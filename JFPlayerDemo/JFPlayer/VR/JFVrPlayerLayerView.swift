//
//  JFVrPlayerLayerView.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/17.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import CoreMotion
import SpriteKit
import AVFoundation

class JFVrPlayerLayerView: UIView {

    // Scene
    var leftSceneView: SCNView!
    var rightSceneView: SCNView!
    var scene: SCNScene!
    
    var motionManager: CMMotionManager!

    // Camera
    fileprivate var leftCameraRollNode: SCNNode!
    fileprivate var leftCameraPitchNode: SCNNode!
    fileprivate var leftCameraYawNode: SCNNode!
    fileprivate var rightCameraRollNode: SCNNode!
    fileprivate var rightCameraPitchNode: SCNNode!
    fileprivate var rightCameraYawNode: SCNNode!

    fileprivate var videoNode: SKVideoNode?
    var playerNode: SCNNode?
    var player: AVPlayer?
    
    weak var delegate: JFVrPlayerLayerViewDelegate?
    
    var videoUrl: URL?
    var playerItem: AVPlayerItem?
    
    var timer: Timer?
    
    var isPlaying = false
    var isPlayToEnd = false
    var status: JFPlayerStatus = .unknown

//
//    func switchMode() {
//        
//        isVRMode = !isVRMode
//        
//        if isVRMode {
//            makeVR()
//        } else {
//            makeNormal()
//        }
//    }
//    
//    func makeVR() {
//        let width = UIScreen.main.bounds.width
//        let height = UIScreen.main.bounds.height
//        leftSceneView.frame = CGRect(x: 0, y: 0, width: width, height: height / 2)
//        rightSceneView.frame = CGRect(x: 0, y: height / 2, width: width, height: height / 2)
//        leftSceneView.alpha = 1.0
//        rightSceneView.alpha = 1.0
//    }
//    
//    func makeNormal() {
//        leftSceneView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
//        rightSceneView.alpha = 0.0
//    }
//    
//    func clickFullScreenButton(button: UIButton) {
//        fullScreenCallback?()
//    }
//    
//    func showInView(view: UIView) {
//        
//        view.addSubview(self)
//    }
//    
//    func stop() {
//        leftSceneView.isPlaying = false
//        rightSceneView.isPlaying = false
//        videoRenderNode.pause()
//        motionManager.stopGyroUpdates()
//    }
    

    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initScenes()
        initCameras()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initScenes()
        initCameras()
    }
    
    /// create sences
    func initScenes() {
        scene = SCNScene()

        leftSceneView = SCNView()
        addSubview(leftSceneView)

        rightSceneView = SCNView()
        addSubview(rightSceneView)

        leftSceneView.scene = scene
        rightSceneView.scene = scene
        
        leftSceneView.delegate = self
    }
    
    
    /// create cameras
    func initCameras() {
        
        let camX: Float = 0.0
        let camY: Float = 0.0
        let camZ: Float = 0.0
        let zFar = 700.0
        let xFov = 70.0
        let yFov = 70.0

        let leftCamera = SCNCamera()
        let rightCamera = SCNCamera()

        leftCamera.xFov = xFov
        leftCamera.yFov = yFov
        leftCamera.zFar = zFar
        rightCamera.xFov = xFov
        rightCamera.yFov = yFov
        rightCamera.zFar = zFar

        let leftCameraNode = SCNNode()
        leftCameraNode.camera = leftCamera
        leftCameraNode.position = SCNVector3(x: camX - 0.5, y: camY, z: camZ)

        let rightCameraNode = SCNNode()
        rightCameraNode.camera = rightCamera
        rightCameraNode.position = SCNVector3(x: camX + 0.5, y: camY, z: camZ)

        leftCameraNode.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(-90.0), 0, 0)
        rightCameraNode.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(-90.0), 0, 0)


        // create euler angles cameras
        leftCameraRollNode = SCNNode()
        leftCameraPitchNode = SCNNode()
        leftCameraYawNode = SCNNode()
        leftCameraRollNode.addChildNode(leftCameraNode)
        leftCameraPitchNode.addChildNode(leftCameraRollNode)
        leftCameraYawNode.addChildNode(leftCameraPitchNode)

        rightCameraRollNode = SCNNode()
        rightCameraPitchNode = SCNNode()
        rightCameraYawNode = SCNNode()
        rightCameraRollNode.addChildNode(rightCameraNode)
        rightCameraPitchNode.addChildNode(rightCameraRollNode)
        rightCameraYawNode.addChildNode(rightCameraPitchNode)
        
        scene.rootNode.addChildNode(leftCameraYawNode)
        
        leftSceneView.pointOfView = leftCameraNode
        rightSceneView.pointOfView = rightCameraNode
    }
    
    // MARK: - Configure
    
    func configurePlayer() {
        
        guard let url = videoUrl else {
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(playerTimerAction), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        // respond to user head movement. Refreshes the position of the camera 60 times per second.
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        

        playerItem = AVPlayerItem(url: url)
        player  = AVPlayer(playerItem: playerItem)
        videoNode = SKVideoNode(avPlayer: player!)

        let spriteKitScene = SKScene(size: CGSize(width: 2500, height: 2500))
        spriteKitScene.scaleMode = .aspectFit

        videoNode?.position = CGPoint(x: spriteKitScene.size.width / 2.0, y: spriteKitScene.size.height / 2.0)
        videoNode?.size = spriteKitScene.size
        spriteKitScene.addChild(videoNode!)

        playerNode = SCNNode()
        playerNode?.geometry = SCNSphere(radius: 30)
        playerNode?.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        playerNode?.geometry?.firstMaterial?.isDoubleSided = true
        scene.rootNode.addChildNode(playerNode!)

        // Flip video upside down, so that it's shown in the right position
        var transform = SCNMatrix4MakeRotation(Float(M_PI), 0.0, 0.0, 1.0)
        transform = SCNMatrix4Translate(transform, 1.0, 1.0, 0.0)

        playerNode?.pivot = SCNMatrix4MakeRotation(Float(M_PI_2), 0.0, -1.0, 0.0)
        playerNode?.geometry?.firstMaterial?.diffuse.contentsTransform = transform
        playerNode?.position = SCNVector3(x: 0, y: 0, z: 0)

        // the other way to flip viedo upside down
        //        playerNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(1,-1,1)
        //        playerNode.geometry?.firstMaterial?.diffuse.wrapT = .repeat
        
        // the other way to flip viedo upside down
        //        var transform = SCNMatrix4MakeRotation(Float(M_PI), 0.0, 0.0, 1.0)
        //        transform = SCNMatrix4Rotate(transform, Float(M_PI), 0, 1, 0)
        //        playerNode.transform = transform
    }
    
    func prepareToDeinit() {
        resetPlayer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        debugPrint("JFPlayerLayerView -- deinit")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        playerLayer?.frame = bounds
        leftSceneView.frame = CGRect(x: 0, y: 0, width: bounds.width / 2, height: bounds.height)
        rightSceneView.frame = CGRect(x: bounds.width / 2, y: 0, width: bounds.width / 2, height: bounds.height)
    }
    
    func updateUI() {
        setNeedsLayout()
    }
    
    // MARK: - Actions
    func play() {
        isPlaying = true
        leftSceneView.isPlaying = true
        rightSceneView.isPlaying = true
        videoNode?.play()
        timer?.fireDate = Date()
    }
    
    func pause() {
        videoNode?.pause()
        isPlaying = false
        leftSceneView.isPlaying = false
        rightSceneView.isPlaying = false
        timer?.fireDate = .distantFuture
    }
    
    func resetPlayer() {
        
        pause()
        
        playerItem = nil
        videoNode?.removeFromParent()
        videoNode = nil
        playerNode?.removeFromParentNode()
        playerNode = nil
        isPlayToEnd = true
        
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
            delegate?.vrPlayerLayerView(vrPlayerLayerView: self, trackTimeDidChange: currentTime, totalTime: totalTime)
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
        delegate?.vrPlayerLayerView(vrPlayerLayerView: self, statusDidChange: status)
    }
}

extension JFVrPlayerLayerView: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Render the scene
        
        DispatchQueue.main.async {
            if let mm = self.motionManager, let motion = mm.deviceMotion {
                
                let currentAttitude = motion.attitude
                
                var orientationMuliplier = 1.0
                if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight {
                    orientationMuliplier = -1.0
                }
                
                self.leftCameraRollNode.eulerAngles.z = Float(-currentAttitude.roll)
                self.rightCameraRollNode.eulerAngles.z = Float(-currentAttitude.roll)
                
                self.leftCameraPitchNode.eulerAngles.x = Float(currentAttitude.pitch)
                self.rightCameraPitchNode.eulerAngles.x = Float(currentAttitude.pitch)
                
                self.leftCameraYawNode.eulerAngles.y = Float(currentAttitude.yaw)
                self.rightCameraYawNode.eulerAngles.y = Float(currentAttitude.yaw)
            }
        }
    }
}
