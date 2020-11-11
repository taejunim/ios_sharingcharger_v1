//  회원가입 화면
//  JoinViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/10.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

class JoinViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: CustomTextField!              //이름 textField
    @IBOutlet weak var phoneTextField: CustomTextField!             //전화 번호 textField
    @IBOutlet weak var emailTextField: CustomTextField!             //이메일 textField
    @IBOutlet weak var autorizationCodeTextField: CustomTextField!  //인증번호 textField
    @IBOutlet weak var passwordTextField: CustomTextField!          //패스워드 textField
    @IBOutlet weak var passwordConfirmTextField: CustomTextField!   //패스워드 확인 textField
    
    @IBOutlet weak var buttonComplete: UIButton!                    //완료 버튼
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeTextField: UITextField?   //현재 포커싱인 textField
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFieldDelegate()
        setKeyboard()
        
        emailTextField.setCurrentType(type: 1, target: self)   //이메일 필드에 인증요청 버튼 추가
        
        buttonComplete.layer.cornerRadius = 7           //완료 버튼 둥글게
        buttonComplete.addTarget(self, action: #selector(joinButton), for: .touchUpInside)
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        self.activityIndicator!.hidesWhenStopped = true
    }
    
    @objc func joinButton(sender: UIButton!) {
        
        if checkBlank() {
        
            var code: Int! = 0
            
            let url = "http://211.253.37.97:8101/api/v1/join"
            
            let parameters: Parameters = [
                "name": nameTextField.text!,
                "phone": phoneTextField.text!,
                "email": emailTextField.text!,
                "password": passwordTextField.text!,
                "userType":"General",
                "collectUserDataFlag":true,
                "privacyPolicyFlag":true
            ]
            
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
                
                code = response.response?.statusCode
                
                switch response.result {
                
                case .success(let obj):
                    
                    print("obj : \(obj)")
                    
                    do {
                        
                        let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        
                        let instanceData = try JSONDecoder().decode(JoinObject.self, from: JSONData)
                        
                        self.view.makeToast("회원가입이 완료되어 로그인 페이지으로 이동합니다.", duration: 2.0, position: .bottom) {didTap in
                            if didTap {
                                print("tap")
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                print("without tap")
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                    } catch {
                        print("error : \(error.localizedDescription)")
                        print("서버와 통신이 원활하지 않습니다. 고객센터로 문의주십시오. code : \(code!)")
                    }
                    
                case .failure(let err):
                    
                    print("error is \(String(describing: err))")
                    
                    if code == 400 {
                        print("중복된 이메일이 존재합니다. 다른 이메일로 가입하여 주십시오.")
                        self.view.makeToast("중복된 이메일이 존재합니다.\n다른 이메일로 가입하여 주십시오.", duration: 2.0, position: .bottom)

                    } else {
                        print("서버와 통신이 원활하지 않습니다. 고객센터로 문의주십시오. code : \(code!)")
                        self.view.makeToast("서버와 통신이 원활하지 않습니다.\n고객센터로 문의주십시오.", duration: 2.0, position: .bottom)
                    }
                }
                
                self.activityIndicator!.stopAnimating()
            })
        }
    }
    
    //빈칸 체크
    private func checkBlank() -> Bool{
        
        if nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("이름을 입력하여주십시오", duration: 2.0, position: .bottom)
            return false
        } else if phoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("전화번호를 입력하여주십시오", duration: 2.0, position: .bottom)
            return false
        } else if emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("이메일을 입력하여주십시오", duration: 2.0, position: .bottom)
            return false
        } else if autorizationCodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("인증번호를 입력하여주십시오", duration: 2.0, position: .bottom)
            return false
        } else if passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("비밀번호를 입력하여주십시오", duration: 2.0, position: .bottom)
            return false
        } else if passwordConfirmTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("비밀번호 확인을 입력하여주십시오", duration: 2.0, position: .bottom)
            return false
        } else if passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != passwordConfirmTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.view.makeToast("비밀번호가 일치하지 않습니다.", duration: 2.0, position: .bottom)
            return false
        }
        
        return true
    }
    
    //textField delegate 설정
    func setTextFieldDelegate() {
        nameTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        autorizationCodeTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
    }
    
    //keyboard 설정
    func setKeyboard() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
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
    
    @objc func requestAuthentication(sender: UIButton!) {
        print("JoinViewController - Button tapped")
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
}
