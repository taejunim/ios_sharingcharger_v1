//
//  SearchChargeHistoryViewController.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/10/18.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import Foundation

protocol SearchingChargeConditionProtocol {
    func searchingChargeConditionDelegate(data: SearchingHistoryConditionObject)
}
class SearchingChargeHistoryCondition: UIViewController {
   
    var delegate: SearchingChargeConditionProtocol?
    
    @IBOutlet var oneMonth       : UIButton!
    @IBOutlet var threeMonth     : UIButton!
    @IBOutlet var sixMonth       : UIButton!
    @IBOutlet var ownPeriod      : UIButton!
    
    @IBOutlet var asc            : UIButton!
    @IBOutlet var desc           : UIButton!
    
    @IBOutlet var adjustButton   : UIButton!
     
    @IBOutlet var startDateLabel : UILabel!
    @IBOutlet var endDateLabel   : UILabel!

    @IBOutlet var datepickerView : UIView!
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet var endDatePicker  : UIDatePicker!
    
    
    var periodButtonArray        : [UIButton] = []
    var sortButtonArray          : [UIButton] = []
    
    
    let sortArray                : [String]   = ["ASC", "DESC"]
    

    let buttonBorderWidth        : CGFloat!   = 1.0
    let ColorE0E0E0              : UIColor!   = UIColor(named: "Color_E0E0E0")
    let Color3498DB              : UIColor!   = UIColor(named: "Color_3498DB")
    let ColorWhite               : UIColor!   = UIColor.white
    
    var selectedSort                          = 0
    
    let calendar                              = Calendar.current
    let date                                  = Date()
    let dateFormatter                         = DateFormatter()

    var startDate                             = ""
    var endDate                               = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    func initialize(){
                
        
        self.delegate                = HistoryElectricityChargingViewController()
        
        addButton(buttonName: "close", width: 40, height: 40, top: 15, left: 15, right: nil, bottom: nil, target: self.view, targetViewController: self)
        addButton(buttonName: "refresh", width: 40, height: 40, top: 15, left: nil, right: -15, bottom: nil, target: self.view, targetViewController: self)
        
        dateFormatter.locale         = Locale(identifier: "ko")
        dateFormatter.dateFormat     = "yyyy-MM-dd"

        startDatePicker.locale       = Locale(identifier: "ko")
        endDatePicker.locale         = Locale(identifier: "ko")
        
        activateView(active: false)
        
        
        periodButtonArray.append(oneMonth)
        periodButtonArray.append(threeMonth)
        periodButtonArray.append(sixMonth)
        periodButtonArray.append(ownPeriod)
        
        sortButtonArray.append(asc)
        sortButtonArray.append(desc)

        for button in self.periodButtonArray {
            
            button.addTarget(self, action: #selector(setPeriodButton(_:)), for: .touchUpInside)
        }
        for button in self.sortButtonArray {
            
            button.addTarget(self, action: #selector(setSortButton(_:)), for: .touchUpInside)
        }
        
        adjustButton.addTarget(self, action: #selector(adjustButton(_:)), for: .touchUpInside)
        adjustButton.layer.cornerRadius = 7
        
        setPeriodButton(oneMonth)
        setSortButton(asc)
    }
    
    @IBAction func setPeriodButton(_ sender: UIButton) {
    
        
        for index in 0...3 {
 
            if(index == periodButtonArray.firstIndex(of: sender)){
                
                periodButtonArray[index].layer.borderWidth = buttonBorderWidth
                periodButtonArray[index].layer.borderColor = Color3498DB?.cgColor
                periodButtonArray[index].layer.backgroundColor = Color3498DB?.cgColor
                periodButtonArray[index].setTitleColor(ColorWhite, for: .normal)
                
                
            } else{

                periodButtonArray[index].layer.borderWidth = buttonBorderWidth
                periodButtonArray[index].layer.borderColor = ColorE0E0E0?.cgColor
                periodButtonArray[index].layer.backgroundColor = ColorWhite?.cgColor
                periodButtonArray[index].setTitleColor(ColorE0E0E0, for: .normal)
                
                
                
            }
        }
        onPeriodButtonClick(sender)
        
    }
    
    @IBAction func setSortButton(_ sender: UIButton) {
        
        for index in 0...1 {
            if(index == sortButtonArray.firstIndex(of: sender)){
            
                sortButtonArray[index].layer.borderWidth = buttonBorderWidth
                sortButtonArray[index].layer.borderColor = Color3498DB?.cgColor
                sortButtonArray[index].layer.backgroundColor = Color3498DB?.cgColor
                sortButtonArray[index].setTitleColor(ColorWhite, for: .normal)
                selectedSort = index
            
            } else{

                sortButtonArray[index].layer.borderWidth = buttonBorderWidth
                sortButtonArray[index].layer.borderColor = ColorE0E0E0?.cgColor
                sortButtonArray[index].layer.backgroundColor = ColorWhite?.cgColor
                sortButtonArray[index].setTitleColor(ColorE0E0E0, for: .normal)
            
            }
        }
        
    }
    
    func onPeriodButtonClick(_ range : UIButton){

        
        if(range == ownPeriod){
            
            activateView(active: true)
            
        }else{
            
            activateView(active: false)

            switch range {
                case oneMonth:
                    startDate   = dateFormatter.string(from : calendar.date(byAdding: .month,value: -1, to: date)!)
                                  break
                case threeMonth:
                    startDate   = dateFormatter.string(from : calendar.date(byAdding: .month,value: -3, to: date)!)
                                  break
                case sixMonth:
                    startDate   = dateFormatter.string(from : calendar.date(byAdding: .month,value: -6, to: date)!)
                                  break
                default:
                                  break
            }
            endDate             = dateFormatter.string(from: date)

            startDateLabel.text = startDate
            endDateLabel.text   = endDate
        }
        
    }

    private func activateView(active: Bool!) {
        
        switch active {
            case true  :    datepickerView.isHidden = false
                            datepickerView.visible()
                            startDatePicker.setDate(dateFormatter.date(from: startDateLabel.text!)! , animated: true)
                            endDatePicker.setDate(dateFormatter.date(from: endDateLabel.text!)! , animated: true)
                            break
            case false :    datepickerView.isHidden = true
                            datepickerView.gone()
                            
                            break
            default    :    break
        }
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
        
    }
    
    @IBAction func changeDate(_ sender: UIDatePicker) {
        
        var originalDate:String                                     = ""
        
        switch sender {
                        case startDatePicker :
                                                originalDate        = startDateLabel.text!
                                                startDateLabel.text = dateFormatter.string(from: sender.date)
                                                break
            
                        case endDatePicker   :
                                                originalDate        = endDateLabel.text!
                                                endDateLabel.text   = dateFormatter.string(from: sender.date)
                                                break
                        default:
                                                break
        }
        
        if(endDatePicker.date > Date()){
            
            endDatePicker.setDate(Date(), animated: true)
            endDateLabel.text   = dateFormatter.string(from: Date())
            
        }
        
        if(startDateLabel.text! > endDateLabel.text!){
            
            sender.setDate(dateFormatter.date(from: originalDate)! , animated: true)
            
            if sender == startDatePicker {
                startDateLabel.text = originalDate
            } else {
                endDateLabel.text   = originalDate
            }
            return
        }
        
    }

    @IBAction func adjustButton(_ sender: UIButton){
        
        let searchingHistoryConditionObject          = SearchingHistoryConditionObject()
        searchingHistoryConditionObject.startDate    = startDateLabel.text!
        searchingHistoryConditionObject.endDate      = endDateLabel.text!
        searchingHistoryConditionObject.sort         = sortArray[selectedSort]
        
        delegate?.searchingChargeConditionDelegate(data: searchingHistoryConditionObject)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func addButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject, targetViewController: AnyObject) {
        
        let button = CustomButton(type: .system)
        
        self.view.addSubview(button)
        
        button.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target, targetViewController: targetViewController)
    }
    
    
    @objc func closeButton(sender: UIButton!) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func refreshButton(sender: UIButton!) {
        
        setPeriodButton(oneMonth)
        setSortButton(asc)
    }
}
