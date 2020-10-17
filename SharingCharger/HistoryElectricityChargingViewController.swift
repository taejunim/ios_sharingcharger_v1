//
//  HistoryElectricityChargingViewController.swift
//  SharingCharger
//
//  Created by chihong an on 2020/08/31.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

class HistoryElectricityChargingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    let myUserDefaults = UserDefaults.standard
    
    var arr:[ReservationObject.InnerItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBarButton = UIBarButtonItem.init(title: "right", style: .done, target: self, action: #selector(rightMenu))
        
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
    
    
    @objc func rightMenu() {
        
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "Setting") else { return }
            
        self.navigationController?.pushViewController(uvc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let row = self.arr[indexPath.row]
        let Cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for:indexPath) as! HistoryElectricityTableCell
        
        Cell.chargingSpotNm?.text = row.chargerName
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
        let url = "http://test.jinwoosi.co.kr:6066/api/v1/reservations"
        
        /*let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"*/

        
        print(myUserDefaults.string(forKey: "email")!)
        let parameters: Parameters = [
            "sort":"ASC",
            "reservationType":"KEEP",
            "page":1,
            "size":10,
            //"username":myUserDefaults.string(forKey: "email")!,
            "username":"dd@gmail.com",
            "startDate":"2020-08-01",
            "endDate":"2020-10-20"
        ]
        
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
            
            switch response.result {
            
                case .success(let obj):
                
                do {
                
                    
                    
                    var JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let instanceData = try JSONDecoder().decode(ReservationObject.self, from: JSONData)
                    
                
                    
                    for content in instanceData.content {
                        
                        self.arr.append(content)
                      
                    }
                    self.tableView.dataSource = self
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    print("test : \(self.arr)")
                  

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
