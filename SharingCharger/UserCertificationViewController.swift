//
//  UserCertificationViewController.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/11/22.
//  Copyright © 2020 metisinfo. All rights reserved.
//
import WebKit

class UserCertificationViewController : UIViewController , WKUIDelegate, WKNavigationDelegate{
    
    @IBOutlet var userCertificationWebView: WKWebView!
    
    let url = "http://101.101.219.230/"
    let myUserDefaults = UserDefaults.standard
    
    override func loadView() {
        userCertificationWebView = WKWebView()
        userCertificationWebView.navigationDelegate = self
        view = userCertificationWebView
    }
    
    override func viewDidLoad() {
        
        print("UserCertificationViewController - viewDidLoad")
        
        super.viewDidLoad()
        initialize()
    }

    func initialize(){
    
        let userUrl = URL(string: url + myUserDefaults.string(forKey: "email")!)
        let request = URLRequest(url: userUrl!)
        self.userCertificationWebView.load(request)

    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("webView didFinish")

        let css = ".bcaJjD { width : 100% }"
        let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"

        userCertificationWebView.evaluateJavaScript(js, completionHandler: nil)

    }
    
}
