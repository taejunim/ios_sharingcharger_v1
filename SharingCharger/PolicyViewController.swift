//
//  UserCertificationViewController.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/12/10.
//  Copyright © 2020 metisinfo. All rights reserved.
//
import WebKit

protocol PolicyProtocol {
    func policyDelegate(data: String)
}
class PolicyViewController : UIViewController , WKUIDelegate, WKNavigationDelegate{
    
    @IBOutlet var policyWebView: WKWebView!
    @IBOutlet var confirmButton: UIButton!
    
    var delegate: PolicyProtocol?
    var url = ""

    override func viewDidLoad() {
        
        super.viewDidLoad()
        initialize()
    }

    func initialize(){
    
        self.delegate = JoinViewController()
        let userUrl = URL(string: url)
        let request = URLRequest(url: userUrl!)
        self.policyWebView.load(request)
        
        confirmButton.addTarget(self, action: #selector(confirmButton(sender:)), for: .touchUpInside)

    }
    
    @objc func confirmButton(sender: UIButton!) {
        

        delegate?.policyDelegate(data: url)
        self.dismiss(animated: true, completion: nil)
    }
}
