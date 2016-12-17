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
import SceneKit

class JFVrPlayerControlBar: SCNNode {

    var playOrPausePlane: SCNPlane!
    
    override init() {
        super.init()
        
        let layerPlane = SCNPlane(width: 2, height: 1.5)
        layerPlane.firstMaterial?.isDoubleSided = true
        layerPlane.firstMaterial?.diffuse.contents = UIColor.black
        layerPlane.firstMaterial?.diffuse.wrapS = .clamp
        layerPlane.firstMaterial?.diffuse.wrapT = .clamp
        layerPlane.firstMaterial?.diffuse.mipFilter = .nearest
        layerPlane.firstMaterial?.locksAmbientWithDiffuse = true
        layerPlane.firstMaterial?.shininess = 0.0
        
        let layerNode = SCNNode(geometry: layerPlane)
        layerNode.position = SCNVector3(x: 0, y: 0, z: -5)
        layerNode.physicsBody = SCNPhysicsBody.static()
        layerNode.physicsBody?.restitution = 1.0
        
        playOrPausePlane = SCNPlane(width: 0.5, height: 0.5)
        playOrPausePlane.firstMaterial?.isDoubleSided = true
        playOrPausePlane.firstMaterial?.diffuse.contents = JFImageResourcePath("JFPlayer_pause")
        playOrPausePlane.firstMaterial?.diffuse.wrapS = .clamp
        playOrPausePlane.firstMaterial?.diffuse.wrapT = .clamp
        playOrPausePlane.firstMaterial?.diffuse.mipFilter = .nearest
        playOrPausePlane.firstMaterial?.locksAmbientWithDiffuse = true
        playOrPausePlane.firstMaterial?.shininess = 0.0
        
        let playOrPauseNode = SCNNode(geometry: playOrPausePlane)
        playOrPauseNode.position = SCNVector3(x: 0, y: 0, z: -4)
        playOrPauseNode.name = "PlayorPauseButton"
        playOrPauseNode.physicsBody = SCNPhysicsBody.static()
        playOrPauseNode.physicsBody?.restitution = 1.0

//        layerNode.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(-60), 0, 0)
        
        let rotationNode = SCNNode()
        rotationNode.position = SCNVector3(x: 0, y: 0, z: 0)
        addChildNode(rotationNode)
        
        rotationNode.addChildNode(layerNode)
        rotationNode.addChildNode(playOrPauseNode)
        
        let rotate = SCNAction.rotate(by: CGFloat(-M_PI * 1.0 / 3), around: SCNVector3(x: 1, y: 0, z: 0), duration: 0.0)
        rotationNode.runAction(rotate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(shouldPause: Bool) {
        if shouldPause {
            playOrPausePlane.firstMaterial?.diffuse.contents = JFImageResourcePath("JFPlayer_play")
        } else {
            playOrPausePlane.firstMaterial?.diffuse.contents = JFImageResourcePath("JFPlayer_pause")
        }
    }
}
