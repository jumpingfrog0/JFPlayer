//
//  JFPlayerProtocols.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/14.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit

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
