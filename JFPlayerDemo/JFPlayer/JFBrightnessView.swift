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

class JFBrightnessView: UIView {
    
    static let shared = JFBrightnessView()
    
    private var longView: UIView!
    private var nodes: [UIImageView]!
    private var backgroundImageView: UIImageView!
    
    init() {
        super.init(frame: CGRect.zero)
        
        frame = CGRect(x: 0, y: 0, width: 155, height: 155)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        // Use UIToolbar to implement blur effect( Easy but Rude !!!)
        let toolbar = UIToolbar(frame: bounds)
        toolbar.alpha = 0.97
        addSubview(toolbar)
        
        backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 79, height: 76))
        backgroundImageView.image = JFImageResourcePath("JFPlayer_brightness")
        addSubview(backgroundImageView)
        
        let titleLable = UILabel(frame: CGRect(x: 0, y: 5, width: bounds.width, height: 30))
        titleLable.font = UIFont.boldSystemFont(ofSize: 16)
        titleLable.textColor = UIColor(red: 0.25, green: 0.22, blue: 0.21, alpha: 1.0)
        titleLable.textAlignment = .center
        titleLable.text = "亮度"
        addSubview(titleLable)
        
        longView = UIView(frame: CGRect(x: 13, y: 132, width: bounds.width - 26, height: 7))
        longView.backgroundColor = UIColor(red: 0.25, green: 0.22, blue: 0.21, alpha: 1.0)
        addSubview(longView)
        
        createNodes()
        addObserver()
        
        alpha = 0.0
        
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // create brightness nodes
    func createNodes() {
        
        nodes = [UIImageView]()
        let w = (longView.bounds.width - 17) / 16
        let h = CGFloat(5)
        let y = CGFloat(1)
        
        for i in 0 ..< 16 {
            let x = CGFloat(i) * (w + 1) + 1
            let view = UIImageView()
            view.backgroundColor =  UIColor.white
            view.frame = CGRect(x: x, y: y, width: w, height: h)
            longView.addSubview(view)
            nodes.append(view)
        }
        
        updateBrightness(UIScreen.main.brightness)
    }
    
    func addObserver() {
        UIScreen.main.addObserver(self, forKeyPath: "brightness", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func updateBrightness(_ brightness: CGFloat) {
        
        let stage = CGFloat(1.0 / 16.0)
        let level = Int(brightness / stage)
        
        for i in 0 ..< nodes.count {
            let node = nodes[i]
            
            if brightness == 0 {
                node.isHidden = true
            } else {
            
                if i <= level {
                    node.isHidden = false
                } else {
                    node.isHidden = true
                }
            }
        }
    }
    
    func orientationDidChange() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let value = change?[.newKey] as? CGFloat {
            appearBrightnessView()
            updateBrightness(value)
        }
    }
    
    func appearBrightnessView() {
        if alpha == 0.0 {
            alpha = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                self.disappearBrightnessView()
            })
        }
    }
    
    func disappearBrightnessView() {
        if alpha == 1.0 {
            UIView.animate(withDuration: 0.8, animations: { 
                self.alpha = 0.0
            })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundImageView.center = CGPoint(x: bounds.width * 0.5, y: 155 * 0.5)
        center = CGPoint(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.5)
    }
    
    deinit {
        UIScreen.main.removeObserver(self, forKeyPath: "brightness")
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
}
