//
//  HTTPBinVC.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import UIKit

class HTTPBinVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let index = (indexPath.section, indexPath.row)
        
        switch index {
        case (0, 0):
            HTTPBinNetwork.request(HTTPBinGETRequest()) { (response) in
                
            }
            
        case (0, 1):
            HTTPBinNetwork.request(HTTPBinPOSTRequest()) { (response) in
                
            }
            
        case (0, 2):
            HTTPBinNetwork.request(HTTPBinPUTRequest()) { (response) in
                
            }
            
        case (0, 3):
            HTTPBinNetwork.request(HTTPBinDELETERequest()) { (response) in
                
            }
            
        case (0, 4):
            HTTPBinNetwork.request(HTTPBinPATCHRequest()) { (response) in
                
            }
            
        case (1, 0):
            HTTPBinNetwork.download(HTTPBinDownLoadRequest(), progressClosure: { (progress) in
                
            }) { (resposne) in
                
            }
            
        case (1, 1):
            let downloadRequest = HTTPBinDownLoadRequest()
            downloadRequest.isResume = true
            
            HTTPBinNetwork.download(downloadRequest, progressClosure: { (progress) in
                
            }) { (resposne) in
                
            }
            
        case (2, 0):
            let bundle = Bundle.main
            let resourcePath = bundle.path(forResource: "SLNetwork", ofType: "png")
            do {
                if let path = resourcePath {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    let uploadRequest = HTTPBinUploadRequest()
                    uploadRequest.data = data
                    HTTPBinNetwork.upload(uploadRequest, progressClosure: { (progress) in
                        
                    }) { (response) in
                        
                    }
                }
            }
            catch {
                debugPrint(error)
            }
            
        case (2, 1):
            let bundle = Bundle.main
            let resourcePath = bundle.path(forResource: "SLNetwork", ofType: "png")
            let uploadRequest = HTTPBinUploadRequest()
            uploadRequest.filePath = resourcePath
            HTTPBinNetwork.upload(uploadRequest, progressClosure: { (progress) in
                
            }) { (response) in
                
            }
            
        default: break
            
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
