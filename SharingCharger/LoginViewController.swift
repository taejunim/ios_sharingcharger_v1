//
//  LoginViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/07/27.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))   //뷰 터치시 키보드 내리기
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        print("Login Button")
        
        let mainViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "Main") as! MainViewController
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.navigationBar.isHidden = true
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    @IBAction func joinButton(_ sender: Any) {
        
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "Join") else { return }
        
        self.navigationController?.pushViewController(uvc, animated: true)
        
        //test
    }
    
    @IBAction func passwordInitButton(_ sender: Any) {
        
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "PasswordInit") else { return }
        
        self.navigationController?.pushViewController(uvc, animated: true)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "Setting") else { return }
        
        self.navigationController?.pushViewController(uvc, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        super.viewWillAppear(animated)
    }
}
