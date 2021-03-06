//  JFBrightnessView.swift
//  JFPlayerDemo
//
//  Created by jumpingfrog0 on 14/12/2016.
//
//
//  Copyright (c) 2016 Jumpingfrog0 LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
    var definitionSelectionView = UIView()
    var definitionPreview = JFPlayerButton()
    var modeButton = JFPlayerButton() // only display in VR player
    
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
    
    var lockButton = UIButton()
    
    var configuration = JFPlayerConfiguration()
    
    var isFullScreen = false
    var definitionSelectionIsShrinked = true
    var isVrPlayer = false {
        didSet {
            modeButton.isHidden = !isVrPlayer
            definitionPreview.isHidden = isVrPlayer
            definitionSelectionView.isHidden = isVrPlayer
        }
    }
    
    var definitionCount = 0
    var currentDefinitionIndex = 0
    
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
        topBar.addSubview(definitionPreview)
        
        mainMaskView.addSubview(definitionSelectionView)
        
        backButton.setImage(JFImageResourcePath("JFPlayer_back"), for: .normal)
        
        titleLabel.text = ""
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 16)

        definitionSelectionView.clipsToBounds = true
        
        modeButton.isHidden = true
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
        
        mainMaskView.addSubview(lockButton)
        lockButton.setImage(JFImageResourcePath("JFPlayer_unlock_nor"), for: .normal)
        lockButton.setImage(JFImageResourcePath("JFPlayer_lock_nor"), for: .selected)
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
        
        definitionPreview.snp.makeConstraints { (make) in
            make.right.equalTo(topBar.snp.right).offset(-25)
            make.top.equalTo(titleLabel.snp.top).offset(-4)
            make.width.equalTo(50)
            make.height.equalTo(25)
        }
        
        definitionSelectionView.snp.makeConstraints { (make) in
            make.right.equalTo(topBar.snp.right).offset(-20)
            make.top.equalTo(titleLabel.snp.top).offset(-4)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        modeButton.snp.makeConstraints { (make) in
            make.right.equalTo(topBar.snp.right).offset(-25)
            make.top.equalTo(titleLabel.snp.top).offset(-4)
            make.width.equalTo(50)
            make.height.equalTo(25)
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
        
        lockButton.snp.makeConstraints { (make) in
            make.left.equalTo(mainMaskView).offset(15)
            make.centerY.equalTo(mainMaskView.snp.centerY)
            make.width.height.equalTo(32)
        }
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapAtSlider(_:)))
        progressSlider.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    func pressedReplayButton(_ button: UIButton) {
        button.isHidden = true
    }
    
    func handleTapAtSlider(_ recognizer: UITapGestureRecognizer) {
        let slider = recognizer.view as? JFProgressSlider
        let location = recognizer.location(in: slider)
        let length = slider!.bounds.width
        let tapValue = location.x / length
        
        progressSlider.value = Float(tapValue)
        delegate?.controlView(self, didTapProgressSliderAt: Float(tapValue))
    }
    
    func definitionButtonDidSelect(_ button: UIButton) {
        
        let height = definitionSelectionIsShrinked ? definitionCount * 40 : 35
        definitionSelectionView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
        
        definitionSelectionIsShrinked = !definitionSelectionIsShrinked
        definitionPreview.isHidden = !definitionSelectionIsShrinked
        definitionSelectionView.isHidden = definitionSelectionIsShrinked
        
        // if selection view is expanding, set the current definition button being selected
        if !definitionSelectionIsShrinked {
            
            for button in definitionSelectionView.subviews as! [JFPlayerButton] {
                if button.tag == currentDefinitionIndex {
                    button.isSelected = true
                } else {
                    button.isSelected = false
                }
            }
            
        } else { // will shrink selection view and change definetion
            let curIndex = button.tag
            
            if currentDefinitionIndex != curIndex {
                
                let preIndex = currentDefinitionIndex
                currentDefinitionIndex = curIndex
                
                let preButton = definitionSelectionView.subviews[preIndex] as? JFPlayerButton
                let curButton = definitionSelectionView.subviews[curIndex] as? JFPlayerButton
                preButton?.isSelected = false
                curButton?.isSelected = true
                
                delegate?.controlView(self, didSelectDefinitionAt: button.tag)
                definitionPreview.setTitle(curButton?.titleLabel?.text, for: .normal)
            }
        }
    }
    
    // MARK: - Public Methods
    func prepareDefinitionView(withItems items: [JFPlayerDefinitionProtocol]) {
        
        definitionCount = items.count
        definitionSelectionIsShrinked = true
        definitionSelectionView.isHidden = true
        
        for (idx, item) in items.enumerated() {
            let button = JFPlayerButton()
            button.tag = idx
            button.setTitle(item.definitionName, for: .normal)
            button.addTarget(self, action: #selector(definitionButtonDidSelect(_:)), for: .touchUpInside)
            definitionSelectionView.addSubview(button)
            button.snp.makeConstraints({ (make) in
                make.top.equalTo(definitionSelectionView.snp.top).offset(35 * idx)
                make.width.equalTo(50)
                make.height.equalTo(25)
                make.centerX.equalTo(definitionSelectionView)
            })
            
            if idx == 0 {
                definitionPreview.setTitle(item.definitionName, for: .normal)
                definitionPreview.addTarget(self, action: #selector(definitionButtonDidSelect(_:)), for: .touchUpInside)
                
                if items.count == 1 {
                    definitionPreview.isEnabled = false
                }
            }
        }
    }
    
    func showUIComponents() {
        topBar.alpha = 1.0
        bottomBar.alpha = 1.0
        mainMaskView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        isHidden = false
        
        if definitionCount == 0 {
            definitionPreview.isHidden = true
        } else {
            definitionPreview.isHidden = !isFullScreen
        }
    }
    
    func hideUIComponents() {
        replayButton.isHidden = true
        definitionSelectionView.isHidden = true
        definitionPreview.isHidden = true
        definitionSelectionIsShrinked = true
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
        lockButton.isHidden = !isFullScreen
        
        if definitionCount == 0 {
            definitionPreview.isHidden = true
        } else {
            definitionPreview.isHidden = !isFullScreen
        }
        
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
