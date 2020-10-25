//
//  ReservationViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/25.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import Alamofire

class ReservationViewController: UIViewController {
    
    @IBOutlet var chargingPeriodLabel: UILabel!
    @IBOutlet weak var myPoint: UILabel!
    @IBOutlet weak var confirmReservation: UIButton!
    
    var receivedSearchingConditionObject: SearchingConditionObject!
    var chargerId: Int = 0
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWillInitializeObjects()
    }
    
    private func viewWillInitializeObjects() {
        
        chargingPeriodLabel.text = receivedSearchingConditionObject.realChargingPeriod
        
        setMyPointLabel()
        
        confirmReservation.layer.cornerRadius = 7
        confirmReservation.addTarget(self, action: #selector(confirmReservation(sender:)), for: .touchUpInside)
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
    }
    
    @objc func setMyPointLabel() {
        
        myPoint.layer.cornerRadius = 7
    }
    
    @objc func confirmReservation(sender: UIButton!) {
        
        let userId: Int = UserDefaults.standard.integer(forKey: "userId")
        
        var code: Int! = 0
        
        let url = "http://test.jinwoosi.co.kr:6066/api/v1/reservation"
        
        let parameters: Parameters = [
            "chargerId" : chargerId,
            "startDate" : receivedSearchingConditionObject.realChargingStartDate,
            "endDate" : receivedSearchingConditionObject.realChargingEndDate,
            "cancelDate" : "",
            "expectPoint" : 250,
            "userId" : userId,
            "reservationType" : "RESERVE"
            
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
            
            switch response.result {
            
            case .success(let obj):
                
                print("obj : \(obj)")
                
                if code == 201 {
                    do {
                        
                        let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        
                        let instanceData = try JSONDecoder().decode(ReservationObject.self, from: JSONData)
                        print("instanceData : \(instanceData)")
                        print("receivedSearchingConditionObject : \(self.receivedSearchingConditionObject)")
                        
                        self.view.makeToast("예약이 완료되었습니다.", duration: 0.5, position: .bottom) {didTap in
                            
                            UserDefaults.standard.set(instanceData.id, forKey: "reservationId")
                            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.receivedSearchingConditionObject), forKey: "reservationInfo")
//
                            if didTap {
                                print("tap")
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                print("without tap")
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                    } catch {
                        print("error : \(error.localizedDescription)")
                        print("서버와 통신이 원활하지 않습니다. 고객센터로 문의주십시오. code : \(code!)")
                    }
                } else if code == 204 {
                    self.view.makeToast("사용자 또는 충전기가 존재하지 않습니다.\n다시 확인하여 주십시오", duration: 2.0, position: .bottom)
                }
                
            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("요청 파라미터가 올바르지 않습니다.")
                    self.view.makeToast("요청 파라미터가 올바르지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오.", duration: 2.0, position: .bottom)
                    
                } else {
                    print("서버와 통신이 원활하지 않습니다. 고객센터로 문의주십시오. code : \(code!)")
                    self.view.makeToast("서버와 통신이 원활하지 않습니다.\n고객센터로 문의주십시오.", duration: 2.0, position: .bottom)
                }
            }
            
            self.activityIndicator!.stopAnimating()
            self.activityIndicator!.isHidden = true
        })
    }
}
