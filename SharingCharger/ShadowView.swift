//
//  ShadowView.swift
//  SharingCharger
//
//  Created by tjlim on 2020/09/10.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class ShadowView: UIControl {
    
    private var shadowLayer: CAShapeLayer!
    let clockLayer = CALayer()
    let chargingTimeTextLayer = CATextLayer()
    let chargingDateTextLayer = CATextLayer()
    
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    let bigFont = UIFont.systemFont(ofSize: 15)
    var smallFont = UIFont()
    
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
            print("layoutSubviews : " , layer.frame.size)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
            addClockLayer()
            addChargingTimeTextLayer()
            addChargingDateTextLayer()
            addMainArrowLayer()
        }
    }
    
    private func addClockLayer() {
        
        clockLayer.frame = CGRect(x:20, y:20, width: 70, height: 70)
        clockLayer.bounds = clockLayer.frame.insetBy(dx: 5.0, dy: 5.0)
        clockLayer.contents = UIImage(named: "clock")?.cgImage
        
        layer.addSublayer(clockLayer)
        
        self.addTarget(MainViewController(), action: #selector(MainViewController.searchingConditionButton), for: .touchUpInside)
    }
    
    private func addChargingTimeTextLayer() {
        
        chargingTimeTextLayer.frame = CGRect(x: clockLayer.frame.maxX, y: 20, width: layer.frame.width - (clockLayer.frame.maxX * 2), height: layer.frame.height/2)
        chargingTimeTextLayer.alignmentMode = .center
        chargingTimeTextLayer.contentsScale = UIScreen.main.scale
        chargingTimeTextLayer.string = chargingTimeTextAttribute(text: "30분")
        
        layer.addSublayer(chargingTimeTextLayer)
    }
    
    private func addChargingDateTextLayer() {
        
        chargingDateTextLayer.frame = CGRect(x: clockLayer.frame.maxX, y: chargingTimeTextLayer.frame.height, width: layer.frame.width - (clockLayer.frame.maxX * 2), height: layer.frame.height - chargingTimeTextLayer.frame.maxY)
        chargingDateTextLayer.alignmentMode = .center
        chargingDateTextLayer.contentsScale = UIScreen.main.scale
        
        dateFormatter.locale = Locale(identifier: "ko")
        dateFormatter.dateFormat = "MM/dd (E) HH:mm"
        
        timeFormatter.locale = Locale(identifier: "ko")
        timeFormatter.dateFormat = "HH:mm"
        
        let date = Date()
        let minute = calendar.component(.minute, from: date)
        let hour = calendar.component(.hour, from: date)
        
        var components = DateComponents()
        components.calendar = calendar
        components.day = 1
        
        var availableDate = Date()
        
        if minute >= 0 && minute < 30 {
            availableDate = calendar.date(bySettingHour: hour, minute: 30, second: 0, of: date)!
        } else {
            
            let tempDate = calendar.date(byAdding: .hour, value: 1, to: date)!
            let tempHour = calendar.component(.hour, from: tempDate)
            availableDate = calendar.date(bySettingHour: tempHour, minute: 0, second: 0, of: tempDate)!
        }
        
        let endDate = Calendar.current.date(byAdding: .minute, value: 30, to: availableDate)!
        chargingDateTextLayer.string = chargingDateTextAttribute(text: "\(dateFormatter.string(from: availableDate)) ~ \(timeFormatter.string(from: endDate))")
        
        layer.addSublayer(chargingDateTextLayer)
    }
    
    private func addMainArrowLayer() {
        
        let mainArrowImageLayer = CALayer()
        
        mainArrowImageLayer.frame = CGRect(x: clockLayer.frame.maxX + chargingTimeTextLayer.frame.width + 20, y:25, width: 60, height: 60)
        mainArrowImageLayer.bounds = clockLayer.frame.insetBy(dx: 15.0, dy: 15.0)
        mainArrowImageLayer.contents = UIImage(named: "main_arrow")?.cgImage
        
        layer.addSublayer(mainArrowImageLayer)
    }
    
    public func setAttributes(width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    public func setLabelText(chargingTimeText: String?, chargingDateText: String?) {
        
        chargingTimeTextLayer.string = chargingTimeTextAttribute(text: chargingTimeText)
        chargingDateTextLayer.string = chargingDateTextAttribute(text: chargingDateText)
    }
    
    private func chargingTimeTextAttribute(text: String?) -> NSAttributedString {
        
        let attributedString = NSAttributedString(
            string: "총 \(text!) 충전",
            attributes: [ .font: UIFont.boldSystemFont(ofSize: 22), .foregroundColor: UIColor.darkText]
        )
        
        return attributedString
    }
    
    private func chargingDateTextAttribute(text: String?) -> NSAttributedString {
        
        let font: UIFont
        
        if text!.count >= 33 {
            font = checkDeviceFrame()
        } else {
            font = bigFont
        }
        
        let attributedString = NSAttributedString(
            string: text!,
            attributes: [ .font: font, .foregroundColor: UIColor.darkText]
        )
        
        return attributedString
    }
    
    private func checkDeviceFrame() -> UIFont {
        
        var font = UIFont()
        
        if UIDevice().userInterfaceIdiom == .phone {
            
            switch UIScreen.main.nativeBounds.height {
            
            case 1136:
                print("iPhone 5 or 5S or 5C")
                font = UIFont.systemFont(ofSize: 10)
                
            case 1334:
                print("iPhone 6/6S/7/8")
                font = UIFont.systemFont(ofSize: 10)
                
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                font = UIFont.systemFont(ofSize: 13)
                
            case 2436:
                print("iPhone X/XS/11 Pro")
                font = UIFont.systemFont(ofSize: 13)
                
            case 2688:
                print("iPhone XS Max/11 Pro Max")
                font = UIFont.systemFont(ofSize: 13)
                
            case 1792:
                print("iPhone XR/ 11 ")
                font = UIFont.systemFont(ofSize: 13)
                
            default:
                print("Unknown")
                font = UIFont.systemFont(ofSize: 13)
                
            }
        }
        
        return font
    }
}
