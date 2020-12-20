//
//  PasswordInitViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/19.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

class PasswordInitViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: CustomTextField!
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var autorizationCodeTextField: CustomTextField!
    
    @IBOutlet weak var passwordInitButton: UIButton!    //비밀번호 초기화 버튼
    
    var activeTextField: UITextField?    //현재 포커싱인 textField
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let notificationCenter = NotificationCenter.default
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    var authenticationNumber: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setKeyboard()
        setTextFieldDelegate()
        
        //emailTextField.setCurrentType(type: 1, target: self)   //이메일 필드에 인증요청 버튼 추가
        
        passwordInitButton.layer.cornerRadius = 7           //완료 버튼 둥글게
        passwordInitButton.addTarget(self, action: #selector(self.passwordInit), for: .touchUpInside)
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        self.activityIndicator!.hidesWhenStopped = true
        
        addAuthenticationButton()
    }
    
    //인증 요청 버튼 추가
    private func addAuthenticationButton() {

        let authenticationButton = UIButton()
        
        let Color_7F7F7F = UIColor(named: "Color_3498DB")
        authenticationButton.backgroundColor = Color_7F7F7F
        authenticationButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(15))
        authenticationButton.setTitle("인증 요청", for: .normal)

        self.view.addSubview(authenticationButton)
        
        authenticationButton.translatesAutoresizingMaskIntoConstraints = false
        authenticationButton.centerYAnchor.constraint(equalTo: phoneTextField.centerYAnchor).isActive = true
        authenticationButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        authenticationButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        authenticationButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -25).isActive = true
        
        authenticationButton.addTarget(self, action: #selector(self.requestAuthentication), for: .touchUpInside)
    }
    
    @objc func passwordInit(sender: UIButton) {
        
        if checkBlank() {
            guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordInitComplete") as? PasswordInitCompleteViewController else { return }
            viewController.userId = emailTextField.text!
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    //textField delegate 설정
    func setTextFieldDelegate() {
        nameTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        autorizationCodeTextField.delegate = self
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
        
        if phoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("전화번호를 입력하여주십시오", duration: 2.0, position: .bottom)
            
        } else {
            self.activityIndicator!.startAnimating()
            
            var code: Int! = 0
            
            let phoneNumber = phoneTextField.text
            let url = "http://211.253.37.97:8101/api/v1/sms/\(phoneNumber!)"
            
            print("url : \(url)")
            
            AF.request(url, method: .get, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
                
                code = response.response?.statusCode
                
                switch response.result {
                
                case .success(let obj):
                    
                    self.activityIndicator!.stopAnimating()
                    
                    if code == 200 {
                        
                        self.authenticationNumber = (obj as! Int)
                        self.autorizationCodeTextField.becomeFirstResponder()
                    }
                    
                case .failure(let err):
                    
                    print("error is \(String(describing: err))")
                    
                    if code == 400 {
                        print("Unknown Error")
                        
                    } else {
                        print("Unknown Error")
                    }
                    
                    self.activityIndicator!.stopAnimating()
                }
            })
        }
    }
    
    //빈칸 체크
    private func checkBlank() -> Bool{
        
        if nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("이름을 입력하여주십시오", duration: 2.0, position: .bottom)
            return false
        } else if emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("이메일을 입력하여주십시오", duration: 2.0, position: .bottom)
            return false
        } else if phoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("전화번호를 입력하여주십시오", duration: 2.0, position: .bottom)
            return false
        } else if autorizationCodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("인증번호를 입력하여주십시오", duration: 2.0, position: .bottom)
            return false
        } else if authenticationNumber == nil {
            self.view.makeToast("인증 요청 버튼을 클릭해주십시오.", duration: 2.0, position: .bottom)
            return false
        } else if autorizationCodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != String(authenticationNumber) {
            self.view.makeToast("인증번호가 일치하지 않습니다.", duration: 2.0, position: .bottom)
            return false
        }
        
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "비밀번호 변경"
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.title = ""
        super.viewWillDisappear(animated)
        
        activeTextField = nil
        notificationCenter.removeObserver(self) //  self에 등록된 옵저버 전체 제거
    }
}
