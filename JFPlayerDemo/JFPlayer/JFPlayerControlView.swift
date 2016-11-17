//
//  JFPlayerControlView.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/14.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class JFTimeSlider: UISlider {
    
}

 class JFPlayerControlView: UIView {

    weak var delegate: JFPlayerControlViewDelegate?
    
    /// Mask view
    var mainMaskView = UIView()
    var topBar = UIView()
    var bottomBar = UIView()
    
    /// Top
    var backButton = UIButton(type: UIButtonType.custom)
    var titleLabel = UILabel()
    var definitionView = UIView()
    var modeButton = UIButton(type: UIButtonType.custom) // only display in VR player
    
    /// Bottom
    var currentTimeLabel = UILabel()
    var totalTimeLabel = UILabel()
    
    var timeSlider = JFTimeSlider()
    var progressView = UIProgressView()
    
    var playButton = UIButton(type: UIButtonType.custom)
    var fullScreenButton = UIButton(type: UIButtonType.custom)
    
    /// Center
    var loadingIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    var replayButton = UIButton(type: UIButtonType.custom)
    
    var configuration = JFPlayerConfiguration()
    
    var isFullScreen = false
    var isVrPlayer = false {
        didSet {
            modeButton.isHidden = !isVrPlayer
        }
    }
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
        layout()
    }
    
    func initUI() {
        // Mask view
        addSubview(mainMaskView)
        mainMaskView.addSubview(topBar)
        mainMaskView.addSubview(bottomBar)
        mainMaskView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        
        // Top
        topBar.addSubview(backButton)
        topBar.addSubview(titleLabel)
        topBar.addSubview(modeButton)
        
        backButton.setImage(JFImageResourcePath("BMPlayer_back"), for: .normal)
        
        titleLabel.text = ""
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        modeButton.isHidden = true
        modeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        modeButton.setTitle("VR", for: .normal)
        modeButton.setTitle("普通", for: .selected)
        
        // Bottom
        bottomBar.addSubview(playButton)
        bottomBar.addSubview(currentTimeLabel)
        bottomBar.addSubview(totalTimeLabel)
        bottomBar.addSubview(progressView)
        bottomBar.addSubview(timeSlider)
        bottomBar.addSubview(fullScreenButton)
        
        playButton.setImage(JFImageResourcePath("BMPlayer_play"), for: .normal)
        playButton.setImage(JFImageResourcePath("BMPlayer_pause"), for: .selected)
        
        currentTimeLabel.textColor = UIColor.white
        currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        currentTimeLabel.text = "00:00"
        currentTimeLabel.textAlignment = .center
        
        totalTimeLabel.textColor = UIColor.white
        totalTimeLabel.font = UIFont.systemFont(ofSize: 12)
        totalTimeLabel.text = "00:00"
        totalTimeLabel.textAlignment = .center
        
        timeSlider.maximumValue = 1.0
        timeSlider.minimumValue = 0.0
        timeSlider.value = 0.0
        timeSlider.setThumbImage(JFImageResourcePath("BMPlayer_slider_thumb"), for: .normal)
        timeSlider.maximumTrackTintColor = UIColor.clear
        timeSlider.minimumTrackTintColor = configuration.tintColor
        
        progressView.tintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
        progressView.trackTintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        
        fullScreenButton.setImage(JFImageResourcePath("BMPlayer_fullscreen"), for: .normal)
        
        // Center
        mainMaskView.addSubview(loadingIndicator)
        loadingIndicator.type = configuration.loaderType
        loadingIndicator.color = configuration.tintColor
        
        addSubview(replayButton)
        replayButton.isHidden = true
        replayButton.setImage(JFImageResourcePath("BMplayer_replay"), for: .normal)
        replayButton.addTarget(self, action: #selector(pressedReplayButton(_:)), for: .touchUpInside)
    }
    
    func layout() {
        // Main mask view
        mainMaskView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        topBar.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(mainMaskView)
            make.height.equalTo(65)
        }
        
        bottomBar.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(mainMaskView)
            make.height.equalTo(50)
        }
        
        // Top
        backButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.left.bottom.equalTo(topBar)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backButton.snp.right)
            make.centerY.equalTo(backButton)
        }
        
        modeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(backButton)
            make.right.equalTo(topBar.snp.right).offset(-10)
            make.width.height.equalTo(50)
        }
        
        // Bottom
        playButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.left.bottom.equalTo(bottomBar)
        }
        
        currentTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(playButton.snp.right)
            make.centerY.equalTo(playButton)
            make.width.equalTo(40)
        }
        
        timeSlider.snp.makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(currentTimeLabel.snp.right).offset(10).priority(750)
            make.height.equalTo(30)
        }
        
        progressView.snp.makeConstraints { (make) in
            make.centerY.left.right.equalTo(timeSlider)
            make.height.equalTo(2)
        }
        
        totalTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(timeSlider.snp.right).offset(5)
            make.width.equalTo(40)
        }
        
        fullScreenButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(totalTimeLabel.snp.right)
            make.right.equalTo(bottomBar.snp.right)
        }
        
        // Center
        loadingIndicator.snp.makeConstraints { (make) in
            make.centerX.equalTo(mainMaskView.snp.centerX)
            make.centerY.equalTo(mainMaskView.snp.centerY)
        }
        
        replayButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(mainMaskView.snp.centerX)
            make.centerY.equalTo(mainMaskView.snp.centerY)
            make.width.height.equalTo(50)
        }
    }
    
    // MARK: - Actions
    
    func pressedReplayButton(_ button: UIButton) {
        button.isHidden = true
    }
    
    // MARK: - Public Methods
    func showUIComponents() {
        topBar.alpha = 1.0
        bottomBar.alpha = 1.0
        mainMaskView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
    }
    
    func hideUIComponents() {
        replayButton.isHidden = true
        topBar.alpha = 0.0
        bottomBar.alpha = 0.0
        mainMaskView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    }
    
    func showPlayToEndView() {
        replayButton.isHidden = false
    }
    
    func updateUI(isForFullScreen: Bool) {
        
        isFullScreen = isForFullScreen
        
        if isForFullScreen {
            fullScreenButton.setImage(JFImageResourcePath("BMPlayer_portialscreen"), for: .normal)
        } else {
            fullScreenButton.setImage(JFImageResourcePath("BMPlayer_fullscreen"), for: .normal)
        }
    }
}
