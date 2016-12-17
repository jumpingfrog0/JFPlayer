//
//  Number+Extend.swift
//  SwiftExtension
//
//  Created by jumpingfrog0 on 01/12/2016.
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

import Foundation

extension Int {
    
    /// Format a number to string.
    ///     
    ///     let num = 10
    ///     let numStr = num.format("003")
    ///     print(numStr) // 010
    ///
    /// - Parameter format: Format (including number of components) of the attribute
    /// - Returns: A number String formatted.
    func format(_ format: String) -> String {
        return String(format: "%\(format)d", self)
    }
    
    /// Convert a number to string.
    func toString() -> String {
        return "\(self)"
    }
    
    /// Format seconds to human-readable time style string.
    func timeFormatted() -> String {
        let seconds = self % 60
        let minutes = (self / 60) % 60
        let hours = self / 3600
        
        if hours >= 100 {
            return String(format: "%03d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// Format seconds to human-readable string with time style except seconds.
    func timeFormattedExceptSeconds() -> String {
        _ = self % 60
        let minutes = (self / 60) % 60
        let hours = self / 3600
        
        if hours >= 100 {
            return String(format: "%03d:%02d", hours, minutes)
        } else {
            return String(format: "%02d:%02d", hours, minutes)
        }
    }
    
    /// Return the length of a number
    func length() -> Int {
        if self == 0 {
            return 1
        }
        return Int(log10(Double(self))) + 1
    }
}

extension Double {
    /// Format a number to string.
    ///
    ///     let num = 10.123456
    ///     let numStr = num.format(".3")
    ///     print(numStr) // 10.123
    ///
    /// - Parameter format: Format (including number of components) of the attribute
    /// - Returns: A number String formatted.
    func format(_ format: String) -> String {
        return String(format: "%\(format)f", self)
    }
    
    /// Convert a number to string.
    func toString() -> String {
        return "\(self)"
    }
}

extension Float {
    /// Format a number to string.
    ///
    ///     let num = 10.123456
    ///     let numStr = num.format(".3")
    ///     print(numStr) // 10.123
    ///
    /// - Parameter format: Format (including number of components) of the attribute
    /// - Returns: A number String formatted.
    func format(_ format: String) -> String {
        return String(format: "%\(format)f", self)
    }
    
    /// Convert a number to string.
    func toString() -> String {
        return "\(self)"
    }
}
