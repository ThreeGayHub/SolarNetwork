//
//  ViewController.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/3.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import UIKit

let network: SLNetwork = SLNetwork(target: GitHub())

class ViewController: UIViewController {

    @IBOutlet weak var downloadButton: UIButton!
    
    //the md5 of sublimeText.dmp is 2426906d22302cd8742162d3b0e154e9
    let downloadRequest = SLDownloadRequest(URLString: "https://download.sublimetext.com/Sublime%20Text%20Build%203143.dmg")
    
    //http://cdnvue.com/video/rzGHzRA19L/64tBZo
    
    var isDownlonding: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func downloadButtonAction(_ sender: UIButton) {
        
        if isDownlonding {
            isDownlonding = false
            downloadRequest.cancel()
            sender.setTitle("Download", for: .normal)
        }
        else {
            isDownlonding = true
            downloadRequest.isResume = true
            network.download(downloadRequest, progressClosure: { (progress) in
                sender.setTitle(progress.currentProgressString, for: .normal)
            }, completionClosure: { (response) in
                
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

