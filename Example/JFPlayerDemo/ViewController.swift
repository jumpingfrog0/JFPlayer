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

class ViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var titles: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        titles = [
            "Play with single url",
            "Play with multiple definition videos",
            "VR Player",
        ]
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let vc = VideoPlayViewController.instantiate(fromStoryboard: "Main")
            vc.isSingle = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.row == 1 {
            
            let vc = VideoPlayViewController.instantiate(fromStoryboard: "Main")
            vc.isSingle = false
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            
            let vc = VRPlayerViewController.instantiate(fromStoryboard: "Main")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JFPlayerCell")
        cell?.textLabel?.text = titles[indexPath.row]
        return cell!
    }
}

