//
//  JFPlayerControlView.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/14.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

open class JFProgressSlider: UISlider {
    open override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let trackHeight = CGFloat(2.0)
        let positon = CGPoint(x: 0, y: 14)
        let customBounds = CGRect(origin: positon, size: CGSize(width: bounds.size.width, height: trackHeight))
        
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    open override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let rect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        let newX = rect.origin.x - 10
        let newRect = CGRect(x: newX, y: 0, width: 30, height: 30)
        return newRect
    }
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
    
    var progressSlider = JFProgressSlider()
    var progressView = UIProgressView()
    
    var playButton = UIButton(type: UIButtonType.custom)
    var fullScreenButton = UIButton(type: UIButtonType.custom)
    
    /// Center
    var loadingIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    var replayButton = UIButton(type: UIButtonType.custom)
    
    var seekView = UIView()
    var seekImageView = UIImageView()
    var seekLabel = UILabel()
    var seekProgressView = UIProgressView()
    
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
        setupGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
        layout()
        setupGestures()
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
        
        backButton.setImage(JFImageResourcePath("JFPlayer_back"), for: .normal)
        
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
        bottomBar.addSubview(progressSlider)
        bottomBar.addSubview(fullScreenButton)
        
        playButton.setImage(JFImageResourcePath("JFPlayer_play"), for: .normal)
        playButton.setImage(JFImageResourcePath("JFPlayer_pause"), for: .selected)
        
        currentTimeLabel.textColor = UIColor.white
        currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        currentTimeLabel.text = "00:00"
        currentTimeLabel.textAlignment = .center
        
        totalTimeLabel.textColor = UIColor.white
        totalTimeLabel.font = UIFont.systemFont(ofSize: 12)
        totalTimeLabel.text = "00:00"
        totalTimeLabel.textAlignment = .center
        
        progressSlider.maximumValue = 1.0
        progressSlider.minimumValue = 0.0
        progressSlider.value = 0.0
        progressSlider.setThumbImage(JFImageResourcePath("JFPlayer_slider_thumb"), for: .normal)
        progressSlider.maximumTrackTintColor = UIColor.clear
        progressSlider.minimumTrackTintColor = configuration.tintColor
        
        progressView.tintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
        progressView.trackTintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        
        fullScreenButton.setImage(JFImageResourcePath("JFPlayer_fullscreen"), for: .normal)
        
        // Center
        mainMaskView.addSubview(loadingIndicator)
        loadingIndicator.type = configuration.loaderType
        loadingIndicator.color = configuration.tintColor
        
        mainMaskView.addSubview(replayButton)
        replayButton.isHidden = true
        replayButton.setImage(JFImageResourcePath("JFPlayer_replay"), for: .normal)
        replayButton.addTarget(self, action: #selector(pressedReplayButton(_:)), for: .touchUpInside)
        
        mainMaskView.addSubview(seekView)
        seekView.addSubview(seekImageView)
        seekView.addSubview(seekLabel)
        seekView.addSubview(seekProgressView)
        
        seekLabel.font = UIFont.systemFont(ofSize: 13)
        seekLabel.textColor = UIColor.white
        seekLabel.textAlignment = .center
        
        seekProgressView.progressTintColor = UIColor.white
        seekProgressView.trackTintColor = UIColor.lightGray.withAlphaComponent(0.4)
        
        seekView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        seekView.layer.cornerRadius = 4
        seekView.layer.masksToBounds = true
        seekView.isHidden = true
        
        seekImageView.image = JFImageResourcePath("JFPlayer_fast_forward")
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
        
        progressSlider.snp.makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(currentTimeLabel.snp.right).offset(10).priority(750)
            make.height.equalTo(30)
        }
        
        progressView.snp.makeConstraints { (make) in
            make.centerY.left.right.equalTo(progressSlider)
            make.height.equalTo(2)
        }
        
        totalTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(progressSlider.snp.right).offset(5)
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
        
        seekView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(125)
            make.height.equalTo(80)
        }
        
        seekImageView.snp.makeConstraints { (make) in
            make.height.equalTo(32)
            make.width.equalTo(32)
            make.top.equalTo(5)
            make.centerX.equalTo(seekView.snp.centerX)
        }
        
        seekLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(seekImageView.snp.bottom).offset(2)
        }
        
        seekProgressView.snp.makeConstraints { (make) in
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.top.equalTo(seekLabel.snp.bottom).offset(10)
        }
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        progressSlider.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    func pressedReplayButton(_ button: UIButton) {
        button.isHidden = true
    }
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        let slider = recognizer.view as? JFProgressSlider
        let location = recognizer.location(in: slider)
        let length = slider!.bounds.width
        let tapValue = location.x / length
        
        progressSlider.value = Float(tapValue)
        delegate?.controlView(self, didTapProgressSliderAt: Float(tapValue))
    }
    
    // MARK: - Public Methods
    func showUIComponents() {
        topBar.alpha = 1.0
        bottomBar.alpha = 1.0
        mainMaskView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        isHidden = false
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
    
    func hidePlayToEndView() {
        replayButton.isHidden = true
    }
    
    func updateUI(isForFullScreen: Bool) {
        
        isFullScreen = isForFullScreen
        
        if isForFullScreen {
            fullScreenButton.setImage(JFImageResourcePath("JFPlayer_portialscreen"), for: .normal)
        } else {
            fullScreenButton.setImage(JFImageResourcePath("JFPlayer_fullscreen"), for: .normal)
        }
    }
    
    func showLoader() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func hideLoader() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
    }
    
    func seek(to draggedTime: TimeInterval, totalDuration: TimeInterval, isForword: Bool) {
        
        if draggedTime.isNaN || totalDuration.isNaN { // avoid value being NaN 
            return
        }
        
        let rotate = isForword ? 0 : CGFloat(M_PI)
        seekImageView.transform = CGAffineTransform(rotationAngle: rotate)
        seekLabel.text = JFPlayer.formatSecondsToString(Int(draggedTime)) + " / " + JFPlayer.formatSecondsToString(Int(totalDuration))
        seekProgressView.setProgress( Float(draggedTime / totalDuration), animated: true)
        
        progressSlider.value = Float(draggedTime / totalDuration)
        currentTimeLabel.text = JFPlayer.formatSecondsToString(Int(draggedTime))
    }
    
    func seekViewDraggedBegin() {
        seekView.isHidden = false
    }
    
    func seekViewDraggedEnd() {
        seekView.isHidden = true
    }
}
