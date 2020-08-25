//  텍스트 필드 커스텀
//  CustomTextField.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/10.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    let border = CALayer()
    var type = 0;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.backgroundColor = UIColor.white
        self.textColor = UIColor.darkText
        
        drawUnderLine()
    }
    
    public func setCurrentType(type: Int, target: AnyObject) {
   
        switch type {
        
        case 1:
            addButton(target: target)
            
            break
            
        default:
            break
        }
    }
    
    //인증 요청 버튼 추가
    private func addButton(target: AnyObject) {

        let btn = UIButton()
        
        let Color_7F7F7F = UIColor(named: "Color_3498DB")
        btn.backgroundColor = Color_7F7F7F
        btn.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(15))
        btn.setTitle("인증 요청", for: .normal)

        self.addSubview(btn)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        btn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -7).isActive = true
        
        btn.addTarget(target, action: #selector(target.buttonAutorization), for: .touchUpInside)
    }
    
    
    //텍스트 필드에 밑줄 긋기
    private func drawUnderLine() {
        
        let underLine = UIView()
        
        let Color_EFEFEF = UIColor(named: "Color_EFEFEF")
        underLine.backgroundColor = Color_EFEFEF

        self.addSubview(underLine)
        
        underLine.translatesAutoresizingMaskIntoConstraints = false
        underLine.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        underLine.leftAnchor.constraint(equalTo: self.leftAnchor, constant:7).isActive = true
        underLine.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -7).isActive = true
        underLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
