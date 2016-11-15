//
//  BaseViewController.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/15.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
