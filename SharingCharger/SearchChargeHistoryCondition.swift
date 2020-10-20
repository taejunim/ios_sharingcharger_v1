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
class SearchChargeHistoryCondition: UIViewController {
   
    var delegate: SearchingChargeConditionProtocol?
    
    @IBOutlet var oneMonth: UIButton!
    @IBOutlet var threeMonth: UIButton!
    @IBOutlet var sixMonth: UIButton!
    @IBOutlet var ownPeriod: UIButton!
    
    @IBOutlet var asc: UIButton!
    @IBOutlet var desc: UIButton!
    
    @IBOutlet var adjustButton: UIButton!
    
    var periodButtonArray: [UIButton] = []
    var sortButtonArray:   [UIButton] = []
    
    
    let sortArray: [String] = ["ASC", "DESC"]
    //var activityIndicator: UIActivityIndicatorView?
   
    let myUserDefaults = UserDefaults.standard

    let ColorEFEFEF: UIColor! = UIColor(named: "Color_7F7F7F")
    let Color3498DB: UIColor! = UIColor(named: "Color_3498DB")
    let ColorWhite:  UIColor! = UIColor.white
    
    var selectedSort = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.delegate = HistoryElectricityChargingViewController()
        
        periodButtonArray.append(oneMonth)
        periodButtonArray.append(threeMonth)
        periodButtonArray.append(sixMonth)
        periodButtonArray.append(ownPeriod)
        
        sortButtonArray.append(asc)
        sortButtonArray.append(desc)
        
        setButton()
    }
    
    func setButton(){
                
        for button in self.periodButtonArray {
            
            /*button.layer.borderWidth = 1
            button.layer.borderColor = ColorEFEFEF?.cgColor*/
            button.addTarget(self, action: #selector(setPeriod(_:)), for: .touchUpInside)
        }
        for button in self.sortButtonArray {
            
            button.addTarget(self, action: #selector(setSort(_:)), for: .touchUpInside)
        }
        
        adjustButton.addTarget(self, action: #selector(adjustButton(_:)), for: .touchUpInside)
        adjustButton.layer.cornerRadius = 7
    }
    
    @IBAction func setPeriod(_ sender: UIButton) {
    
    
        for index in 0...3 {
 
            if(index == periodButtonArray.firstIndex(of: sender)){
                
                periodButtonArray[index].layer.backgroundColor = Color3498DB?.cgColor
                periodButtonArray[index].setTitleColor(ColorWhite, for: .normal)
                
            } else{

                periodButtonArray[index].layer.backgroundColor = ColorWhite?.cgColor
                periodButtonArray[index].setTitleColor(ColorEFEFEF, for: .normal)
                
            }

        }
        

        onPeriodButtonClick()
    }
    @IBAction func setSort(_ sender: UIButton) {
        
        for index in 0...1 {
            if(index == sortButtonArray.firstIndex(of: sender)){
            
                sortButtonArray[index].layer.backgroundColor = Color3498DB?.cgColor
                sortButtonArray[index].setTitleColor(ColorWhite, for: .normal)
                selectedSort = index
            
            } else{

                sortButtonArray[index].layer.backgroundColor = ColorWhite?.cgColor
                sortButtonArray[index].setTitleColor(ColorEFEFEF, for: .normal)
            
            }
        }
        
    }
    
    func onPeriodButtonClick(){
        

        
        
    }
    func onSortButtonClick(){
        
        print("onSortButtonClick")

    }
    @IBAction func adjustButton(_ sender: UIButton){
        
        let searchingHistoryConditionObject = SearchingHistoryConditionObject()
        searchingHistoryConditionObject.startDate = "e됨?"
        searchingHistoryConditionObject.sort = sortArray[selectedSort]
        
        delegate?.searchingChargeConditionDelegate(data: searchingHistoryConditionObject)
        self.dismiss(animated: true, completion: nil)
    }
    
}
