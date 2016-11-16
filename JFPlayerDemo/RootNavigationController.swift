//
//  RootNavigationController.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/15.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit

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
