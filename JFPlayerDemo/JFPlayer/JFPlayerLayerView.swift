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
    var isBuffering = false
    
    var status: JFPlayerStatus = .unknown {
        didSet {
            delegate?.playerLayerView(playerLayerView: self, statusDidChange: status)
        }
    }
    
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
            playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
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

    // MARK: - Actions & Events
    func play() {
        if let player = player {
            isPlaying = true
            isPlayToEnd = false
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
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        
        playerItem = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player?.replaceCurrentItem(with: nil)
        player = nil
        isPlayToEnd = false
        
        timer?.invalidate()
        timer = nil
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
            
            // pause for fixing a bug that the playback speed is not consistent
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
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let item = object as? AVPlayerItem, let keyPath = keyPath else {
            return
        }
        
        guard item == playerItem else {
            return
        }
        
        switch keyPath {
            
        case "status":
            if player?.status == AVPlayerStatus.readyToPlay {
                status = .readyToPlay
            } else if player?.status == AVPlayerStatus.failed {
                status = .failed
            } else {
                status = .unknown
            }
            
        case "loadedTimeRanges":
            let loadedDuration = availableDuration()
            let totalDuration = CMTimeGetSeconds(item.duration)
            delegate?.playerLayerView(playerLayerView: self, loadedTimeDidChange: loadedDuration, totalDuration: totalDuration)
            
        case "playbackBufferEmpty":
            if item.isPlaybackBufferEmpty {
                status = .buffering
            }
        
        case "playbackLikelyToKeepUp":
            if item.isPlaybackLikelyToKeepUp && status == .buffering {
                status = .bufferFinished
                player?.play()
            } else if !item.isPlaybackLikelyToKeepUp {
                status = .buffering
            }
            
        default: break
        }
    }
    
    /// Progress buffer
    fileprivate func availableDuration() -> TimeInterval {
        guard let loadedTimeRanges = player?.currentItem?.loadedTimeRanges,
            let first = loadedTimeRanges.first else {
            return 0
        }
        
        let timeRange = first.timeRangeValue
        let result = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration)
        return result
    }
    
    fileprivate func bufferingSomeSecond() {
        if isBuffering {
            return
        }
        
        isBuffering = true
        
        // pause for a while to avoid some unexpected and unpredicable issues.
        player?.pause()
        
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * 1.0 )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
            
            self.isBuffering = false
            
            if let item = self.playerItem {
                if item.isPlaybackLikelyToKeepUp {
                    self.status = .bufferFinished
                    self.player?.play()
                } else {
                    self.bufferingSomeSecond()
                }
            }
        })
    }
}
