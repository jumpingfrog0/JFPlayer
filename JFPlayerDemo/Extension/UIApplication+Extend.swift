//
//  UIApplication+Extend.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/16.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit

extension UIApplication {
    
    func jf_usesViewControllerBasedStatusBarAppearance() -> Bool {
        let key = "UIViewControllerBasedStatusBarAppearance"
        guard  let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            return true
        }
        
        return (object as! Bool)
    }
    
    func jf_updateStatusBarAppearanceHidden(_ hidden: Bool, animation: UIStatusBarAnimation, fromViewController sender: UIViewController) {
        
        if jf_usesViewControllerBasedStatusBarAppearance() {
            sender.setNeedsStatusBarAppearanceUpdate()
        } else {
            if #available(iOS 9, *) {
                
                debugPrint("setStatusBarHidden:withAnimation: is deprecated. Please use view-controller-based status bar appearance.")
                
            } else {
                UIApplication.shared.setStatusBarHidden(hidden, with: animation)
            }
        }
    }
}
