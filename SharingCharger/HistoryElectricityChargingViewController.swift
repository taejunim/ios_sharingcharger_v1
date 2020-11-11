//
//  HistoryElectricityChargingViewController.swift
//  SharingCharger
//
//  Created by chihong an on 2020/08/31.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialBottomSheet
import Alamofire
import Toast_Swift

class HistoryElectricityChargingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchingChargeConditionProtocol {
    
    func searchingChargeConditionDelegate(data: SearchingHistoryConditionObject) {
        NotificationCenter.default.post(name: .updateChargeSearchingCondition, object: data, userInfo: nil)
    }
    
    
    @IBOutlet weak var tableView  : UITableView!
    
    var utils                     : Utils?
    var activityIndicator         : UIActivityIndicatorView?
    
    let rightMenuImage            : UIImage!  = UIImage(named: "menu_list")
    
    let dateFormatter                         = DateFormatter()
    let calendar                              = Calendar.current
    var date                                  = Date()
    
    let myUserDefaults                        = UserDefaults.standard
    
    var startDate                             = ""
    var endDate                               = ""
    var sort                                  = ""
    
    let size                                  = 10
    var page                                  = 1
    
    var moreLoadFlag                          = false
    
    var arr:[ChargingHistoryObject.InnerItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.locale        = Locale(identifier: "ko")
        dateFormatter.dateFormat    = "yyyy-MM-dd"
        
        startDate = dateFormatter.string(from : calendar.date(byAdding: .month,value: -1, to: date)!)
        endDate   = dateFormatter.string(from: date)
        sort      = "ASC"
        
        let rightBarButton = UIBarButtonItem.init(image: rightMenuImage ,style: .done, target: self, action: #selector(rightMenu))
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateChargeSearchingCondition(_:)), name: .updateChargeSearchingCondition, object: nil)
        
        //로딩 뷰
        utils             = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        self.activityIndicator!.hidesWhenStopped = true
        
        getChargingHistoryData()
        
        navigationItem.rightBarButtonItem   = rightBarButton
        
        self.tableView.delegate             = self
        self.tableView.dataSource           = self
        self.tableView.allowsSelection      = false

    }
    
    @objc func updateChargeSearchingCondition(_ notification: Notification) {
        
        let data = notification.object as! SearchingHistoryConditionObject
        
        startDate = data.startDate
        endDate   = data.endDate
        sort      = data.sort
        
        arr.removeAll()
        page      = 1
        getChargingHistoryData()

    }
    @objc func rightMenu() {
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchingChargeHistoryCondition") else { return }
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: tableView.frame.size.width, height: tableView.frame.size.height)
        
        let shapeGenerator = MDCCurvedRectShapeGenerator(cornerSize: CGSize(width: 15, height: 15))
        bottomSheet.setShapeGenerator(shapeGenerator, for: .preferred)
        bottomSheet.setShapeGenerator(shapeGenerator, for: .extended)
        bottomSheet.setShapeGenerator(shapeGenerator, for: .closed)
        
        present(bottomSheet, animated: true, completion: nil)
            
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let row = self.arr[indexPath.section]
        let Cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for:indexPath) as! HistoryElectricityTableCell
    
        if(row.chargerName != nil){
            Cell.chargingSpotNm?.text  = row.chargerName
        } else {
            Cell.chargingSpotNm?.text  = "충전기 이름 정보가 없습니다."
        }
        
        if(row.startRechargeDate == nil || row.endRechargeDate == nil){
            Cell.chargingDate?.text   = "충전 기간 정보가 유효하지 않습니다."
        } else {
            Cell.chargingDate?.text   = String(row.startRechargeDate!).replacingOccurrences(of: "T", with: " ") + " ~ " + String(row.endRechargeDate!).replacingOccurrences(of: "T", with: " ")
        }
        
        
        if(row.rechargePoint != nil){
            Cell.chargingUsePoint?.text = String(row.rechargePoint!) + " 포인트 사용"
        } else {
            Cell.chargingUsePoint?.text =  "포인트 사용 정보가 없습니다."
        }
        
        Cell.chargingSpotNm?.font = UIFont.systemFont(ofSize: 14)
        Cell.chargingDate?.font = UIFont.systemFont(ofSize: 14)
        Cell.chargingUsePoint?.font = UIFont.systemFont(ofSize: 14)
    
        if(indexPath[0] == arr.count-1 && moreLoadFlag){
            
            getChargingHistoryData()
        }
        
        return Cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return arr.count
    }

    func tableView(_ tableView:UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return 120
    }
    

    
    func getChargingHistoryData(){
        
        var code: Int!  = 0
        let url         = "http://211.253.37.97:8101/api/v1/recharges"
        
        let parameters: Parameters = [
            "sort"      :sort,
            "page"      :page,
            "size"      :size,
            "username"  :myUserDefaults.string(forKey: "email")!,
            "startDate" :startDate,
            "endDate"   :endDate
        ]
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
 
            switch response.result {
            
                case .success(let obj):
                
                do {

                        let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        let instanceData = try JSONDecoder().decode(ChargingHistoryObject.self, from: JSONData)
                        
                    if instanceData.numberOfElements != self.size {
                        
                        self.moreLoadFlag = false
                        
                    }else {
                        
                        self.moreLoadFlag = true
                        
                    }
                    for content in instanceData.content {
                        
                        self.arr.append(content)
                      
                    }
                    self.tableView.dataSource = self
                    
                    DispatchQueue.main.async {
                            
                        self.tableView.delegate             = self
                        self.tableView.dataSource           = self
                        self.tableView.allowsSelection      = false
                        self.tableView.reloadData()
                    }
                    
                    if(self.moreLoadFlag == false){
                        
                        self.activityIndicator!.stopAnimating()
                        return
                    }
                    
                    self.page += 1
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다. 고객센터로 문의주십시오. code : \(code!)")
                }
                
            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("400 Error.")
                    self.view.makeToast("400 Error", duration: 2.0, position: .bottom)

                } else {
                    print("Error : \(code!)")
                    self.view.makeToast("Error.", duration: 2.0, position: .bottom)
                }
            }
            
            self.activityIndicator!.stopAnimating()
        })
        
    }
    
}
extension Notification.Name {
    static let updateChargeSearchingCondition = Notification.Name("updateChargeSearchingCondition")
}
