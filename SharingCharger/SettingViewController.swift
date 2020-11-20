//
//  SettingViewController.swift
//  SharingCharger
//
//  Created by chihong an on 2020/08/26.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var passwordChangeView: UIView!
    @IBOutlet weak var cardSettingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let passwordChangeGesture = UITapGestureRecognizer(target: self, action: #selector(self.passwordChange(_:)))
        passwordChangeView.isUserInteractionEnabled = true
        passwordChangeView.addGestureRecognizer(passwordChangeGesture)
    }
    
    @objc func passwordChange(_ sender: UITapGestureRecognizer) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordChange") as? PasswordChangeViewController else { return }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        print("logoutButton")
        UserDefaults.standard.set(false, forKey: "isLogin")
        UserDefaults.standard.set(0, forKey: "userId")
        UserDefaults.standard.set("", forKey: "name")
        UserDefaults.standard.set("", forKey: "email")
        UserDefaults.standard.set("", forKey: "password")
        
        let loginViewController = UIStoryboard(name:"Login", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
        let navigationController = UINavigationController(rootViewController: loginViewController)
        
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "설정"
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.title = ""
        super.viewWillDisappear(animated)
    }
}
