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
    
    var originBounds: CGRect?
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        preparePlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
        preparePlayer()
    }
    
//    convenience init(cu)
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isFullScreen {
            
            if originBounds == nil {
                originBounds = bounds
            }
            
            self.snp.remakeConstraints({ (make) in
                make.left.equalTo(superview!).offset(0)
                make.top.equalTo(superview!).offset(0)
                make.width.equalTo(UIScreen.main.bounds.width)
                make.height.equalTo(UIScreen.main.bounds.height)
            })
            
            UIApplication.shared.isStatusBarHidden = false
            
        } else {
            
            if let width = originBounds?.width, let height = originBounds?.height {
                self.snp.remakeConstraints({ (make) in
                    make.left.equalTo(superview!).offset(0)
                    make.top.equalTo(superview!).offset(0)
                    make.width.equalTo(width)
                    make.height.equalTo(height)
                })
            }
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
    
    func deviceOrientationDidChange() {
        
        setNeedsLayout()
    }

    // MARK: - Public Methods
    
    func playWithUrl(_ url: URL, title: String = "") {
        playerLayer.videoUrl = url
        playerLayer.configurePlayer()
        playerLayer.play()
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
