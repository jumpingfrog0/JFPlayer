//
//  JFPlayer.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/14.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit
import SnapKit

public func JFImageResourcePath(_ filename: String) -> UIImage? {
    if let bunbleUrl = Bundle.main.url(forResource: "JFPlayer", withExtension: "bundle") {
        if let bunble = Bundle(url: bunbleUrl) {
            return UIImage(named: filename, in: bunble, compatibleWith: nil)
        } else {
            assertionFailure("Could not load the bundle")
        }
    } else {
        assertionFailure("Could not create a path to the bundle")
    }
    return nil
}

enum JFPlayerStatus {
    case unknown
    case failed
    case readyToPlay
    case buffering
    case bufferFinished
    case playToEnd
}

extension JFPlayer {
    struct AnimationTimeInterval {
        static let fadeOut = 0.5
        static let delay = 4.0

    }
}

class JFPlayer: UIView {

    var backClosure: (() -> Void)?
    
    var videoItem: JFPlayerItem!
    var playerLayer: JFPlayerLayerView!
    var controlView: JFPlayerControlView!
    
    var isFullScreen: Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
    
    var isMaskShowing = true
    var statusBarIsHidden = false
    var totalDuration: TimeInterval = 0
    
    /// using for avoiding bugs in full screen mode
    fileprivate var sizeRatioDetected = false
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        addActionListener()
        preparePlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
        addActionListener()
        preparePlayer()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !sizeRatioDetected {
            detectSizeRatio()
            sizeRatioDetected = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        debugPrint("JFPlayer -- deinit")
    }
    
    // MARK: - Public Methods
    
    func playWithUrl(_ url: URL, title: String = "") {
        playerLayer.videoUrl = url
        controlView.titleLabel.text = title
        playerLayer.configurePlayer()
        play()
    }
    
    func play() {
        playerLayer.play()
        controlView.playButton.isSelected = true
        autoFadeOutControlView()
    }
    
    func pause() {
        playerLayer.pause()
        controlView.playButton.isSelected = false
        showControlViewAnimated()
    }
    
    func replay() {
        playerLayer.isPlayToEnd = false
        playerLayer.seekToTime(0) { [unowned self] in
            self.play()
        }
    }
    
    func autoFadeOutControlView() {
        cancelAutoFadeOutControlView()
        perform(#selector(hideControlViewAnimated), with: nil, afterDelay: JFPlayer.AnimationTimeInterval.delay)
    }
    
    func cancelAutoFadeOutControlView() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    // MARK: - Setup
    
    func initUI() {
        backgroundColor = UIColor.black
        
        controlView = JFPlayerControlView()
        controlView.delegate = self
        addSubview(controlView)
        
        controlView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        controlView.updateUI(isForFullScreen: false)
    }
    
    func addActionListener() {
        controlView.playButton.addTarget(self, action: #selector(playButtonPressed(_:)), for: .touchUpInside)
        controlView.fullScreenButton.addTarget(self, action: #selector(fullScreenButtonPressed(_:)), for: .touchUpInside)
        controlView.backButton.addTarget(self, action: #selector(backButtonPressed(_:)), for: .touchUpInside)
        controlView.replayButton.addTarget(self, action: #selector(replayButtonPressed(_:)), for: .touchUpInside)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: .touchDown)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [.touchUpInside, .touchCancel, .touchUpOutside])
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureTapped(_:))))
    }
    
    func preparePlayer() {
        playerLayer = JFPlayerLayerView()
        playerLayer.delegate = self
        insertSubview(playerLayer, at: 0)
        playerLayer.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        controlView.showLoader()
    }
    
    
    /// Using for avoiding bugs in full screen mode
    fileprivate func detectSizeRatio() {
        let expectedHeight = UIScreen.main.bounds.width * (UIScreen.main.bounds.width / UIScreen.main.bounds.height)
        if fabs(bounds.height - expectedHeight) < 0.25 {
            // The size proportion in line with expectations, do nothing
        } else {
            // The size is not in conformity with the expected rate
            assert(false, "The size is not in conformity with the expected rate, please set the size of JFPlayer to (UIScreen.main.bounds.width, UIScreen.main.bounds.height)")
        }
    }
    
    // MARK: - Actions
    
    func tapGestureTapped(_ recognizer: UITapGestureRecognizer) {
        if isMaskShowing {
            hideControlViewAnimated()
        } else {
            showControlViewAnimated()
        }
    }
    
    func playButtonPressed(_ button: UIButton) {
        if playerLayer.isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func fullScreenButtonPressed(_ button: UIButton?) {
        
        // force change device and status bar orientation, that toggle the UIApplicationDidChangeStatusBarOrientation notification
        if isFullScreen {
            
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            updateStatusBarAppearanceHidden(false)
            UIApplication.shared.statusBarOrientation = .portrait
        } else {
            
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            updateStatusBarAppearanceHidden(false)
            UIApplication.shared.statusBarOrientation = .landscapeRight
        }
    }
    
    func backButtonPressed(_ button: UIButton) {
        if isFullScreen {
            fullScreenButtonPressed(nil)
        } else {
            playerLayer.prepareToDeinit()
            backClosure?()
        }
    }
    
    func replayButtonPressed(_ button: UIButton) {
        controlView.hidePlayToEndView()
        replay()
    }
    
    func progressSliderTouchBegan(_ slider: JFTimeSlider) {
        playerLayer.onTimeSliderBegan()
    }
    
    func progressSliderValueChanged(_ slider: JFTimeSlider) {
        let target = totalDuration * TimeInterval(slider.value)
        controlView.currentTimeLabel.text = formatSecondsToString(target)
    }
    
    func progressSliderTouchEnded(_ slider: JFTimeSlider) {
        let target = totalDuration * TimeInterval(slider.value)
        playerLayer.onTimeSliderEnd()
        playerLayer.seekToTime(target, completionHandler: nil)
        play()
    }
    
    func deviceOrientationDidChange() {
        
        setNeedsLayout()
        controlView.updateUI(isForFullScreen: isFullScreen)
    }
    
    // MARK: - Private Methods
    fileprivate func formatSecondsToString(_ seconds: TimeInterval) -> String {
        let min = Int(seconds / 60)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", min, sec)
    }
    
    fileprivate func showControlViewAnimated() {
        UIView.animate(withDuration: JFPlayer.AnimationTimeInterval.fadeOut, animations: {
            
            self.controlView.showUIComponents()
            self.updateStatusBarAppearanceHidden(false)
            
            if self.playerLayer.isPlayToEnd {
                self.controlView.showPlayToEndView()
            }
            
        }, completion: { _ in
            self.isMaskShowing = true
            
            // do not fade out control view if player is paused
            if self.playerLayer.isPlaying {
                self.autoFadeOutControlView()
            } else if self.playerLayer.isPlayToEnd {
                self.cancelAutoFadeOutControlView()
            } else {
                self.cancelAutoFadeOutControlView()
            }
        })
    }
    
    @objc fileprivate func hideControlViewAnimated() {
        UIView.animate(withDuration: JFPlayer.AnimationTimeInterval.fadeOut, animations: {
            
            self.controlView.hideUIComponents()
            self.updateStatusBarAppearanceHidden(true)
            
        }, completion: { _ in
            self.isMaskShowing = false
            self.cancelAutoFadeOutControlView()
        })
    }
    
    fileprivate func updateStatusBarAppearanceHidden(_ hidden: Bool) {
        statusBarIsHidden = hidden
        if let parentViewController = self.parentViewController {
            UIApplication.shared.jf_updateStatusBarAppearanceHidden(self.statusBarIsHidden, animation: .none, fromViewController: parentViewController)
        }
    }
}

// MARK: - JFPlayerLayerViewDelegate

extension JFPlayer: JFPlayerLayerViewDelegate {
    func playerLayerView(playerLayerView: JFPlayerLayerView, trackTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        totalDuration = totalTime
        controlView.currentTimeLabel.text = formatSecondsToString(currentTime)
        controlView.totalTimeLabel.text = formatSecondsToString(totalTime)
        controlView.timeSlider.value = Float(currentTime / totalTime)
    }
    
    func playerLayerView(playerLayerView: JFPlayerLayerView, statusDidChange status: JFPlayerStatus) {
        switch status {
            
        case .readyToPlay:
            controlView.hideLoader()
            
        case .buffering:
            cancelAutoFadeOutControlView()
            controlView.showLoader()
            
        case .bufferFinished:
            controlView.hideLoader()
            
        case .playToEnd:
            controlView.showPlayToEndView()
            showControlViewAnimated()
        default:
            break
        }
    }
    
    func playerLayerView(playerLayerView: JFPlayerLayerView, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        controlView.progressView.setProgress(Float(loadedDuration / totalDuration), animated: true)
    }
}

// MARK: - JFPlayerControlViewDelegate

extension JFPlayer: JFPlayerControlViewDelegate {
    func controlViewDidPressOnReplay() {
        
    }
    
    func controlViewDidSelectDefinition(_ index: Int) {
        
    }
}
