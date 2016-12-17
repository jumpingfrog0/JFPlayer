//  JFPlayerButton.swift
//  JFPlayerDemo
//
//  Created by jumpingfrog0 on 15/12/2016.
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

class JFPlayerButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }
    
    func initUI() {
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        layer.cornerRadius = 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        setTitleColor(UIColor.white, for: .normal)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                setTitleColor(UIColor(red: 252.0 / 255.0, green: 13.0 / 255.0, blue: 27.0 / 255.0, alpha: 1.0), for: .normal)
                layer.borderColor = UIColor(red: 252.0 / 255.0, green: 13.0 / 255.0, blue: 27.0 / 255.0, alpha: 1.0).cgColor
            } else {
                setTitleColor(UIColor.white, for: .normal)
                layer.borderColor = UIColor.white.cgColor
            }
        }
    }
}
