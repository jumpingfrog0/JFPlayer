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

    override func viewDidLoad() {
        super.viewDidLoad()

        preparePlayer()
        playResource()
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
    
    func playResource() {
//        let url = URL(string: "http://gslb.miaopai.com/stream/kPzSuadRd2ipEo82jk9~sA__.mp4")
//        let url = URL(string: "http://baobab.wdjcdn.com/14571455324031.mp4")
        let url = URL(string: "http://baobab.wdjcdn.com/1457529788412_5918_854x480.mp4")
        player.playWithUrl(url!, title: "至尊宝")
        
        
//         let url = URL(string: "http://player.hunantv.com/mgtv_v5_main/main.swf?js_function_name=vjjFlash&video_id=3734000")
//        player.playWithUrl(url!, title: "爸爸去哪儿")
        
//        let url = URL(string: "https://www.youtube.com/embed/jL0SZ71rhak")
//        player.playWithUrl(url!, title: "街舞")
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
