//  Label 뒤에 별표 빨간색으로 변경
//  AppendStar.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/18.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class AppendStar: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        //스토리보드에서 받아온 텍스트
        let attributedString = NSMutableAttributedString(string: self.text!)
        
        //위에서 만든 attributedString에 addAttribute메소드를 통해 Attribute를 적용. -> "*" 만 빨간색 입힘
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemRed, range: (text! as NSString).range(of: "*"))
        
        self.attributedText = attributedString
    }
}
