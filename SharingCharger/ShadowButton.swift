//
//  ShadowButton.swift
//  SharingCharger
//
//  Created by tjlim on 2020/09/09.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class ShadowButton: UIButton {

    private var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 4).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor   // 버튼 내부 색상
            shadowLayer.shadowColor = UIColor.gray.cgColor  // 그림자 색상
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)  // 그림자를 그리는 컴포넌트에서 그림자를 얼마나 이동시키는지. 설정하는 CGSize 값만큼 이동해서 나타남
            shadowLayer.shadowOpacity = 0.7 // 그림자 투명도. 투명도는 여기서 설정할 수도 있고, 색을 지정할때 alpha 로 지정할 수도 있음
            shadowLayer.shadowRadius = 1  // 그림자 경계의 선명도. 숫자가 클수록 그림자가 많이 퍼짐. 0이면 그림자가 칼같이 떨어짐.
            shadowLayer.masksToBounds = false   // 내부에 속한 요소들이 UIView 밖을 벗어날 때, 잘라낼 것인지. 그림자는 밖에 그려지는 것이므로 false 로 설정

            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }
    
    public func setAttributes(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
    
        self.translatesAutoresizingMaskIntoConstraints = false
        
        switch buttonName {
        
        case "menu":
            
            let imageLayer = CALayer()
            
            imageLayer.frame = CGRect(x:0, y:0, width: width!, height: height!)
            imageLayer.bounds = imageLayer.frame.insetBy(dx: 5.0, dy: 5.0)
            imageLayer.contents = UIImage(named: "menu")?.cgImage
            
            layer.addSublayer(imageLayer)
            
            self.addTarget(MainViewController(), action: #selector(MainViewController.menuButton), for: .touchUpInside)
            break
            
        case "address":
            
            self.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(18))
            //self.setTitle("", for: .normal)
            self.addTarget(MainViewController(), action: #selector(MainViewController.addressButton), for: .touchUpInside)

            break
            
        default:
            break
        }
        
        if width != nil {
            self.widthAnchor.constraint(equalToConstant: width!).isActive = true
        }
        
        if height != nil {
            self.heightAnchor.constraint(equalToConstant: height!).isActive = true
        }
        
        if top != nil {
            self.topAnchor.constraint(equalTo: target.topAnchor, constant: top!).isActive = true
        }
        
        if left != nil {
            self.leftAnchor.constraint(equalTo: target.leftAnchor, constant: left!).isActive = true
        }
        
        if right != nil {
            self.rightAnchor.constraint(equalTo: target.rightAnchor, constant: right!).isActive = true
        }
        
        if bottom != nil {
            self.bottomAnchor.constraint(equalTo: target.bottomAnchor, constant: bottom!).isActive = true
        }
     }
    
}
