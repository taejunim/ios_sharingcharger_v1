//
//  ChargeDefaultTimeSettingViewController.swift
//  SharingCharger
//
//  Created by 조유영 on 2021/01/05.
//  Copyright © 2021 metisinfo. All rights reserved.
//

import UIKit

class ChargeDefaultTimeSettingViewController: UIViewController ,UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet var defaultChargeTimeLabel: UILabel!
    @IBOutlet var defaultChargeTimeVIew: UIView!
    @IBOutlet var defaultChargeTimePickerView: UIPickerView!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    private var chargeTimeArray: [String] = ["8시간" , "7시간" , "6시간" , "5시간" , "4시간" , "3시간" , "2시간" , "1시간" ]
    
    var defaultTime:Int = 0
    let maximumTime:Int = 8
    
    let myUserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cancelButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(self.confirm), for: .touchUpInside)
        
        defaultChargeTimePickerView.backgroundColor = .white
        defaultChargeTimePickerView.delegate = self
        defaultChargeTimePickerView.dataSource = self

        if let userDefaultTime = myUserDefaults.string(forKey: "defaultTime"){
            
            let index = maximumTime - Int(userDefaultTime)!
            defaultChargeTimePickerView.selectRow(index, inComponent: 0, animated: false)
            defaultChargeTimeLabel.text = chargeTimeArray[index]
            
        } else {
            defaultChargeTimePickerView.selectRow(0, inComponent: 0, animated: false)
            defaultChargeTimeLabel.text = chargeTimeArray[0]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return chargeTimeArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        defaultChargeTimeLabel.text = chargeTimeArray[row]
        defaultTime = row
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return chargeTimeArray.count
    }
    
    @objc func confirm(){
        let selectedTime = maximumTime - defaultTime
        myUserDefaults.set(selectedTime,forKey:"defaultTime")
        close()
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
