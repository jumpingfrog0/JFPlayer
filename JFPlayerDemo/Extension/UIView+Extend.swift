//
//  UIView+Extend.swift
//  JFPlayerDemo
//
//  Created by sheldon on 2016/11/16.
//  Copyright © 2016年 kankan. All rights reserved.
//

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
