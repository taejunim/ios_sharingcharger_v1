//
//  PasswordChangeViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/11/19.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

class PasswordChangeViewController: UIViewController, UITextFieldDelegate {
    
    var activeTextField: UITextField?    //현재 포커싱인 textField
    @IBOutlet weak var currentPasswordTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var passwordConfirmTextField: CustomTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordInitCompleteButton: UIButton!
    
    let notificationCenter = NotificationCenter.default
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    let myUserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFieldDelegate()
        
        passwordInitCompleteButton.layer.cornerRadius = 7           //완료 버튼 둥글게
        passwordInitCompleteButton.addTarget(self, action: #selector(self.passwordInitComplete), for: .touchUpInside)
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        self.activityIndicator!.hidesWhenStopped = true
    }
    
    @objc func passwordInitComplete(sender: UIButton) {
        
        if myUserDefaults.string(forKey: "password")!.trimmingCharacters(in: .whitespacesAndNewlines) != currentPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.view.makeToast("현재 비밀번호가 일치하지 않습니다.", duration: 2.0, position: .bottom)
            return
        } else if passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != passwordConfirmTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.view.makeToast("새 비밀번호가 일치하지 않습니다.", duration: 2.0, position: .bottom)
            return
        } else {
            changePassword()
        }
    }
    
    private func changePassword() {
        
        self.activityIndicator!.startAnimating()
        
        var code: Int! = 0
        
        let userId = myUserDefaults.integer(forKey: "userId")
        let url = "http://211.253.37.97:8101/api/v1/change/password/\(userId)"
        
        print("url : \(url)")
        
        let parameters: Parameters = [
            "password" : passwordTextField.text!
        ]
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"], interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
            
            switch response.result {
            
            case .success(let obj):
                print(obj)
                
                self.activityIndicator!.stopAnimating()
                
                if code == 200 {
                    
                    self.view.makeToast("비밀번호가 변경되었습니다.", duration: 2.0, position: .bottom) {didTap in
                        
                        let loginViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "Main") as! MainViewController
                        let navigationController = UINavigationController(rootViewController: loginViewController)
                        
                        self.myUserDefaults.set(self.passwordTextField.text, forKey: "password")
                        
                        if didTap {
                            print("tap")
                            
                            UIApplication.shared.windows.first?.rootViewController = navigationController
                            UIApplication.shared.windows.first?.makeKeyAndVisible()
                        } else {
                            print("without tap")
                            
                            UIApplication.shared.windows.first?.rootViewController = navigationController
                            UIApplication.shared.windows.first?.makeKeyAndVisible()
                        }
                    }
                } else {
                    print("요청 파라미터가 올바르지 않습니다.\n다시 확인하여 주십시오.")
                    self.view.makeToast("요청 파라미터가 올바르지 않습니다.\n다시 확인하여 주십시오.", duration: 2.0, position: .bottom)
                }
                
            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("요청 파라미터가 올바르지 않습니다.\n다시 확인하여 주십시오.")
                    self.view.makeToast("요청 파라미터가 올바르지 않습니다.\n다시 확인하여 주십시오.", duration: 2.0, position: .bottom)
                    
                } else {
                    print("서버와 통신이 원활하지 않습니다. 고객센터로 문의주십시오. code : \(code!)")
                    self.view.makeToast("서버와 통신이 원활하지 않습니다.\n고객센터로 문의주십시오.", duration: 2.0, position: .bottom)
                }
                
                self.activityIndicator!.stopAnimating()
            }
        })
    }
    
    //textField delegate 설정
    func setTextFieldDelegate() {
        currentPasswordTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
    }
    
    //keyboard 설정
    func setKeyboard() {
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))   //뷰 터치시 키보드 내리기
        view.addGestureRecognizer(tap)
    }

    //다음 버튼 누르면 아래 텍스트 필드로 포커스 이동, 마지막 텍스트 필드에서 return 누르면 키보드 내려감
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let textFieldTag:Int = textField.tag

        if let textFieldNext = self.view.viewWithTag(textFieldTag + 1) as? UITextField {
            textFieldNext.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
    
   func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextField = textField
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {

        activeTextField = nil
    }
    
    @objc func keyboardWillHide(_ notification : Notification?) {
        
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillShow(_ notification : Notification?) {
        
        guard let keyboardFrame = (notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        // 활성화된 텍스트 필드가 키보드에 의해 가려진다면 가려지지 않도록 스크롤한다.
        // 이 부분은 상황에 따라 불필요할 수 있다.
        var rect = self.view.frame
        rect.size.height -= keyboardFrame.height
        if rect.contains(activeTextField!.frame.origin) {
            scrollView.scrollRectToVisible(activeTextField!.frame, animated: true)
        }
    }
    
    @objc func requestAuthentication(sender: UIButton!) {
        print("PasswordInitViewController - Button tapped")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        activeTextField = nil
        notificationCenter.removeObserver(self) //  self에 등록된 옵저버 전체 제거
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setKeyboard()
    }

}
