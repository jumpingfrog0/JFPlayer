//
//  JFPlayerItem.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/14.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit

class JFPlayerItem {
    var title: String
    var resource: [JFPlayerDefinitionProtocol]
    var cover: String
    
    init(title: String, resource: [JFPlayerDefinitionProtocol], cover: String = "") {
        self.title = title
        self.resource = resource
        self.cover = cover
    }
}

class JFPlayerDefinitionItem: JFPlayerDefinitionProtocol {
    var videoUrl: URL
    var definitionName: String
    
    init(url: URL, definitionName: String) {
        self.videoUrl = url
        self.definitionName = definitionName
    }
}
