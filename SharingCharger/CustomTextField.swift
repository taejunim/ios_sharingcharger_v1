//
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
        drawUnderLine()
//        switch type {
//        case 1:
//            drawUnderLine()
//            addButton()
//            break
//        default:
//            drawUnderLine()
//            break
//        }
        
//        drawUnderLine()
    }
    
    public func setCurrentType(type: Int, target: JoinViewController) {
        switch type {
        case 1:
            addButton(target: target)
            break
        default:
            break
        }
    }
    
    private func addButton(target: JoinViewController) {
//        let btn = UIButton(frame: CGRect(x: 100, y: 0, width: 100, height: 30))
        let btn = UIButton()
        btn.setTitle("인증 요청", for: .normal)
        //btn.backgroundColor = UIColor.black
        
        let Color_7F7F7F = UIColor(named: "Color_7F7F7F")
        btn.backgroundColor = Color_7F7F7F
//        btn.addTarget(superview, action: #selector(buttonAction), for: .touchUpInside)
        self.addSubview(btn)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        btn.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        btn.addTarget(target, action: #selector(target.buttonAction), for: .touchUpInside)
    }
    
    private func drawUnderLine() {
        
        let frameY: CGFloat = self.frame.size.height-1
        let frameWidth: CGFloat = self.frame.width
        
        border.frame = CGRect(x: 0, y: frameY, width: frameWidth, height: 1)

        //border.backgroundColor = UIColor.Color_7F7F7F.cgColor
        let Color_7F7F7F = UIColor(named: "Color_EFEFEF")?.cgColor
        border.backgroundColor = Color_7F7F7F
//            UIColor(named: "Color_7F7F7F")!
        
        self.layer.addSublayer(border)
    }
}
