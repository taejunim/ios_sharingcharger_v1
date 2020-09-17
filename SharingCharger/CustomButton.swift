//
//  CustomButton.swift
//  SharingCharger
//
//  Created by tjlim on 2020/09/14.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    public func setAttributes(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
    
        self.translatesAutoresizingMaskIntoConstraints = false
        
        switch buttonName {
        
        case "close":
            
            let imageLayer = CALayer()
            
            imageLayer.frame = CGRect(x:0, y:0, width: width!, height: height!)
            imageLayer.bounds = imageLayer.frame.insetBy(dx: 5.0, dy: 5.0)
            imageLayer.contents = UIImage(named: "close")?.cgImage
            
            layer.addSublayer(imageLayer)
            
            self.addTarget(SearchingConditionViewController(), action: #selector(SearchingConditionViewController.closeButton), for: .touchUpInside)
            
            break
            
        case "refresh":
            
            let imageLayer = CALayer()
            
            imageLayer.frame = CGRect(x:0, y:0, width: width!, height: height!)
            imageLayer.bounds = imageLayer.frame.insetBy(dx: 5.0, dy: 5.0)
            imageLayer.contents = UIImage(named: "refresh")?.cgImage
            
            layer.addSublayer(imageLayer)
            
            self.addTarget(SearchingConditionViewController(), action: #selector(SearchingConditionViewController.closeButton), for: .touchUpInside)
            
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
