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
        print("data.chargingPeriod : \(data.startDate)")
        print("data.sort : \(data.sort)")
        
        NotificationCenter.default.post(name: .updateChargeSearchingCondition, object: data, userInfo: nil)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    let myUserDefaults = UserDefaults.standard
    
    var arr:[ChargingHistoryObject.InnerItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBarButton = UIBarButtonItem.init(title: "right", style: .done, target: self, action: #selector(rightMenu))
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateChargeSearchingCondition(_:)), name: .updateChargeSearchingCondition, object: nil)
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        
        getChargingHistData()
        
        navigationItem.rightBarButtonItem = rightBarButton
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        
    }
    
    @objc func updateChargeSearchingCondition(_ notification: Notification) {
        
        let data = notification.object as! SearchingHistoryConditionObject
        print("data : \(data)")

    }
    @objc func rightMenu() {
        
        
        print("검색조건 -  tapped")
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchingChargeCondition") else { return }
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: tableView.frame.size.width, height: tableView.frame.size.height)
        
        let shapeGenerator = MDCCurvedRectShapeGenerator(cornerSize: CGSize(width: 15, height: 15))
        bottomSheet.setShapeGenerator(shapeGenerator, for: .preferred)
        bottomSheet.setShapeGenerator(shapeGenerator, for: .extended)
        bottomSheet.setShapeGenerator(shapeGenerator, for: .closed)
        
        present(bottomSheet, animated: true, completion: nil)
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let row = self.arr[indexPath.section]
        let Cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for:indexPath) as! HistoryElectricityTableCell
        

        
        
        Cell.chargingSpotNm?.text = row.chargerName
        
        if(row.startRechargeDate != nil && row.endRechargeDate != nil){
            Cell.chargingDate?.text   = String(row.startRechargeDate!).replacingOccurrences(of: "T", with: " ") + " ~ " + String(row.endRechargeDate!).replacingOccurrences(of: "T", with: " ")
        }
        if(row.rechargePoint != nil){
            Cell.chargingUsePoint?.text = String(row.rechargePoint!) + " 포인트 사용"
        }
        
        Cell.chargingSpotNm?.font = UIFont.systemFont(ofSize: 14)
        Cell.chargingDate?.font = UIFont.systemFont(ofSize: 14)
        Cell.chargingUsePoint?.font = UIFont.systemFont(ofSize: 14)
        
        return Cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return arr.count
    }

    func tableView(_ tableView:UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return 120
    }
    
    func getChargingHistData(){
        
        
        var code: Int! = 0
        let url = "http://test.jinwoosi.co.kr:6066/api/v1/recharges"
        
        /*let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"*/

        
        print(myUserDefaults.string(forKey: "email")!)
        let parameters: Parameters = [
            "sort":"ASC",
            "page":1,
            "size":10,
            "username":myUserDefaults.string(forKey: "email")!,
            "startDate":"2020-08-01",
            "endDate":"2020-10-20"
        ]
        
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
 
            switch response.result {
            
                case .success(let obj):
                
                do {
                

                    var JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        let instanceData = try JSONDecoder().decode(ChargingHistoryObject.self, from: JSONData)
                    
                
                        for content in instanceData.content {
                        
                            self.arr.append(content)
                      
                        }
                        self.tableView.dataSource = self
                    
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    
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
            self.activityIndicator!.isHidden = true
        })
        
    }
}
extension Notification.Name {
    static let updateChargeSearchingCondition = Notification.Name("updateChargeSearchingCondition")
}
