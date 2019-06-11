//
//  HTTPBinVC.swift
//  SolarKit-SwiftExample
//
//  Created by wyhazq on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import UIKit

class HTTPBinVC: UITableViewController {
    
    enum Section: Int {
        case Data
        case Download
        case Upload
        case Custom
    }
    
    enum DataRow: Int {
        case GET
        case POST
        case PUT
        case DELETE
        case PATCH
    }
    
    enum DownloadRow: Int {
        case Normal
        case Resume
    }
    
    enum UploadRow: Int {
        case Data
        case File
        case InputStrame
        case FormData
    }
    
    enum CustomRow: Int {
        case StringParameters
        case ArrayParameters
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let section = Section(rawValue: indexPath.section) else { return }
        

        switch section {
        case .Data:
            guard let row = DataRow(rawValue: indexPath.row) else { return }
            
            switch row {
            case .GET:
                HTTPBinNetwork.request(HTTPBinGETRequest()) { (response) in
                    
                }
                
            case .POST:
                let postReq = HTTPBinPOSTRequest()
                postReq.name = "yourName"
                HTTPBinNetwork.request(postReq) { (response) in
                    
                }
                
            case .PUT:
                HTTPBinNetwork.request(HTTPBinPUTRequest()) { (response) in
                    
                }
                
            case .DELETE:
                HTTPBinNetwork.request(HTTPBinDELETERequest()) { (response) in
                    
                }
                
            case .PATCH:
                HTTPBinNetwork.request(HTTPBinPATCHRequest()) { (response) in
                    
                }
                
            }
            
        case .Download:
            guard let row = DownloadRow(rawValue: indexPath.row) else { return }

            switch row {
            case .Normal:
                HTTPBinNetwork.download(HTTPBinDownLoadRequest(), progressClosure: { (progress) in
                    
                }) { (resposne) in
                    
                }
                
            case .Resume:
                let downloadRequest = HTTPBinDownLoadRequest()
                downloadRequest.isResume = true
                
                HTTPBinNetwork.download(downloadRequest, progressClosure: { (progress) in
                    
                }) { (resposne) in
                    
                }
                
            }
            
        case .Upload:
            guard let row = UploadRow(rawValue: indexPath.row) else { return }

            switch row {
            case .Data:
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
                
            case .File:
                let bundle = Bundle.main
                let resourcePath = bundle.path(forResource: "SLNetwork", ofType: "png")
                if let path = resourcePath {
                    let uploadRequest = HTTPBinUploadRequest()
                    uploadRequest.filePath = path
                    HTTPBinNetwork.upload(uploadRequest, progressClosure: { (progress) in
                        
                    }) { (response) in
                        
                    }
                }
                
            case .InputStrame:
                let bundle = Bundle.main
                let resourcePath = bundle.path(forResource: "SLNetwork", ofType: "png")
                do {
                    if let path = resourcePath {
                        let data = try Data(contentsOf: URL(fileURLWithPath: path))
                        let inputStream = InputStream(data: data)
                        
                        let uploadRequest = HTTPBinUploadRequest()
                        uploadRequest.inputStream = (inputStream, data.count)
                        HTTPBinNetwork.upload(uploadRequest, progressClosure: { (progress) in
                            
                        }) { (response) in
                            
                        }
                    }
                }
                catch {
                    debugPrint(error)
                }
                
            case .FormData:
                let bundle = Bundle.main
                let resourcePath = bundle.path(forResource: "SLNetwork", ofType: "png")
                if let path = resourcePath {
                    let uploadRequest = HTTPBinUploadRequest()
                    uploadRequest.multipartFormDataClosure { (multipartFormData) in
                        let url = URL(fileURLWithPath: path)
                        multipartFormData.append(url, withName: "SLNetwork")
                    }
                    
                    HTTPBinNetwork.upload(uploadRequest, progressClosure: { (progress) in
                        
                    }) { (response) in
                        
                    }
                }
                
            }
            
        case .Custom:
            guard let row = CustomRow(rawValue: indexPath.row) else { return }
            
            switch row {
                
            case .StringParameters:
                
                HTTPBinNetwork.request(HTTPBinStringParametersRequest()) { (response) in
                    
                }
                                
            case .ArrayParameters: 
                
                HTTPBinNetwork.request(HTTPBinArrayParametersRequest()) { (response) in
                
                }
                
            }
        
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


