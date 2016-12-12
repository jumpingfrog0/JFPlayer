//
//  JFPlayerProtocols.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/14.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit

// MARK: - JFPlayer Protocols

public protocol JFPlayerControlViewDelegate: class {
    
    
    /// Call this method when user select to change definition
    ///
    /// - parameter index: definition item index
    func controlViewDidSelectDefinition(_ index: Int)
    
    
    /// Call this method when user press on replay button
    func controlViewDidPressOnReplay()
}

protocol JFPlayerDefinitionProtocol {
    
    var videoUrl: URL { get set }
    
    /// definition name, e.g. standard, high, super
    var definitionName: String { get set }
}

protocol JFPlayerLayerViewDelegate: class {
    
    
    /// Call this method to handle something according to current time
    ///
    /// - parameter playerLayerView: the view of player layer
    /// - parameter currentTime:     the time(seconds) has played
    /// - parameter totalTime:       total duration of the player item
    func playerLayerView(playerLayerView: JFPlayerLayerView, trackTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval)
    
    /// Call this method to handle something according to the status of player item
    ///
    /// - parameter playerLayerView: the view of player layer
    /// - parameter status:          the status of player item
    func playerLayerView(playerLayerView: JFPlayerLayerView, statusDidChange status: JFPlayerStatus)
    
    
    /// Call this method to handle progress buffering
    ///
    /// - Parameters:
    ///   - playerLayerView: the view of player layer
    ///   - loadedTime: the time(seconds) has loaded
    ///   - totalDuration: total duration of the player item
    func playerLayerView(playerLayerView: JFPlayerLayerView, loadedTimeDidChange loadedTime: TimeInterval, totalDuration: TimeInterval)
}

// MARK: - JFVrPlayer Protocols

public protocol JFVrPlayerControlViewDelegate: class {
    
    
    /// Call this method when user select to change definition
    ///
    /// - parameter index: definition item index
    func controlViewDidSelectDefinition(_ index: Int)
    
    
    /// Call this method when user press on replay button
    func controlViewDidPressOnReplay()
}

protocol JFVrPlayerLayerViewDelegate: class {
    
    
    /// Call this method to handle something according to current time
    ///
    /// - parameter vrPlayerLayerView: the view of vr player layer
    /// - parameter currentTime:     the time(seconds) that player have played
    /// - parameter totalTime:       total duration of the player item
    func vrPlayerLayerView(vrPlayerLayerView: JFVrPlayerLayerView, trackTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval)
    
    /// Call this method to handle something according to the status of player item
    ///
    /// - parameter vrPlayerLayerView: the view of vr player layer
    /// - parameter status:          the status of player item
    func vrPlayerLayerView(vrPlayerLayerView: JFVrPlayerLayerView, statusDidChange status: JFPlayerStatus)
    
    
    /// Call this method when will play next video
    ///
    /// - Parameters:
    ///   - vrPlayerLayerView: the view of vr player layer
    ///   - name: the next video item
    func vrPlayerLayerView(vrPlayerLayerView: JFVrPlayerLayerView, shouldPlayNextItem item: JFPlayerItem)
}
