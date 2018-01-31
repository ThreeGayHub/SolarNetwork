//
//  GitHubVC.swift
//  SolarKit-SwiftExample
//
//  Created by wyh on 2018/1/30.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import UIKit

private let GitHubTokenKey: String = "GitHubTokenKey"
//    d12e11ca90b5e30d55b1819e1c099c935b0d5f12
//        x-oauth-basic

class GitHubVC: UITableViewController {
    
    var userName: String?
    var password: String?
    
    var token: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        token = UserDefaults.standard.string(forKey: GitHubTokenKey)
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func userNameTextFieldDidEndEditing(_ sender: UITextField) {
        userName = sender.text
    }
    
    @IBAction func passwordTextFieldDidEndEditing(_ sender: UITextField) {
        password = sender.text
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        view.endEditing(true)
        
        let index = (indexPath.section, indexPath.row)
        switch index {
        case (0, 2):
            
            if let token = token, token.count > 0 {
                debugPrint("You have been sign in.")
            }
            else {
                if let userName = userName, let password = password {
                    
                    let signinRequest = GitHubSigninRequest()
                    signinRequest.basicAuthentication = (userName, password)
                    
                    GitHubNetwork.request(signinRequest) { [weak self] (response) in
                        guard let strongSelf = self else { return }
                        
                        if let model = response.decode(to: GitHubAuthenticationModel.self) {
                            
                            if model.token.count > 0 {
                                //You shouldn't actually do that.
                                strongSelf.token = model.token
                                UserDefaults.standard.set(model.token, forKey: GitHubTokenKey)
                                UserDefaults.standard.synchronize()
                                debugPrint("Sign in succeed.")
                            }
                            
                        }
                        
                    }
                }
            }
            
        case (0, 3):
            if let token = token, token.count > 0 {
                let myInfoRequest = GitHubMyInfoRequest()
                myInfoRequest.basicAuthentication = (token, "x-oauth-basic")
                
                GitHubNetwork.request(myInfoRequest) { (response) in
                    
                }
                
            }
            else {
                debugPrint("Please sign in.")
            }
            
        case (0, 4):
            if let token = token, token.count > 0 {
                let signoutRequest = GitHubSignoutRequest()
                signoutRequest.path = signoutRequest.path + token
                GitHubNetwork.request(signoutRequest) { [weak self] (response) in
                    guard let strongSelf = self else { return }

                    if response.httpURLResponse?.statusCode == 204 {
                        strongSelf.token = nil
                        UserDefaults.standard.removeObject(forKey: GitHubTokenKey)
                        UserDefaults.standard.synchronize()
                        debugPrint("Sign out succeed.")
                    }
                }
                
            }
            else {
                debugPrint("Please sign in.")
            }
            
        case (1, 0):
            GitHubNetwork.request(GitHubAPIRequest()) { (response) in
                
            }
            
        case (1, 1):
            GitHubNetwork.request(GitHubUserInfoRequest()) { (response) in
                
            }
            
        case (2, 0):
            GitHubNetwork.download(GitHubDownloadRequest(), progressClosure: { (progress) in
                
            }) { (response) in
                
            }
            
        case (2, 1):
            let downloadRequest = GitHubDownloadRequest()
            downloadRequest.isResume = true
            GitHubNetwork.download(downloadRequest, progressClosure: { (progress) in
                
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
