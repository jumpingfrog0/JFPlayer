//
//  JFVrPlayer.swift
//  SceneKitDemo
//
//  Created by sheldon on 2016/11/11.
//  Copyright © 2016年 sheldon. All rights reserved.
//

import UIKit
import SceneKit

class JFVrPlayer: UIView {
    
    var backClosure: (() -> Void)?
    
    var menus: [String]?
    var episodes: [JFPlayerItem]?
    
    var playerLayer: JFVrPlayerLayerView!
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
        debugPrint("JFVrPlayer -- deinit")
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
        controlView.isVrPlayer = true
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
        controlView.progressSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: .touchDown)
        controlView.progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        controlView.progressSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [.touchUpInside, .touchCancel, .touchUpOutside])
        controlView.modeButton.addTarget(self, action: #selector(modeButtonPressed(_:)), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    func preparePlayer() {
        playerLayer = JFVrPlayerLayerView()
        playerLayer.delegate = self
        insertSubview(playerLayer, at: 0)
        playerLayer.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
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
    
    func deviceOrientationDidChange() {
        
        setNeedsLayout()
        controlView.updateUI(isForFullScreen: isFullScreen)
        playerLayer.updateUI(isForFullScreen: isFullScreen)
    }
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
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
    
    // FIXME: - Bug: sometimes crash -
    func backButtonPressed(_ button: UIButton) {
        if isFullScreen {
            fullScreenButtonPressed(nil)
        } else {
            playerLayer.prepareToDeinit()
            self.backClosure?()
        }
    }
    
    func replayButtonPressed(_ button: UIButton) {
        replay()
    }
    
    func progressSliderTouchBegan(_ slider: JFProgressSlider) {
        playerLayer.onTimeSliderBegan()
    }
    
    func progressSliderValueChanged(_ slider: JFProgressSlider) {
        let target = totalDuration * TimeInterval(slider.value)
        controlView.currentTimeLabel.text = formatSecondsToString(target)
    }
    
    func progressSliderTouchEnded(_ slider: JFProgressSlider) {
        let target = totalDuration * TimeInterval(slider.value)
        playerLayer.onTimeSliderEnd()
        playerLayer.seekToTime(target, completionHandler: nil)
        play()
    }
    
    func modeButtonPressed(_ button: UIButton) {
        button.isSelected = !button.isSelected
        playerLayer.switchMode()
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
            
            }, completion: { _ in
                self.isMaskShowing = true
                
                // do not fade out control view if player is paused
                if self.playerLayer.isPlaying {
                    self.autoFadeOutControlView()
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

// MARK: - JFVrPlayerLayerViewDelegate

extension JFVrPlayer: JFVrPlayerLayerViewDelegate {
    func vrPlayerLayerView(vrPlayerLayerView: JFVrPlayerLayerView, trackTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        totalDuration = totalTime
        controlView.currentTimeLabel.text = formatSecondsToString(currentTime)
        controlView.totalTimeLabel.text = formatSecondsToString(totalTime)
        controlView.progressSlider.value = Float(currentTime / totalTime)
    }
    
    func vrPlayerLayerView(vrPlayerLayerView: JFVrPlayerLayerView, statusDidChange status: JFPlayerStatus) {
        switch status {
        case .playToEnd:
            if let episodes = episodes {
                playerLayer.showEpisodes(episodes: episodes)
            }
        default:
            break
        }
    }
    
    func vrPlayerLayerView(vrPlayerLayerView: JFVrPlayerLayerView, shouldPlayNextItem item: JFPlayerItem) {
        playerLayer.resetPlayer()
        showControlViewAnimated()
        controlView.showLoader()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.controlView.hideLoader()
            self.playWithUrl(item.resources[0].videoUrl, title: item.title)
        })
        
    }
}

// MARK: - JFVrPlayerControlViewDelegate

extension JFVrPlayer: JFPlayerControlViewDelegate {
    func controlViewDidPressOnReplay() {
        
    }
    
    func controlView(_ controlView: JFPlayerControlView, didSelectDefinitionAt index: Int) {
        
    }
    
    func controlView(_ controlView: JFPlayerControlView, didTapProgressSliderAt value: Float) {
        
    }
}
