//  회원가입 화면
//  JoinViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/10.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController {
    
    @IBOutlet weak var tfEmail: CustomTextField!    //이메일 텍스트 필드
    
    @IBOutlet weak var buttonComplete: UIButton!    //완료 버튼
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeHideKeyboard()    //뷰 터치시 키보드 내리기
        
        self.navigationController?.navigationBar.tintColor = UIColor.black  //백버튼 검은색으로
        self.navigationController?.navigationBar.topItem?.title = ""        //백버튼 텍스트 제거
        
        tfEmail.setCurrentType(type: 1, target: self)   //이메일 필드에 인증요청 버튼 추가
        
        buttonComplete.layer.cornerRadius = 7           //완료 버튼 둥글게
    }
    
    
    @objc func buttonAutorization(sender: UIButton!) {
        print("Button tapped")
    }
}

//뷰 터치시 키보드 내리기
extension JoinViewController {
    func initializeHideKeyboard(){
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    @objc func dismissMyKeyboard(){
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
    }
}
