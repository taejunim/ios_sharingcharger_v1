//
//  SearchingChargerViewController.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/10/06.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class SearchingChargerViewController: UIViewController {

    
    let Color7F7F7F: UIColor! = UIColor(named: "Color_7F7F7F")
    
    @IBOutlet var stepTable: UIView!
    @IBOutlet var chargerSearch: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SearchingChargerViewController")
       
        stepTable.layer.borderColor = Color7F7F7F?.cgColor
        stepTable.layer.borderWidth = 1
        
        
        chargerSearch.layer.cornerRadius = 7
        chargerSearch.addTarget(self, action: #selector(charge(sender:)), for: .touchUpInside)
        
    }
    
    
    @objc func charge(sender: UIView!) {
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Charge") else { return }
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}
