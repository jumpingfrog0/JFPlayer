//
//  VideoPlayViewController.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/14.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit
import SnapKit

class VideoPlayViewController: UIViewController {
    
    var player: JFPlayer!
    var resourceItem: JFPlayerItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        preparePlayer()
        playSingleResource()
//        prepareResourceItem()
//        player.play(withItem: resourceItem)
    }

    func preparePlayer() {
        player = JFPlayer()
        view.addSubview(player)
        
        // push入这个控制器的上一个控制器必须只支持竖屏，不然在手机横着时，push入这个控制器时视频的尺寸有问题。
        player.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(view.snp.width).multipliedBy(UIScreen.main.bounds.width/UIScreen.main.bounds.height)
//            make.height.equalTo(view.snp.width).multipliedBy(9.0/16.0)
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
    
    func playSingleResource() {
        let url = URL(string: "http://gslb.miaopai.com/stream/kPzSuadRd2ipEo82jk9~sA__.mp4")
//        let url = URL(string: "http://baobab.wdjcdn.com/14571455324031.mp4")
//        let url = URL(string: "http://baobab.wdjcdn.com/1457529788412_5918_854x480.mp4")
        player.play(withUrl: url!, title: "至尊宝")
    }
    
    func prepareResourceItem() {
        let resource0 = JFPlayerDefinitionItem(url: URL(string: "http://baobab.wdjcdn.com/1457162012752491010143.mp4")!, definitionName: "高清")
        let resource1 = JFPlayerDefinitionItem(url: URL(string: "http://baobab.wdjcdn.com/1457529788412_5918_854x480.mp4")!, definitionName: "标清")
        resourceItem = JFPlayerItem(title: "中国第一高楼", resources: [resource0, resource1], cover: "http://img.wdjimg.com/image/video/447f973848167ee5e44b67c8d4df9839_0_0.jpeg")
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
}
