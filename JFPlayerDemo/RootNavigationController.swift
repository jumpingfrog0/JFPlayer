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
        return topViewController!.shouldAutorotate
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController!.supportedInterfaceOrientations
    }
}
