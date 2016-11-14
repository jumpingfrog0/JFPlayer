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
    
    var isFullScreen = false
    
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
    
//    func updateUI() {
//        if isFullScreen {
//            fullScreenButton.setImage(<#T##image: UIImage?##UIImage?#>, for: <#T##UIControlState#>)
//        }
//    }
}
