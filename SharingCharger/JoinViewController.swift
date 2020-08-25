//  회원가입 화면
//  JoinViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/10.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: CustomTextField!              //이름 textField
    @IBOutlet weak var phoneTextField: CustomTextField!             //전화 번호 textField
    @IBOutlet weak var emailTextField: CustomTextField!             //이메일 textField
    @IBOutlet weak var autorizationCodeTextField: CustomTextField!  //인증번호 textField
    @IBOutlet weak var passwordTextField: CustomTextField!          //패스워드 textField
    @IBOutlet weak var passwordConfirmTextField: CustomTextField!   //패스워드 확인 textField
    
    @IBOutlet weak var buttonComplete: UIButton!                    //완료 버튼
    
    var activeTextFieldTag: Int = -1    //현재 포커싱인 textField
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.black  //백버튼 검은색으로
        self.navigationController?.navigationBar.topItem?.title = ""        //백버튼 텍스트 제거
        
        emailTextField.setCurrentType(type: 1, target: self)   //이메일 필드에 인증요청 버튼 추가
        
        setTextFieldDelegate()
        setKeyboard()
        
        buttonComplete.layer.cornerRadius = 7           //완료 버튼 둥글게
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
    
    @objc func buttonAutorization(sender: UIButton!) {
        print("JoinViewController - Button tapped")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextFieldTag = textField.tag
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {

        activeTextFieldTag = -1
    }
    
    @objc func keyboardWillHide(_ notification : Notification?) {
        
        if (activeTextFieldTag == self.passwordConfirmTextField.tag) {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func keyboardWillShow(_ notification : Notification?) {
        
        //맨 아래의 "패스워드 확인 textField" 터치후 키보드 올라오면 키보드가 textField 를 가리므로 뷰를 -50 만큼 올려줌
        if (activeTextFieldTag == self.passwordConfirmTextField.tag) {
            self.view.frame.origin.y = -50
        }
        
        //키보드가 올라와있고 "패스워드 확인 textField" 포커싱중인 상태에서 다른 textField 로 포커스 이동시 뷰를 0만큼 원래위치로
        else if (activeTextFieldTag != self.passwordConfirmTextField.tag && self.view.frame.origin.y == -50.0) {
            self.view.frame.origin.y = 0
        }
    }
}
