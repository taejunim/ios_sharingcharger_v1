//
//  ReservationPopupViewController.swift
//  SharingCharger
//
//  Created by 조유영 on 2021/01/03.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import GoneVisible

class ChargeEndPopupViewController: UIViewController {
    

    @IBOutlet var reservationPointLabel: UILabel!
    @IBOutlet var refundPointLabel: UILabel!
    @IBOutlet var realUsedPointLabel: UILabel!
    @IBOutlet var startRechargeDateLabel: UILabel!
    @IBOutlet var endRechargeDateLabel: UILabel!
    @IBOutlet var rechargePeriodLabel: UILabel!
    
    var reservationPoint:Int = 0
    var refundPoint:Int = 0
    var realUsedPoint:Int = 0
    var startRechargeDate:String = ""
    var endRechargeDate:String = ""
    var rechargePeriod:String = ""
    
    var userType:String = ""
    
    @IBOutlet var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       viewWillInitializeObjects()
    }
    
    private func viewWillInitializeObjects() {
        
        if refundPoint == 0 && realUsedPoint == 0 {
            realUsedPointLabel.gone()
        }
        
        reservationPointLabel.text = setComma(value : reservationPoint) + "p"
        refundPointLabel.text = setComma(value : refundPoint) + "p"
        realUsedPointLabel.text = setComma(value : realUsedPoint) + "p"
        startRechargeDateLabel.text = startRechargeDate
        endRechargeDateLabel.text = endRechargeDate
        rechargePeriodLabel.text = rechargePeriod
        
        confirmButton.layer.cornerRadius = 7
        confirmButton.addTarget(self, action: #selector(self.confirm), for: .touchUpInside)
    }
    
    private func setComma(value: Int) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: value))!
        
        return result
    }
    
    private func setComma(value: Double) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: value))!
        
        return result
    }
    
    @objc func confirm(){
        
        if userType == "General" {
            let mainViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "Main") as! MainViewController
            let navigationController = UINavigationController(rootViewController: mainViewController)
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
        self.dismiss(animated: true, completion: nil)
        
    }
}
