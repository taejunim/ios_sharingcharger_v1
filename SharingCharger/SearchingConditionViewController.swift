//
//  SearchingConditionViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/09/13.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import GoneVisible

protocol SearchingConditionProtocol {
    func searchingConditionDelegate(data: SearchingConditionObject)
}

class SearchingConditionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var delegate: SearchingConditionProtocol?
    
    @IBOutlet var totalChargingTimeTextField: UILabel!
    @IBOutlet var chargingPeriod: UILabel!
    @IBOutlet var instantCharge: UIButton!
    @IBOutlet var reservationCharge: UIButton!
    @IBOutlet var chargingStartDateView: UIControl!
    @IBOutlet var chargingStartDate: UILabel!
    var chargingEndDate: String = ""
    @IBOutlet var chargingTimeView: UIView!
    @IBOutlet var chargingTime: UILabel!
    @IBOutlet var rangeView: UIView!
    @IBOutlet var range: UILabel!
    @IBOutlet var feeView: UIView!
    @IBOutlet var fee: UILabel!
    @IBOutlet var confirmButton: UIButton!
    
    @IBOutlet var chargingStartDatePickerView: UIView!
    @IBOutlet var chargingStartDatePicker: UIDatePicker!
    
    @IBOutlet var chargingTimePickerView: UIView!
    @IBOutlet var chargingTimePicker: UIPickerView!
    
    private var chargingTimeArray: [String] = []
    private var rangeArray: [String] = ["전체", "3 km", "10 km", "30 km"]
    private var feeArray: [String] = ["전체", "100원 대", " 200원 대", "300원 대"]
    
    @IBOutlet var rangePickerView: UIView!
    @IBOutlet var rangePicker: UIPickerView!
    
    @IBOutlet var feePickerView: UIView!
    @IBOutlet var feePicker: UIPickerView!
    
    var isChargingStartDatePickerViewShowing: Bool = false
    var isChargingTimePickerViewShowing: Bool = false
    var isRangePickerViewShowing: Bool = false
    var isFeePickerViewShowing: Bool = false
    
    @IBOutlet var scrollView: UIScrollView!
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    let HHMMFormatter = DateFormatter()
    let HHFormatter = DateFormatter()
    let MMFormatter = DateFormatter()
    
    let buttonBorderWidth: CGFloat! = 1.0
    let ColorE0E0E0: UIColor! = UIColor(named: "Color_E0E0E0")
    let Color3498DB: UIColor! = UIColor(named: "Color_3498DB")
    
    let calendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWillInitializeObjects()
    }
    
    private func viewWillInitializeObjects() {
        
        self.delegate = MainViewController()    //선택한 검색 조건들을 MainViewController 로 넘김
        
        addButton(buttonName: "close", width: 40, height: 40, top: 15, left: 15, right: nil, bottom: nil, target: self.view)
        addButton(buttonName: "refresh", width: 40, height: 40, top: 15, left: nil, right: -15, bottom: nil, target: self.view)
        
        instantCharge.addTarget(self, action: #selector(instantChargeButton(sender:)), for: .touchUpInside)
        instantCharge.layer.borderWidth = 1.0
        instantCharge.layer.borderColor = Color3498DB?.cgColor
        
        reservationCharge.addTarget(self, action: #selector(reservationChargeButton(sender:)), for: .touchUpInside)
        reservationCharge.layer.borderWidth = 1.0
        reservationCharge.layer.borderColor = ColorE0E0E0?.cgColor
        
        let chargingStartDateViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.chargingStartDateViewButton))
        chargingStartDateView.addGestureRecognizer(chargingStartDateViewGesture)
        chargingStartDateView.isEnabled = false
        
        dateFormatter.locale = Locale(identifier: "ko")
        dateFormatter.dateFormat = "MM/dd (E) HH:mm"
        
        timeFormatter.locale = Locale(identifier: "ko")
        timeFormatter.dateFormat = "HH:mm"
        
        HHMMFormatter.locale = Locale(identifier: "ko")
        HHMMFormatter.dateFormat = "HH시간 mm분"
        
        HHFormatter.locale = Locale(identifier: "ko")
        HHFormatter.dateFormat = "HH시간"
        
        MMFormatter.locale = Locale(identifier: "ko")
        MMFormatter.dateFormat = "mm분"
        
        chargingStartDate.text = "\(dateFormatter.string(from: Date()))"
        
        chargingStartDatePickerView.backgroundColor = UIColor.white
        chargingStartDatePickerView.gone()
        
        chargingStartDatePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        
        let date = Date()
        let minute = calendar.component(.minute, from: date)
        let hour = calendar.component(.hour, from: date)
        
        var components = DateComponents()
        components.calendar = calendar
        components.day = 1
        
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let maximumDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: tomorrow)!
        
        var availableDate = Date()
        
        if minute >= 0 && minute < 30 {
            availableDate = calendar.date(bySettingHour: hour, minute: 30, second: 0, of: date)!
        } else {
            
            let tempDate = calendar.date(byAdding: .hour, value: 1, to: date)!
            let tempHour = calendar.component(.hour, from: tempDate)
            availableDate = calendar.date(bySettingHour: tempHour, minute: 0, second: 0, of: tempDate)!
        }
        
        chargingStartDate.text = "\(dateFormatter.string(from: availableDate))"
        chargingStartDatePicker.minimumDate = availableDate
        chargingStartDatePicker.maximumDate = maximumDate
        
        let endDate = calendar.date(byAdding: .minute, value: 30, to: date)!
        chargingEndDate = "\(timeFormatter.string(from: endDate))"
        chargingPeriod.text = "\(dateFormatter.string(from: date)) ~ \(chargingEndDate)"
        
        let chargingTimeViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.chargingTimeViewButton))
        chargingTimeView.addGestureRecognizer(chargingTimeViewGesture)
        
        chargingTimeArray.append("30분")
        for i in 1 ... 10 {
            
            chargingTimeArray.append("\(i)시간")
            
            if i < 10 {
                chargingTimeArray.append("\(i)시간 30분")
            }
        }
        
        chargingTimePickerView.backgroundColor = UIColor.white
        chargingTimePickerView.gone()
        
        chargingTimePicker.backgroundColor = .white
        chargingTimePicker.delegate = self
        chargingTimePicker.dataSource = self
        
        let rangeViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.rangeViewButton))
        rangeView.addGestureRecognizer(rangeViewGesture)
        
        rangePickerView.backgroundColor = UIColor.white
        rangePickerView.gone()
        
        rangePicker.backgroundColor = .white
        rangePicker.delegate = self
        rangePicker.dataSource = self
        rangePicker.selectRow(1, inComponent: 0, animated: false)
        
        let feeViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.feeViewButton))
        feeView.addGestureRecognizer(feeViewGesture)
        
        feePickerView.backgroundColor = UIColor.white
        feePickerView.gone()
        
        feePicker.backgroundColor = .white
        feePicker.delegate = self
        feePicker.dataSource = self
        feePicker.selectRow(1, inComponent: 0, animated: false)
        
        confirmButton.addTarget(self, action: #selector(confirmButton(sender:)), for: .touchUpInside)
        confirmButton.layer.cornerRadius = 7
    }
    
    //datePicker 에서 변경시
    @objc func dateChanged(_ sender: UIDatePicker) {
        
        chargingStartDate.text = "\(dateFormatter.string(from: sender.date))"
        calculateChargingTime(senderDate: sender.date)
    }
    
    //time 변경시
    private func timeChanged() {
        
        calculateChargingTime(senderDate: chargingStartDatePicker.date)
    }
    
    //즉시 충전 버튼
    @objc func instantChargeButton(sender: UIButton!) {
        print("instantChargeButton")
        
        changeAttribute(inactiveButton: reservationCharge, activeButton: instantCharge)
    }
    
    //예약 충전 버튼
    @objc func reservationChargeButton(sender: UIButton!) {
        print("reservationChargeButton")
        
        changeAttribute(inactiveButton: instantCharge, activeButton: reservationCharge)
    }
    
    //충전 기간 세팅
    private func setChargingPeriod(activeButton: UIButton!) {
        
        let date = Date()
        
        if activeButton == instantCharge {

            calculateChargingTime(senderDate: date)
            
        } else {
            
            calculateChargingTime(senderDate: chargingStartDatePicker.date)
        }
    }
    
    private func calculateChargingTime(senderDate: Date) {
        
        let chargingTimeText = chargingTime.text!
        totalChargingTimeTextField.text = "총 \(chargingTimeText) 충전"
        
        var formattedChargingTime = Date()
        
        //30분
        if !chargingTimeText.contains("시간") && chargingTimeText.contains("분") {
            
            formattedChargingTime = MMFormatter.date(from: chargingTimeText)!
        }
        
        //1시간 .. 2시간 .. 3시간
        else if chargingTimeText.contains("시간") && !chargingTimeText.contains("분") {
            
            formattedChargingTime = HHFormatter.date(from: chargingTimeText)!
        }
        
        //1시간 30분 .. 2시간 30분 .. 3시간 30분
        else {
            formattedChargingTime = HHMMFormatter.date(from: chargingTimeText)!
        }
        
        let minute = calendar.component(.minute, from: formattedChargingTime)
        let hour = calendar.component(.hour, from: formattedChargingTime)
        
        let dateAddedHour = calendar.date(byAdding: .hour, value: hour, to: senderDate)!
        
        let endDate = calendar.date(byAdding: .minute, value: minute, to: dateAddedHour)!
        
        let dayOfStartDate = calendar.component(.day, from: senderDate)
        let dayOfEndDate = calendar.component(.day, from: endDate)
        
        if dayOfStartDate == dayOfEndDate {
            
            chargingEndDate = "\(timeFormatter.string(from: endDate))"
            chargingPeriod.text = "\(dateFormatter.string(from: senderDate)) ~ \(chargingEndDate)"
            
        } else if dayOfStartDate != dayOfEndDate {
            
            chargingEndDate = "\(dateFormatter.string(from: senderDate))"
            chargingPeriod.text = "\(dateFormatter.string(from: senderDate)) ~ \(dateFormatter.string(from: endDate))"
            
        } else {
            
            chargingEndDate = "\(dateFormatter.string(from: senderDate))"
            chargingPeriod.text = "\(dateFormatter.string(from: senderDate)) ~ \(dateFormatter.string(from: endDate))"
        }
    }
    
    //즉시 충전, 예약 충전 버튼 활성화시 속성 변경
    private func changeAttribute(inactiveButton: UIButton!, activeButton: UIButton!) {
        
        if isChargingStartDatePickerViewShowing {
            
            inactivateView(inactiveView: chargingStartDatePickerView)
            isChargingStartDatePickerViewShowing = false
            
        } else if isChargingTimePickerViewShowing {
            
            inactivateView(inactiveView: chargingTimePickerView)
            isChargingTimePickerViewShowing = false
            
        } else if isRangePickerViewShowing {
            
            inactivateView(inactiveView: rangePickerView)
            isRangePickerViewShowing = false
            
        } else if isFeePickerViewShowing {
            
            inactivateView(inactiveView: feePickerView)
            isFeePickerViewShowing = false
        }
        
        inactiveButton.backgroundColor = UIColor.white
        inactiveButton.layer.borderColor = ColorE0E0E0?.cgColor
        inactiveButton.setTitleColor(ColorE0E0E0, for: .normal)
        
        activeButton.backgroundColor = Color3498DB
        activeButton.layer.borderColor = Color3498DB?.cgColor
        activeButton.setTitleColor(UIColor.white, for: .normal)
        
        if activeButton == reservationCharge {
            chargingStartDate.textColor = UIColor.darkText
            chargingStartDateView.isEnabled = true
        } else {
            chargingStartDate.textColor = ColorE0E0E0
            chargingStartDateView.isEnabled = false
        }
        
        setChargingPeriod(activeButton: activeButton)
    }
    
    @objc func chargingStartDateViewButton(sender: UIView!) {
        print("chargingStartDateViewButton")
        
        if isChargingStartDatePickerViewShowing {
            
            inactivateView(inactiveView: chargingStartDatePickerView)
            isChargingStartDatePickerViewShowing = false
            
        } else {
            
            activateView(activeView: chargingStartDatePickerView)
            isChargingStartDatePickerViewShowing = true
        }
    }
    
    @objc func chargingTimeViewButton(sender: UIView!) {
        print("chargingTimeViewButton")
        
        if isChargingTimePickerViewShowing {
            
            inactivateView(inactiveView: chargingTimePickerView)
            isChargingTimePickerViewShowing = false
            
        } else {
            
            activateView(activeView: chargingTimePickerView)
            isChargingTimePickerViewShowing = true
        }
    }
    
    @objc func rangeViewButton(sender: UIView!) {
        print("rangeViewButton")
        
        if isRangePickerViewShowing {
            
            inactivateView(inactiveView: rangePickerView)
            isRangePickerViewShowing = false
            
        } else {
            
            activateView(activeView: rangePickerView)
            isRangePickerViewShowing = true
        }
    }
    
    @objc func feeViewButton(sender: UIView!) {
        print("feeViewButton")
        
        if isFeePickerViewShowing {
            
            inactivateView(inactiveView: feePickerView)
            isFeePickerViewShowing = false
            
        } else {
            
            activateView(activeView: feePickerView)
            isFeePickerViewShowing = true
        }
    }
    
    private func activateView(activeView: UIView!) {
        
        activeView.isHidden = false
        activeView.visible()
        
        if isChargingStartDatePickerViewShowing {
            
            chargingStartDatePickerView.isHidden = true
            chargingStartDatePickerView.gone()
            isChargingStartDatePickerViewShowing = false
            
        } else if isChargingTimePickerViewShowing {
            
            chargingTimePickerView.isHidden = true
            chargingTimePickerView.gone()
            isChargingTimePickerViewShowing = false
            
        } else if isRangePickerViewShowing {
            
            rangePickerView.isHidden = true
            rangePickerView.gone()
            isRangePickerViewShowing = false
            
        } else if isFeePickerViewShowing {
            
            feePickerView.isHidden = true
            feePickerView.gone()
            isFeePickerViewShowing = false
        }
        
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    
    private func inactivateView(inactiveView: UIView!) {
        
        inactiveView.isHidden = true
        inactiveView.gone()
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
     
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
        if pickerView == chargingTimePicker {
            
            return chargingTimeArray.count
            
        } else if pickerView == rangePicker {
            
            return rangeArray.count
            
        } else if pickerView == feePicker {
            
            return feeArray.count
            
        } else {
            
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == chargingTimePicker {
            
            return chargingTimeArray[row]
            
        } else if pickerView == rangePicker {
            
            return rangeArray[row]
            
        } else if pickerView == feePicker {
            
            return feeArray[row]
            
        } else {
            
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
     
        if pickerView == chargingTimePicker {
            
            print("row: \(row)")
            print("value: \(chargingTimeArray[row])")
            chargingTime.text = chargingTimeArray[row]
            timeChanged()
            
        } else if pickerView == rangePicker {
            
            print("row: \(row)")
            print("value: \(rangeArray[row])")
            range.text = rangeArray[row]
            
        } else if pickerView == feePicker {
            
            print("row: \(row)")
            print("value: \(feeArray[row])")
            fee.text = feeArray[row]
            
        } else {
            
        }
    }
    
    @objc func closeButton(sender: UIButton!) {
        print("JoinViewController - Button tapped")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func confirmButton(sender: UIButton!) {
        
        let searchingConditionObject = SearchingConditionObject()
        searchingConditionObject.chargingEndDate = chargingEndDate
        searchingConditionObject.chargingTime = chargingTime.text!
        searchingConditionObject.chargingPeriod = chargingPeriod.text!
        
        delegate?.searchingConditionDelegate(data: searchingConditionObject)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func addButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
        let button = CustomButton(type: .system)
        
        self.view.addSubview(button)
        
        button.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
    }
}
