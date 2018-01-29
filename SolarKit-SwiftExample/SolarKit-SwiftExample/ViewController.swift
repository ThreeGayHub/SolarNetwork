//
//  ViewController.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/3.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import UIKit

let network: SLNetwork = SLNetwork(target: GitHub())

let TestFiles: [String] = ["https://video.cdnvue.com/uploads/1746405174696532785/video/asBF81t",
                           "https://video.cdnvue.com/uploads/812734077666566393/video/ar9RkFL",
                           "http://cdnvue.com/video/rzGHzRA19L/64tBZo",
                           "https://video.cdnvue.com/uploads/-3518274263869595162/video/asBqjiJ",
                           "https://video.cdnvue.com/uploads/6921208716048356378/video/asCjvhf"]

class ViewController: UIViewController {

    @IBOutlet weak var downloadButton: UIButton!
        
    let downloadRequest = SLDownloadRequest(URLString: TestFiles[0])
    
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

