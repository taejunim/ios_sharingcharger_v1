//
//  SettingViewController.swift
//  SharingCharger
//
//  Created by chihong an on 2020/08/26.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var LogoutButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        LogoutButton.layer.cornerRadius = 5
        
    }
}
