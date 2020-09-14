//
//  SearchingConditionViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/09/13.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class SearchingConditionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        print(self.view.safeAreaLayoutGuide.bottomAnchor)
        
        addButton(buttonName: "close", width: 40, height: 40, top: 15, left: 15, right: nil, bottom: nil, target: self.view)
        addButton(buttonName: "refresh", width: 40, height: 40, top: 15, left: nil, right: -15, bottom: nil, target: self.view)
        
        //확인 버튼의 bottom constraint 가 safe area 의 bottom constraint 로 맞추려고 bottom: nil 설정 -> CustomButton 에서 분기처리 했음
        addButton(buttonName: "confirm", width: nil, height: 40, top: nil, left: 0, right: 0, bottom: nil, target: self.view)
    }
    
    @objc func closeButton(sender: UIButton!) {
        print("JoinViewController - Button tapped")
        self.dismiss(animated: true, completion: nil)
    }
    
    private func addButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
        let button = CustomButton(type: .system)
        
        self.view.addSubview(button)
        
        button.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
    }
}
