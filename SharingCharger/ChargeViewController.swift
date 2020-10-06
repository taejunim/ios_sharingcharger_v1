//
//  ChargeViewController.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/10/06.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class ChargeViewController: UIViewController {

    
    
    @IBOutlet var chargeStart: UIButton!
    @IBOutlet var chargeEnd: UIButton!
    @IBOutlet var searchCharger: UIButton!
    @IBOutlet var customerCenter: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       chargeStart.layer.cornerRadius = 50
       chargeEnd.layer.cornerRadius = 50
       searchCharger.layer.cornerRadius = 7
       
       
        chargeStart.addTarget(self, action: #selector(chargeStart(sender:)), for: .touchUpInside)
        chargeEnd.addTarget(self, action: #selector(chargeEnd(sender:)), for: .touchUpInside)
        searchCharger.addTarget(self, action: #selector(searchCharger(sender:)), for: .touchUpInside)
        customerCenter.addTarget(self, action: #selector(contactCustomerCenter(sender:)), for: .touchUpInside)
    
    }
 
    @objc func chargeStart(sender: UIView!) {
        
        print("chargeStart")
        
    }
    
    @objc func chargeEnd(sender: UIView!) {
        
        print("chargeEnd")
    }
    
    @objc func searchCharger(sender: UIView!) {
        
        print("searchCharger")
        
    }
    
    @objc func contactCustomerCenter(sender: UIView!) {
        
        print("contactCustomerCenter")
        
    }
}
