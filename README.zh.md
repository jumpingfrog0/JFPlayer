# JFPlayer

一个模仿主流播放器（如爱奇艺、优酷等客户端）的Swift库，基于 `AVPlayer`, 支持普通视屏，正在支持360视频（目前效果还很差）。

## 特性

### 普通播放器
- [x] 支持横竖屏切换，自动旋转屏幕，横屏模式下锁定屏幕方向
- [x] 支持本地视频、网络视频播放
- [x] 左侧上下滑动调节屏幕亮度
- [x] 右侧上下滑动调节音量
- [x] 左右滑动调节播放进度
- [x] 切换视频清晰度

### VR播放器
- [x] 支持切换 普通/VR 模式
- [x] 支持手势左右上下拖动，手势缩放画面
- [x] 支持头控播放和暂停
- [x] 支持播放完后显示下一个播放菜单

## 要求
* iOS 8.0+
* Xcode 8.1+
* Swift 3.0+

## 交流
* Email: 447467113@qq.com 或 jumpingfrog0@gmail.com
* QQ: 447467113

## 安装

如果你没有安装[CocoadPods](https://cocoapods.org/)，请先安装好。

下载`JFPlayer`，把 `Source`文件夹拖入项目中，在 `Podfile` 中添加以下两个第三方依赖库：

	  pod 'NVActivityIndicatorView'
	  pod 'SnapKit'

安装依赖库：

	$ pod install
	
点击 `Run` 运行代码。

## 使用

### 普通播放器
#### 布局

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
    
#### 播放普通视屏

```swift
let url = URL(string: "http://gslb.miaopai.com/stream/kPzSuadRd2ipEo82jk9~sA__.mp4")
player.play(withUrl: url!, title: "至尊宝")
```
    
#### 播放多清晰度视屏

```swift
let resource0 = JFPlayerDefinitionItem(url: URL(string: "http://baobab.wdjcdn.com/1457162012752491010143.mp4")!, definitionName: "高清")
let resource1 = JFPlayerDefinitionItem(url: URL(string: "http://baobab.wdjcdn.com/1457529788412_5918_854x480.mp4")!, definitionName: "标清")
resourceItem = JFPlayerItem(title: "中国第一高楼", resources: [resource0, resource1], cover: "http://img.wdjimg.com/image/video/447f973848167ee5e44b67c8d4df9839_0_0.jpeg")
player.play(withItem: resourceItem)
```
    
#### 设置横屏锁屏

实现横屏锁屏功能，需要在控制器中添加以下代码，来控制屏幕是否自动旋转以及支持的方向。这个功能实现的不好，有待改进，哪位朋友有更好的实现方式，可以交流下 :)

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
    
如果你的根控制器是 `UINavigationController` 或 `UITabBarController`，还需要添加以下代码：

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

#### 设置状态栏

在 `Info.plist` 中添加 `View controller-based status bar appearance` 字段， 并改为 `YES`。

如果想要修改状态栏颜色以及一开始就隐藏状态栏，需要在控制器中添加一下代码。

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
    
在`ViewDidLoad`添加以下代码：

```swift
setNeedsStatusBarAppearanceUpdate()
```

### VR播放器

`JFVrPlayer`是基于`SceneKit`的，将视频内容渲染在一个球体内部的，但是会有画面抖动的问题，不知道是不是 `SceneKit`的性能问题，目前不知如何解决。

有两个想法：

* 把 `SceneKit` 换成 `OPGLES` 渲染，参考 [MD360Player4iOS](https://github.com/ashqal/MD360Player4iOS)
* 视频硬解后再渲染

这两个方法都比较难搞，需要花大量时间去学习才能解决😞

#### 播放360视频

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