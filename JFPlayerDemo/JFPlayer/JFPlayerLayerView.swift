//
//  JFPlayerLayerView.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/14.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit
import AVFoundation

class JFPlayerLayerView: UIView {

    weak var delegate: JFPlayerLayerViewDelegate?
    
    var videoUrl: URL?
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var timer: Timer?
    
    var isPlaying = false
    var isPlayToEnd = false
    var status: JFPlayerStatus = .unknown
    
    // MARK: - Configure
    
    func configurePlayer() {
        if let url = videoUrl {
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
            
            layer.insertSublayer(playerLayer!, at: 0)
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(playerTimerAction), userInfo: nil, repeats: true)
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
    }
    
    func prepareToDeinit() {
        resetPlayer()
    }
    
    deinit {
        debugPrint("JFPlayerLayerView -- deinit")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer?.frame = bounds
    }
    
    func updateUI() {
        setNeedsLayout()
    }

    // MARK: - Actions
    func play() {
        if let player = player {
            isPlaying = true
            player.play()
            timer?.fireDate = Date()
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        timer?.fireDate = .distantFuture
    }
    
    func resetPlayer() {
        
        pause()
        
        playerItem = nil
        playerLayer?.removeFromSuperlayer()
        player?.replaceCurrentItem(with: nil)
        player = nil
        isPlayToEnd = true
        
        timer?.invalidate()
        timer = nil
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func playerTimerAction() {
        guard let playerItem = playerItem else {
            return
        }
        
        if playerItem.duration.timescale != 0 {
            let currentTime = CMTimeGetSeconds(player!.currentTime())
            let totalTime = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)
            delegate?.playerLayerView(playerLayerView: self, trackTimeDidChange: currentTime, totalTime: totalTime)
        }
    }
    
    func onTimeSliderBegan() {
        if player?.currentItem?.status == AVPlayerItemStatus.readyToPlay {
            timer?.fireDate = .distantFuture
        }
    }
    
    func onTimeSliderEnd() {
        if player?.currentItem?.status == AVPlayerItemStatus.readyToPlay {
            timer?.fireDate = Date()
            pause()
        }
    }
    
    func seekToTime(_ seconds: TimeInterval, completionHandler: (() -> Void)? ) {
        if seconds.isNaN {
            return
        }
        
        if player?.currentItem?.status == AVPlayerItemStatus.readyToPlay {
            let draggedTime = CMTimeMake(Int64(seconds), 1)
            player?.seek(to: draggedTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (_) in
                completionHandler?()
            })
        }
    }
    
    func playerDidPlayToEnd(_ notification: Notification) {
        isPlayToEnd = true
        isPlaying = false
        status = .playToEnd
        delegate?.playerLayerView(playerLayerView: self, statusDidChange: status)
        print("xxxxx")
    }
}
