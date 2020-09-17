//
//  SearchingConditionViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/09/13.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class SearchingConditionViewController: UIViewController {

    @IBOutlet var totalChargingTimeTextField: UILabel!
    @IBOutlet var chargingPeriod: UILabel!
    @IBOutlet var instantCharge: UIButton!
    @IBOutlet var reservationCharge: UIButton!
    @IBOutlet var chargingStartDateView: UIControl!
    @IBOutlet var chargingStartDate: UILabel!
    @IBOutlet var chargingTimeView: UIView!
    @IBOutlet var chargingTime: UILabel!
    @IBOutlet var rangeView: UIView!
    @IBOutlet var range: UILabel!
    @IBOutlet var feeView: UIView!
    @IBOutlet var fee: UILabel!
    @IBOutlet var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        print(self.view.safeAreaLayoutGuide.bottomAnchor)
        
        setButton()
    }
    
    private func setButton() {
        addButton(buttonName: "close", width: 40, height: 40, top: 15, left: 15, right: nil, bottom: nil, target: self.view)
        addButton(buttonName: "refresh", width: 40, height: 40, top: 15, left: nil, right: -15, bottom: nil, target: self.view)
        
        instantCharge.addTarget(self, action: #selector(instantChargeButton(sender:)), for: .touchUpInside)
        reservationCharge.addTarget(self, action: #selector(reservationChargeButton(sender:)), for: .touchUpInside)
        
        let chargingStartDateViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.chargingStartDateViewButton))
        chargingStartDateView.addGestureRecognizer(chargingStartDateViewGesture)
        
        let chargingTimeViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.chargingTimeViewButton))
        chargingTimeView.addGestureRecognizer(chargingTimeViewGesture)
        
        let rangeViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.rangeViewButton))
        rangeView.addGestureRecognizer(rangeViewGesture)
        
        let feeViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.feeViewButton))
        feeView.addGestureRecognizer(feeViewGesture)
        
        confirmButton.addTarget(self, action: #selector(confirmButton(sender:)), for: .touchUpInside)
        confirmButton.layer.cornerRadius = 7
    }
    
    @objc func instantChargeButton(sender: UIButton!) {
        print("instantChargeButton")
    }
    
    @objc func reservationChargeButton(sender: UIButton!) {
        print("reservationChargeButton")
    }
    
    @objc func chargingStartDateViewButton(sender: UIView!) {
        print("chargingStartDateViewButton")
    }
    
    @objc func chargingTimeViewButton(sender: UIView!) {
        print("chargingTimeViewButton")
    }
    
    @objc func rangeViewButton(sender: UIView!) {
        print("rangeViewButton")
    }
    
    @objc func feeViewButton(sender: UIView!) {
        print("feeViewButton")
    }
    
    @objc func closeButton(sender: UIButton!) {
        print("JoinViewController - Button tapped")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func confirmButton(sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func addButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
        let button = CustomButton(type: .system)
        
        self.view.addSubview(button)
        
        button.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
    }
}
