//
//  JFPlayerLayerView.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/14.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit
import AVFoundation

protocol JFPlayerLayerViewDelegate: class {
    
}

class JFPlayerLayerView: UIView {

    weak var delegate: JFPlayerLayerViewDelegate?
    
    var videoUrl: URL?
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var isPlaying = false
    
    // MARK: - Configure
    
    func configurePlayer() {
        if let url = videoUrl {
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            
            layer.insertSublayer(playerLayer!, at: 0)
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func prepareToDeinit() {
        resetPlayer()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer?.frame = bounds
    }

    // MARK: - Actions
    func play() {
        if let player = player {
            isPlaying = true
            player.play()
            
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        
    }
    
    func resetPlayer() {
        
        pause()
        
        playerItem = nil
        playerLayer?.removeFromSuperlayer()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
}
