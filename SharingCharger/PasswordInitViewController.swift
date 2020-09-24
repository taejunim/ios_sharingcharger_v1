//
//  PasswordInitViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/19.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class PasswordInitViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: CustomTextField!
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var autorizationCodeTextField: CustomTextField!
    
    @IBOutlet weak var passwordInitButton: UIButton!    //비밀번호 초기화 버튼
    
    var activeTextField: UITextField?    //현재 포커싱인 textField
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        setTextFieldDelegate()
        setKeyboard()
        
        emailTextField.setCurrentType(type: 1, target: self)   //이메일 필드에 인증요청 버튼 추가
        
        passwordInitButton.layer.cornerRadius = 7           //완료 버튼 둥글게
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
}
