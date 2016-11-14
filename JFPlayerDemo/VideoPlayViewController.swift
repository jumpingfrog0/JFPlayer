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
        
        player.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
//            make.height.equalTo(view.snp.width).multipliedBy(9.0/16.0)
            make.height.equalTo(100)
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
    }
    
    func playResource() {
        let url = URL(string: "http://gslb.miaopai.com/stream/kPzSuadRd2ipEo82jk9~sA__.mp4")
        player.playWithUrl(url!, title: "至尊宝")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        UIApplication.shared.setStatusBarStyle(.default, animated: false)
    }
}
