//
//  JFPlayer.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/14.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit
import SnapKit

class JFPlayer: UIView {

    var backClosure: (() -> Void)?
    
    var videoItem: JFPlayerItem!
    var playerLayer: JFPlayerLayerView!
    var controlView: JFPlayerControlView!
    
    var isFullScreen: Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
    var statusBarIsHidden = false
    
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
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: .touchDown)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [.touchUpInside, .touchCancel, .touchUpOutside])
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    func preparePlayer() {
        playerLayer = JFPlayerLayerView()
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
            statusBarIsHidden = false
            
            if let parentViewController = self.parentViewController {
                UIApplication.shared.jf_updateStatusBarAppearanceHidden(statusBarIsHidden, animation: .none, fromViewController: parentViewController)
            }
            UIApplication.shared.statusBarOrientation = .portrait
        } else {
            
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            statusBarIsHidden = false
            
            if let parentViewController = self.parentViewController {
                UIApplication.shared.jf_updateStatusBarAppearanceHidden(statusBarIsHidden, animation: .none, fromViewController: parentViewController)
            }
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
    
    func progressSliderTouchBegan(_ slider: JFTimeSlider) {
        
    }
    
    func progressSliderValueChanged(_ slider: JFTimeSlider) {
        
    }
    
    func progressSliderTouchEnded(_ slider: JFTimeSlider) {
        
    }
    
    func deviceOrientationDidChange() {
        
        setNeedsLayout()
        controlView.updateUI(isForFullScreen: isFullScreen)
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
    }
    
    func pause() {
        playerLayer.pause()
        controlView.playButton.isSelected = false
    }
}

// MARK: - JFPlayerLayerViewDelegate

extension JFPlayer: JFPlayerLayerViewDelegate {
    
}

// MARK: - JFPlayerControlViewDelegate

extension JFPlayer: JFPlayerControlViewDelegate {
    func controlViewDidPressOnReplay() {
        
    }
    
    func controlViewDidSelectDefinition(_ index: Int) {
        
    }
}
