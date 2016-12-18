# JFPlayer

A library that mimics the mainstream video players writting in Swift, based on `AVPlayer`, support normal video, supporting 360 degree video(The effect is still poor currently).

[中文文档](https://github.com/jumpingfrog0/JFPlayer/blob/master/README.zh.md)

## Features

### Normal player
- [x] Support for vertical and horizontal screen switch, rotate screen automatically, lock screen direction in horizontal mode
- [x] Support local video and network video playback
- [x] Slide up or down the left side to adjust brightness
- [x] Slide up or down the right side to adjust volume
- [x] Slide left or right the screen to adjust playback progress 
- [x] Switch video definition

## Requirements
* iOS 8.0+
* Xcode 8.1+
* Swift 3.0+

## Communication
* Email: 447467113@qq.com  or  jumpingfrog0@gmail.com
* QQ: 447467113

## Installation

Please install [CocoadPods](https://cocoapods.org/) firstly.

Download `JFPlayer` and drag `Source` folder into your project, then add two dependencies within `Podfile` as below:

	pod 'NVActivityIndicatorView'
	pod 'SnapKit'
	
Install dependencies:

	$ pod install
	
Click `Run` button for running code.

## Usage

### Normal player
#### Layout

```swift
player = JFPlayer()
view.addSubview(player)
    
// push入这个控制器的上一个控制器必须只支持竖屏，不然在手机横着时，push入这个控制器时视频的尺寸有问题。
player.snp.makeConstraints { (make) in
    make.top.equalTo(view.snp.top)
    make.left.equalTo(view.snp.left)
    make.right.equalTo(view.snp.right)
    make.height.equalTo(view.snp.width).multipliedBy(UIScreen.main.bounds.width/UIScreen.main.bounds.height)
	// 宽高比也可以为 16:9
	// make.height.equalTo(view.snp.width).multipliedBy(9.0/16.0)
}
    
player.backClosure = { [unowned self] in
    let _ = self.navigationController?.popViewController(animated: true)
}
```

#### Play normal video

```swift
let url = URL(string: "http://gslb.miaopai.com/stream/kPzSuadRd2ipEo82jk9~sA__.mp4")
player.play(withUrl: url!, title: "至尊宝")
```

#### Play multiple definitions video

```swift
let resource0 = JFPlayerDefinitionItem(url: URL(string: "http://baobab.wdjcdn.com/1457162012752491010143.mp4")!, definitionName: "高清")
let resource1 = JFPlayerDefinitionItem(url: URL(string: "http://baobab.wdjcdn.com/1457529788412_5918_854x480.mp4")!, definitionName: "标清")
resourceItem = JFPlayerItem(title: "中国第一高楼", resources: [resource0, resource1], cover: "http://img.wdjimg.com/image/video/447f973848167ee5e44b67c8d4df9839_0_0.jpeg")
player.play(withItem: resourceItem)
```

#### Lock screen in horizontal mode

To archive lock screen in horizontal mode, should add below code in controller.
I wrote some bad code room for improvement, if you have the other better way to implement this function, wish you communicating with me.

```swift
override var shouldAutorotate: Bool {
    return true
}
    
override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if player.isLocked {
        return .landscape
    } else {
        return .all
    }
}
```

You should add some extra code as below if your root controller is `UINavigationController` or `UITabBarController`:

```swift
class RootNavigationController: UINavigationController {

    override var shouldAutorotate: Bool {
        guard let topViewController = topViewController else {
            return true
        }
        
        return topViewController.shouldAutorotate
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let topViewController = topViewController else {
            return .all
        }
        return topViewController.supportedInterfaceOrientations
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let topViewController = topViewController else {
            return .default
        }
        return topViewController.preferredStatusBarStyle
    }
}
```

#### Setting status bar

Please add `View controller-based status bar appearance` field in `Info.plist`, and change it to `YES`.

If you want to change the color of status bar, and hide the status bar at the beginning, please add the code int controller as below:

```swift
override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
}
    
override var prefersStatusBarHidden: Bool {
    guard let hidden = player?.statusBarIsHidden else {
        return false
    }
    return hidden
}
```

and then add code at `viewDidLoad` method:

```swift
setNeedsStatusBarAppearanceUpdate()
```

### VR player

`JFVrPlayer` is based on `SceneKit`, it render the video content inside the sphere. But it occur to a problem that video screen jitter seriously, I have no idea whether the performance of `SceneKit` result in and I don't know how to solve it.

I have two ideas:

* change `SceneKit` to `OPGLES` for render, refer to [MD360Player4iOS](https://github.com/ashqal/MD360Player4iOS)
* render video content after hardware accelerate

These methods above mentioned need spend too much time to study the knowledge.

#### Play 360 video

```swift
player = JFVrPlayer()
view.addSubview(player)
    
// push入这个控制器的上一个控制器必须只支持竖屏，不然在手机横着时，push入这个控制器时视频的尺寸有问题。
player.snp.makeConstraints { (make) in
    make.top.equalTo(view.snp.top)
    make.left.equalTo(view.snp.left)
    make.right.equalTo(view.snp.right)
    make.height.equalTo(view.snp.width).multipliedBy(UIScreen.main.bounds.width/UIScreen.main.bounds.height)
}
    
player.backClosure = { [unowned self] in
    let _ = self.navigationController?.popViewController(animated: true)
}
    
let resource0 = JFPlayerDefinitionItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: "Aerial_photography", ofType: "mp4")!), definitionName: "高清")
let resource1 = JFPlayerDefinitionItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: "demo", ofType: "m4v")!), definitionName: "高清")
let resource2 = JFPlayerDefinitionItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: "Aerial_photography", ofType: "mp4")!), definitionName: "高清")
let resource3 = JFPlayerDefinitionItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: "Aerial_photography", ofType: "mp4")!), definitionName: "高清")
var episodes = [JFPlayerItem]()
episodes.append(JFPlayerItem(title: "manhuangji", resources: [resource0], cover: "manhuangji"))
episodes.append(JFPlayerItem(title: "One Piece", resources: [resource1], cover: "onepiece"))
episodes.append(JFPlayerItem(title: "ciyuan", resources: [resource2], cover: "ciyuan"))
episodes.append(JFPlayerItem(title: "zhenhunjie", resources: [resource3], cover: "zhenhunjie"))
    
let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Aerial_photography", ofType: "mp4")!)
player.episodes = episodes
player.playWithUrl(url, title: "全景视频")
```