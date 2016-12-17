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

// MARK: - JFPlayer Protocols

protocol JFPlayerControlViewDelegate: class {
    
    
    /// Call this method when user select to change definition
    ///
    /// - parameter index: definition item index
    func controlView(_ controlView: JFPlayerControlView, didSelectDefinitionAt index: Int)
    
    
    /// Call this method when user press on replay button
    func controlViewDidPressOnReplay()
    
    func controlView(_ controlView: JFPlayerControlView, didTapProgressSliderAt value: Float)
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
