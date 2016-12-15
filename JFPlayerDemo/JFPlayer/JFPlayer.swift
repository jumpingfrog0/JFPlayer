//
//  JFPlayer.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/14.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit
import SnapKit
import MediaPlayer

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

enum JFPanDirection: Int {
    case horizontal = 0
    case vertical = 1
}

extension JFPlayer {
    struct AnimationTimeInterval {
        static let fadeOut = 0.5
        static let delay = 4.0

    }
    
    class func formatSecondsToString(_ seconds: Int) -> String {
        let durMin = seconds / 60
        let durSec = seconds % 60

        return String(format: "%02zd:%02zd", durMin, durSec)
    }
}

class JFPlayer: UIView {

    var backClosure: (() -> Void)?
    
    var playerLayer: JFPlayerLayerView!
    var controlView: JFPlayerControlView!
    var volumeSlider: UISlider!
    
    var isFullScreen: Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
    
    var isMaskShowing = true
    var statusBarIsHidden = false
    var isVolumeAdjusting = false
    var isSliding = false
    
    var currentTime: TimeInterval = 0
    var totalDuration: TimeInterval = 0
    var sumDuration: TimeInterval = 0
    var sliderLastValue: Float = 0
    var shouldSeekTo: TimeInterval = 0
    
    fileprivate var videoItem: JFPlayerItem?
    
    fileprivate var panDirection = JFPanDirection.horizontal
    
    /// using for avoiding bugs in full screen mode
    fileprivate var sizeRatioDetected = false
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        addActionListener()
        configureVolume()
        preparePlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
        addActionListener()
        configureVolume()
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
    
    func play(withUrl url: URL, title: String = "") {
        playerLayer.videoUrl = url
        controlView.titleLabel.text = title
        playerLayer.configurePlayer()
        play()
    }
    
    func play(withItem item: JFPlayerItem, title: String = "") {
        videoItem = item
        playerLayer.videoItem = item
        playerLayer.videoUrl = item.resources.first?.videoUrl
        playerLayer.configurePlayer()
        controlView.titleLabel.text = title
        controlView.prepareDefinitionView(withItems: item.resources)
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
        
        let brightnessView = JFBrightnessView.shared
        UIApplication.shared.keyWindow?.addSubview(brightnessView)
    }
    
    func addActionListener() {
        controlView.playButton.addTarget(self, action: #selector(playButtonPressed(_:)), for: .touchUpInside)
        controlView.fullScreenButton.addTarget(self, action: #selector(fullScreenButtonPressed(_:)), for: .touchUpInside)
        controlView.backButton.addTarget(self, action: #selector(backButtonPressed(_:)), for: .touchUpInside)
        controlView.replayButton.addTarget(self, action: #selector(replayButtonPressed(_:)), for: .touchUpInside)
        controlView.progressSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: .touchDown)
        controlView.progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        controlView.progressSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [.touchUpInside, .touchCancel, .touchUpOutside])
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
        // add gestures
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
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
    
    func configureVolume() {
        let volumeView = MPVolumeView()
        for view in volumeView.subviews {
            if let slider = view as? UISlider {
                volumeSlider = slider
            }
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
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        if isMaskShowing {
            hideControlViewAnimated()
        } else {
            showControlViewAnimated()
        }
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        let location = recognizer.location(in: self)
        let velocity = recognizer.velocity(in: self)
        
        switch recognizer.state {
        case .began:
            
            let x = fabs(velocity.x)
            let y = fabs(velocity.y)
            
            if x > y { // move horizontally
                
                panDirection = .horizontal
                
                if let player = playerLayer.player {
                    let time = player.currentTime()
                    sumDuration = TimeInterval(time.value) / TimeInterval(time.timescale)
                    
                    playerLayer.onTimeSliderBegan()
                    controlView.seekViewDraggedBegin()
                }
                
            } else { // move vertically
                
                panDirection = .vertical
                if location.x > bounds.width / 2.0 { // adjust volume
                    isVolumeAdjusting = true
                } else {
                    isVolumeAdjusting = false
                }
            }
            
        case .changed:
            switch panDirection {
            case .horizontal:
                horizontalMoved(velocity.x)
                
            case .vertical:
                verticalMoved(velocity.y)
            }
            
        case .ended:
            sumDuration = 0.0
            progressSliderTouchEnded(controlView.progressSlider)
            
        default:
            break
        }
    }
        
    func horizontalMoved(_ value: CGFloat) {
        
        guard let playerItem = playerLayer.playerItem else {
            return
        }
        
        sumDuration += TimeInterval(value / 200)
        
        let totalTime = playerItem.duration
        let totalDuration = TimeInterval(totalTime.value) / TimeInterval(totalTime.timescale)
        
        if sumDuration > totalDuration {
            sumDuration = totalDuration
        }
        if sumDuration < 0 {
            sumDuration = 0
        }
        
        let isForword = value > 0
        
        controlView.seek(to: sumDuration, totalDuration: totalDuration, isForword: isForword)
    }
    
    func verticalMoved(_ value: CGFloat) {
        if isVolumeAdjusting {
            volumeSlider.value -= Float(value / 10000)
        } else {
            UIScreen.main.brightness -= value / 10000
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
    
    func progressSliderTouchBegan(_ slider: JFProgressSlider) {
        isSliding = true
        cancelAutoFadeOutControlView()
        playerLayer.onTimeSliderBegan()
        controlView.seekViewDraggedBegin()
    }
    
    func progressSliderValueChanged(_ slider: JFProgressSlider) {
    
        let isForword = (slider.value - sliderLastValue) > 0
        
        controlView.seek(to: TimeInterval(slider.value) * totalDuration, totalDuration: totalDuration, isForword: isForword)
    }
    
    func progressSliderTouchEnded(_ slider: JFProgressSlider) {
        sliderLastValue = slider.value
        let target = totalDuration * TimeInterval(slider.value)
        playerLayer.onTimeSliderEnd()
        playerLayer.seekToTime(target, completionHandler: { [unowned self] in
            self.play()
        })
        controlView.seekViewDraggedEnd()
        
        if !playerLayer.isPlayToEnd { // hide replay button if not play to the end
            controlView.hidePlayToEndView()
        }
        
        if isSliding { // being dragged the progress slider
            autoFadeOutControlView()
        }
    }
    
    func deviceOrientationDidChange() {
        
        setNeedsLayout()
        controlView.updateUI(isForFullScreen: isFullScreen)
    }
    
    // MARK: - Private Methods
    
    fileprivate func showControlViewAnimated() {
        UIView.animate(withDuration: JFPlayer.AnimationTimeInterval.fadeOut, animations: {
            
            self.controlView.showUIComponents()
            self.updateStatusBarAppearanceHidden(false)
            
            if self.playerLayer.isPlayToEnd {
                self.controlView.showPlayToEndView()
            }
            
        }, completion: { _ in
            self.isMaskShowing = true
            
            // do not fade out control view if being paused or playing to the end
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
        self.currentTime = currentTime
        totalDuration = totalTime
        controlView.currentTimeLabel.text = JFPlayer.formatSecondsToString(Int(currentTime))
        controlView.totalTimeLabel.text = JFPlayer.formatSecondsToString(Int(totalTime))
        controlView.progressSlider.value = Float(currentTime / totalTime)
    }
    
    func playerLayerView(playerLayerView: JFPlayerLayerView, statusDidChange status: JFPlayerStatus) {
        switch status {
            
        case .readyToPlay:
            controlView.hideLoader()
            if shouldSeekTo != 0 {
                playerLayer.seekToTime(shouldSeekTo, completionHandler: { [unowned self] in
                    self.play()
                    self.shouldSeekTo = 0
                })
            }
            
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
    
    func controlView(_ controlView: JFPlayerControlView, didSelectDefinitionAt index: Int) {
        playerLayer.resetPlayer()
        
        if let item = videoItem {
            play(withUrl: item.resources[index].videoUrl)
        }
        shouldSeekTo = currentTime
    }
    
    func controlView(_ controlView: JFPlayerControlView, didTapProgressSliderAt value: Float) {
        
        progressSliderTouchEnded(controlView.progressSlider)
    }
}
