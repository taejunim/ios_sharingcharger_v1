//
//  MainViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/25.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        super.viewWillAppear(animated)
    }
}
