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

class VRPlayerViewController: UIViewController {

    var player: JFVrPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preparePlayer()
        playResource()
    }
    
    func preparePlayer() {
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
        
        let bottomView = UIView()
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.top.equalTo(player.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(100)
        }
        bottomView.backgroundColor = UIColor.orange
        
        let leftLabel = UILabel()
        leftLabel.text = "左边"
        leftLabel.frame = CGRect(x: 10, y: 10, width: 40, height: 20)
        bottomView.addSubview(leftLabel)
        
        let rightLabel = UILabel()
        rightLabel.text = "右边"
        rightLabel.frame = CGRect(x: 250, y: 10, width: 40, height: 20)
        bottomView.addSubview(rightLabel)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func playResource() {
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        guard let hidden = player?.statusBarIsHidden else {
            return false
        }
        return hidden
    }

}
