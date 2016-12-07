//
//  JFVrPlayerLayerView.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/17.
//  Copyright © 2016年 kankan. All rights reserved.
//

//http://stackoverflow.com/questions/29252418/how-to-play-360-video-on-the-ios-device

import UIKit
import QuartzCore
import SceneKit
import CoreMotion
import SpriteKit
import AVFoundation

class JFVrPlayerLayerView: UIView {
    
    weak var delegate: JFVrPlayerLayerViewDelegate?

    // Scene
    var leftSceneView: SCNView!
    var rightSceneView: SCNView!
    var scene: SCNScene!
    
    var motionManager: CMMotionManager!

    // Camera
    fileprivate var leftCameraNode: SCNNode!
    fileprivate var rightCameraNode: SCNNode!
    fileprivate var leftCameraRollNode: SCNNode!
    fileprivate var leftCameraPitchNode: SCNNode!
    fileprivate var leftCameraYawNode: SCNNode!
    fileprivate var rightCameraRollNode: SCNNode!
    fileprivate var rightCameraPitchNode: SCNNode!
    fileprivate var rightCameraYawNode: SCNNode!
    
    // Control Bar
    fileprivate var controlBar: JFVrPlayerControlBar!

    // Player
    var videoUrl: URL?
    var episodes: [JFPlayerItem]?
    fileprivate var playerItem: AVPlayerItem?
    fileprivate var videoNode: SKVideoNode?
    var playerNode: SCNNode?
    var player: AVPlayer?
    
    // Focus
    var leftFocus: UIImageView!
    var rightFocus: UIImageView!
    
    var timer: Timer?
    var focusDetectionTimer: Timer?
    
    // Boolean
    var isVrMode = true
    var isPlaying = false
    var isPlayToEnd = false
    var status: JFPlayerStatus = .unknown
    var isFullScreen = false
    var motionEnable = true
    var focusIsLoading = false
    
    fileprivate var pitchSum: Float = 0.0
    fileprivate var yawSum: Float = 0.0
    fileprivate var preHitNode: SCNNode?
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initScenes()
        initCameras()
        initFocus()
        initGesture()
        initControlBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initScenes()
        initCameras()
        initFocus()
        initGesture()
        initControlBar()
    }
    
    /// create sences
    func initScenes() {
        scene = SCNScene()

        leftSceneView = SCNView()
        leftSceneView.backgroundColor = UIColor.black
        addSubview(leftSceneView)

        rightSceneView = SCNView()
        rightSceneView.backgroundColor = UIColor.black
        addSubview(rightSceneView)

        leftSceneView.scene = scene
        rightSceneView.scene = scene
        
        leftSceneView.delegate = self
        leftSceneView.showsStatistics = true
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

        leftCameraNode = SCNNode()
        leftCameraNode.camera = leftCamera
        leftCameraNode.position = SCNVector3(x: camX - 0.5, y: camY, z: camZ)

        rightCameraNode = SCNNode()
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
        
        // respond to user head movement. Refreshes the position of the camera 60 times per second.
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical)
    }
    
    func initGesture() {
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
    }
    
    /// Create focal spot
    func initFocus() {
        
        leftFocus = UIImageView(image: JFImageResourcePath("vr_select/selecting-vr_00000"))
        leftFocus.alpha = 0.6
        
        
        rightFocus = UIImageView(image: JFImageResourcePath("vr_select/selecting-vr_00000"))
        rightFocus.alpha = 0.6
        
        insertSubview(leftFocus, at: 10)
        insertSubview(rightFocus, at: 10)
        
        // load animation
        var animationArray = [UIImage]()
        for i in 0..<60 {
            let image = JFImageResourcePath("vr_select/selecting-vr_000\(i.format("02"))")
            animationArray.append(image!)
        }
        
        leftFocus.animationImages = animationArray
        leftFocus.animationDuration = 1.5
        leftFocus.animationRepeatCount = .max
    }
    
    /// Create control bar
    func initControlBar() {
        controlBar = JFVrPlayerControlBar()
        scene.rootNode.addChildNode(controlBar!)
        controlBar.isHidden = true
    }
    
    deinit {
        debugPrint("JFPlayerLayerView -- deinit")
    }
    
    // MARK: - Configure
    
    func configurePlayer() {
        
        guard let url = videoUrl else {
            return
        }
        
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
        
        playerNode?.pivot = SCNMatrix4MakeRotation(Float(M_PI), 0.0, -1.0, 0.0)
        playerNode?.geometry?.firstMaterial?.diffuse.contentsTransform = transform
        playerNode?.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // the other way to flip viedo upside down
        //        playerNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(1,-1,1)
        //        playerNode.geometry?.firstMaterial?.diffuse.wrapT = .repeat
        
        // the other way to flip viedo upside down
        //        var transform = SCNMatrix4MakeRotation(Float(M_PI), 0.0, 0.0, 1.0)
        //        transform = SCNMatrix4Rotate(transform, Float(M_PI), 0, 1, 0)
        //        playerNode.transform = transform
        
        switchToNormalMode()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(playerTimerAction), userInfo: nil, repeats: true)
        focusDetectionTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(detectFocusCollision), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func prepareToDeinit() {
        motionManager.stopDeviceMotionUpdates()
        resetPlayer()
    }
    
    // MARK: - Public methods
    
    func showControlBar() {
        controlBar.isHidden = false
    }
    
    func hideControlBar() {
        controlBar.isHidden = true
    }
    
    func showEpisodes(episodes: [JFPlayerItem]) {
        
        guard self.episodes == nil else {
            return
        }
        
        self.episodes = episodes
        
        let distance = CGFloat(5)
        let position = SCNVector3(x: 0, y: 0, z: -5)
        let half = episodes.count / 2
        
        addReplayNode(width:  distance, height: distance * 9.0 / 16.0, position: position)
        
        for (idx, item) in episodes.enumerated() {
            
            if (idx >= half) {
                
                let rotation = SCNVector4Make(0, 1, 0, Float(M_PI_2 * 3 * Double(idx - half + 1) / Double(episodes.count)))
                addEpisodeItem(item: item, width: distance, height: distance * 9.0 / 16.0, position: position, rotation: rotation)
                
            } else {
                let position = SCNVector3(x: 0, y: 0, z: -5)
                let rotation = SCNVector4Make(0, 1, 0, -Float(M_PI_2 * 3 * Double(idx + 1) / Double(episodes.count)))
                addEpisodeItem(item: item, width: distance, height: distance * 9.0 / 16.0, position: position, rotation: rotation)
            }
        }
    }
    
    func detectFocusCollision() {
        
        let hits = leftSceneView.hitTest(leftFocus.center, options: nil)
        
        guard hits.count > 0  else {
            return
        }
        
        let result = hits[0]
        let node = result.node
        
        guard node.name != nil else {
            preHitNode = node
            return
        }
        
        guard preHitNode != node else {
            return
        }
        
        preHitNode = node
        
        // focus on episode
        // TODO: - change `for` to `Map` -
        if let episodes = episodes {
            for episode in episodes {
                if episode.title == node.name {
                    
                    startFocusLoading(callback: { [unowned self] in
                        self.delegate?.vrPlayerLayerView(vrPlayerLayerView: self, shouldPlayNextItem: episode)
                    })
                    break
                }
            }
        }
        
        // focus on control bar
        if node.name == "PlayorPauseButton" {
            startFocusLoading (callback: { [unowned self] in
                if self.isPlaying {
                    self.controlBar.updateUI(shouldPause: true)
                    self.pause()
                } else {
                    self.controlBar.updateUI(shouldPause: false)
                    self.play()
                }
            })
        }
    }
    
    func startFocusLoading(callback: (() -> Void)?) {
        if !focusIsLoading {
            
            leftFocus.startAnimating()
            rightFocus.startAnimating()
            focusIsLoading = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                
                self.leftFocus.stopAnimating()
                self.rightFocus.stopAnimating()
                self.focusIsLoading = false
                
                callback?()
            })
        }
    }
    
    // MARK: - Private Method
    
    fileprivate func addEpisodeItem(item: JFPlayerItem, width: CGFloat, height: CGFloat, position: SCNVector3, rotation: SCNVector4) {
        
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.diffuse.contents = UIImage(named: item.cover)
        plane.firstMaterial?.diffuse.wrapS = .clamp
        plane.firstMaterial?.diffuse.wrapT = .clamp
        plane.firstMaterial?.diffuse.mipFilter = .nearest
        plane.firstMaterial?.locksAmbientWithDiffuse = true
        plane.firstMaterial?.shininess = 0.0
        
        let node = SCNNode()
        node.physicsBody = SCNPhysicsBody.static()
        node.physicsBody?.restitution = 1.0
        node.geometry = plane
        node.position = position
        node.name = item.title
        
        let rotationNode = SCNNode()
        rotationNode.position = SCNVector3(x: 0, y: 0, z: 0)
        rotationNode.name = item.title
        scene.rootNode.addChildNode(rotationNode)
        rotationNode.addChildNode(node)
        
        let rotate = SCNAction.rotate(by: CGFloat(rotation.w), around: SCNVector3(x: 0, y: 1, z: 0), duration: 0.0)
        rotationNode.runAction(rotate)
    }
    
    fileprivate func addReplayNode(width: CGFloat, height: CGFloat, position: SCNVector3) {
        
        //        let skScene = SKScene(size: CGSize(width: width, height: height))
        //        skScene.backgroundColor = UIColor.yellow
        //
        //        let labelNode = SKLabelNode()
        //        labelNode.text = "重播"
        //        labelNode.color = UIColor.green
        //        labelNode.fontSize = 20
        //        labelNode.position = CGPoint(x: width / 2.0, y: height / 2.0)
        //
        //        skScene.addChild(labelNode)
        
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        layer.backgroundColor = UIColor.yellow.cgColor
        
        let textLayer = CATextLayer()
        textLayer.frame = layer.bounds
        textLayer.fontSize = layer.bounds.size.height
        textLayer.string = "重播"
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.foregroundColor = UIColor.green.cgColor
        textLayer.display()
        layer.addSublayer(textLayer)
        
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.diffuse.contents = layer
        plane.firstMaterial?.locksAmbientWithDiffuse = true
        plane.firstMaterial?.lightingModel = .constant
        
        let node = SCNNode()
        node.geometry = plane
        node.position = position
        node.name = "Replay"
        scene.rootNode.addChildNode(node)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isVrMode {
            leftSceneView.frame = CGRect(x: 0, y: 0, width: bounds.width / 2, height: bounds.height)
            rightSceneView.frame = CGRect(x: bounds.width / 2, y: 0, width: bounds.width / 2, height: bounds.height)
            leftFocus.frame = CGRect(x: bounds.width / 4 - 24, y: bounds.height / 2 - 24, width: 48, height: 48)
            rightFocus.frame = CGRect(x: bounds.width / 4 * 3 - 24, y: bounds.height / 2 - 24, width: 48, height: 48)
        } else  {
            leftSceneView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            leftFocus.frame = CGRect(x: bounds.width / 2 - 24, y: bounds.height / 2 - 24, width: 48, height: 48)
        }
    }
    
    func updateUI(isForFullScreen: Bool) {
        
        isFullScreen = isForFullScreen
        setNeedsLayout()
        
        // Flip video upside down, so that it's shown in the right position
        if (isFullScreen) {
            
            var transform = SCNMatrix4MakeRotation(Float(M_PI), 0.0, 0.0, 1.0)
            transform = SCNMatrix4Translate(transform, 1.0, 1.0, 0.0)
            
            playerNode?.pivot = SCNMatrix4MakeRotation(Float(M_PI_2), 0.0, 1.0, 0.0)
            playerNode?.geometry?.firstMaterial?.diffuse.contentsTransform = transform
            
        } else {
            var transform = SCNMatrix4MakeRotation(Float(M_PI), 0.0, 0.0, 1.0)
            transform = SCNMatrix4Translate(transform, 1.0, 1.0, 0.0)
            
            playerNode?.pivot = SCNMatrix4MakeRotation(Float(M_PI), 0.0, -1.0, 0.0)
            playerNode?.geometry?.firstMaterial?.diffuse.contentsTransform = transform
            
        }
    }
    
    func switchMode() {
        
        if isVrMode {
            switchToNormalMode()
        } else {
            switchToVrMode()
        }
    }
    
    func switchToVrMode() {
        isVrMode = true
        leftSceneView.alpha = 1.0
        rightSceneView.alpha = 1.0
        leftFocus.alpha = 1.0
        rightFocus.alpha = 1.0
        setNeedsLayout()
    }
    
    func switchToNormalMode() {
        isVrMode = false
        rightSceneView.alpha = 0.0
        rightFocus.alpha = 0.0
        setNeedsLayout()
    }
    
    // MARK: - Actions
    func play() {
        isPlaying = true
        leftSceneView.isPlaying = true
        rightSceneView.isPlaying = true
        videoNode?.play()
        player?.play()
        timer?.fireDate = Date()
    }
    
    func pause() {
        videoNode?.pause()
        player?.pause()
        isPlaying = false
        leftSceneView.isPlaying = false
        rightSceneView.isPlaying = false
        timer?.fireDate = .distantFuture
    }
    
    func resetPlayer() {
        
        pause()
        
        playerItem = nil
        player?.replaceCurrentItem(with: nil)
        player = nil
        videoNode?.removeFromParent()
        playerNode?.removeFromParentNode()
        playerNode = nil
        isPlayToEnd = true
        
        timer?.invalidate()
        timer = nil
        focusDetectionTimer?.invalidate()
        focusDetectionTimer = nil
        
        // remove episodes
        if let _ = episodes {
            for item in episodes! {
                let episodeNode = scene.rootNode.childNode(withName: item.title, recursively: false)
                episodeNode?.removeFromParentNode()
            }
            let replayNode = scene.rootNode.childNode(withName: "Replay", recursively: true)
            replayNode?.removeFromParentNode()
        }
        
        episodes?.removeAll()
        episodes = nil
        
        // remove notification observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
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
        pause()
        isPlayToEnd = true
        status = .playToEnd
        
        delegate?.vrPlayerLayerView(vrPlayerLayerView: self, statusDidChange: status)
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            motionEnable = false
            
        case .changed:
            motionEnable = false
            let yawDelta = Float(recognizer.translation(in: recognizer.view).x) / 100.0
            yawSum += yawDelta
            leftCameraYawNode.eulerAngles.y -= Float(yawDelta)
            rightCameraYawNode.eulerAngles.y -= Float(yawDelta)
            
            let pitchDelta = Float(recognizer.translation(in: recognizer.view).y) / 100.0
            pitchSum += pitchDelta
            leftCameraPitchNode.eulerAngles.x -= Float(pitchDelta)
            rightCameraPitchNode.eulerAngles.x -= Float(pitchDelta)
            
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
            
        default:
            motionEnable = true
        }
    }
}

extension JFVrPlayerLayerView: SCNSceneRendererDelegate {
    
    // Control motion
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if let mm = self.motionManager, let motion = mm.deviceMotion, motionEnable == true {
            DispatchQueue.main.async {
                
                let currentAttitude = motion.attitude

                if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight {
                    
                    self.leftCameraRollNode.eulerAngles.z = Float(-currentAttitude.pitch)
                    self.rightCameraRollNode.eulerAngles.z = Float(-currentAttitude.pitch)
                    
                    self.leftCameraPitchNode.eulerAngles.x = Float(-currentAttitude.roll)  - self.pitchSum
                    self.rightCameraPitchNode.eulerAngles.x = Float(-currentAttitude.roll)   - self.pitchSum
                    
                    self.leftCameraYawNode.eulerAngles.y = Float(currentAttitude.yaw) - self.yawSum
                    self.rightCameraYawNode.eulerAngles.y = Float(currentAttitude.yaw) - self.yawSum
                    
                } else {
                    
                    self.leftCameraRollNode.eulerAngles.z = Float(-currentAttitude.roll)
                    self.rightCameraRollNode.eulerAngles.z = Float(-currentAttitude.roll)
                    
                    self.leftCameraPitchNode.eulerAngles.x = Float(currentAttitude.pitch) - self.pitchSum
                    self.rightCameraPitchNode.eulerAngles.x = Float(currentAttitude.pitch) - self.pitchSum
                    
                    self.leftCameraYawNode.eulerAngles.y = Float(currentAttitude.yaw) - self.yawSum
                    self.rightCameraYawNode.eulerAngles.y = Float(currentAttitude.yaw) - self.yawSum
                }
                
                if self.leftCameraPitchNode.eulerAngles.x < GLKMathDegreesToRadians(45) {
                    self.showControlBar()
                } else {
                    self.hideControlBar()
                }
            }
        }
    }
}
