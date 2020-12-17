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
        
        let cardSettingGesture = UITapGestureRecognizer(target: self, action: #selector(self.cardSetting(_:)))
        cardSettingView.isUserInteractionEnabled = true
        cardSettingView.addGestureRecognizer(cardSettingGesture)
        
    }
    
    @objc func passwordChange(_ sender: UITapGestureRecognizer) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordChange") as? PasswordChangeViewController else { return }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func cardSetting(_ sender: UITapGestureRecognizer) {
       
        let dialog = UIAlertController(title:"", message : "서비스 준비중입니다.", preferredStyle: .alert)

        dialog.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default){
            
            (action:UIAlertAction) in
            self.dismiss(animated: true, completion: nil)

        })
        present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        print("logoutButton")
        
        let dialog = UIAlertController(title:"", message : "로그아웃 하시겠습니까?", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default ){
            
            (action:UIAlertAction) in
            
                UserDefaults.standard.set(false, forKey: "isLogin")
                UserDefaults.standard.set(0, forKey: "userId")
                UserDefaults.standard.set("", forKey: "name")
                UserDefaults.standard.set("", forKey: "email")
                UserDefaults.standard.set("", forKey: "password")
            
                let loginViewController = UIStoryboard(name:"Login", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
                let navigationController = UINavigationController(rootViewController: loginViewController)
            
                UIApplication.shared.windows.first?.rootViewController = navigationController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            
        })
        
        dialog.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.destructive){
            
            (action:UIAlertAction) in
                self.dismiss(animated: true, completion: nil)

        })

        present(dialog, animated: true, completion: nil)
        
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
