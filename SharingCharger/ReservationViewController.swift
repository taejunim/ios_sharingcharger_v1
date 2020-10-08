//
//  ReservationViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/25.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class ReservationViewController: UIViewController {

    @IBOutlet weak var myPoint: UILabel!
    @IBOutlet weak var confirmReservation: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeCheckReservation()
    }
    
    private func initializeCheckReservation() {
        
        setMyPointLabel()
        
        confirmReservation.layer.cornerRadius = 7
        confirmReservation.addTarget(self, action: #selector(confirmReservation(sender:)), for: .touchUpInside)
    }
    
    @objc func setMyPointLabel() {
        
        myPoint.layer.cornerRadius = 7

    }
    
    @objc func confirmReservation(sender: UIButton!) {
        
        print("예약완료 이벤트")

//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
