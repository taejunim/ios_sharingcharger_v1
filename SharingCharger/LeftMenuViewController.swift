//
//  LeftMenuViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/09/28.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class LeftMenuViewController: UIViewController {

    @IBOutlet var pointCharge: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLeftMenu()
    }
    
    private func initializeLeftMenu() {
        
        //print("LeftMenuViewController - initializeLeftMenu")
        
        pointCharge.addTarget(self, action: #selector(pointChargeButton(sender:)), for: .touchUpInside)
    }
    
    @objc func pointChargeButton(sender: UIView!) {
        
        print("충전하기 이벤트")

    }
    

}
