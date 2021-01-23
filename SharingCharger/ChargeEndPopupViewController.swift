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
    @IBOutlet var refundPointView: UIView!
    @IBOutlet var refundPointLabel: UILabel!
    @IBOutlet var realUsedPointView: UIView!
    @IBOutlet var realUsedPointLabel: UILabel!
    @IBOutlet var startRechargeDateView: UIView!
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
    
    let myUserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

       viewWillInitializeObjects()
    }
    
    private func viewWillInitializeObjects() {
        
        if refundPoint == 0 {
            //realUsedPointView.gone()
            realUsedPointView.isHidden = true
            
            startRechargeDateView.translatesAutoresizingMaskIntoConstraints = false
            startRechargeDateView.topAnchor.constraint(equalTo: refundPointView.bottomAnchor, constant: 20).isActive = true
        }
        
        reservationPointLabel.text = setComma(value : reservationPoint) + "p"
        refundPointLabel.text = setComma(value : refundPoint) + "p"
        realUsedPointLabel.text = setComma(value : realUsedPoint) + "p"
        startRechargeDateLabel.text = startRechargeDate
        endRechargeDateLabel.text = endRechargeDate
        rechargePeriodLabel.text = rechargePeriod
        
        confirmButton.layer.cornerRadius = 7
        confirmButton.addTarget(self, action: #selector(self.confirm), for: .touchUpInside)
        
        myUserDefaults.set(0, forKey: "reservationId")
        myUserDefaults.set(nil, forKey: "reservationInfo")
        myUserDefaults.set(0, forKey: "rechargeId")
        myUserDefaults.set(false, forKey: "isCharging")
        myUserDefaults.set(nil, forKey: "startRechargeDate")
        myUserDefaults.set(nil, forKey: "endRechargeDate")
        myUserDefaults.set(0, forKey: "reservationPoint")
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
