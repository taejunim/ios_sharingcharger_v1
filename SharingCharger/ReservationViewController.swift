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
    
    @IBOutlet var chargerNameLabel: UILabel!
    @IBOutlet var chargingPeriodLabel: UILabel!
    @IBOutlet var currentPointLabel: UILabel!
    @IBOutlet var expectedPointLabel: UILabel!
    @IBOutlet var resultPointLabel: UILabel!
    @IBOutlet var reservationButton: UIButton!
    @IBOutlet var pointChargeButton: UIButton!
    
    let ColorE0E0E0: UIColor! = UIColor(named: "Color_E0E0E0")  //회색
    let Color3498DB: UIColor! = UIColor(named: "Color_3498DB")  //파랑
    let ColorE74C3C: UIColor! = UIColor(named: "Color_E74C3C")  //빨강
    
    var receivedSearchingConditionObject: SearchingConditionObject!
    var chargerId: Int = 0
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    let myUserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWillInitializeObjects()
    }
    
    private func viewWillInitializeObjects() {
        
        chargerNameLabel.text = receivedSearchingConditionObject.chargerName
        chargingPeriodLabel.text = receivedSearchingConditionObject.realChargingPeriod
        
        currentPointLabel.layer.cornerRadius = currentPointLabel.frame.height / 2
        reservationButton.layer.cornerRadius = 7
        reservationButton.addTarget(self, action: #selector(reservationButton(sender:)), for: .touchUpInside)
        
        pointChargeButton.layer.cornerRadius = 3
        pointChargeButton.addTarget(self, action: #selector(pointChargeButton(sender:)), for: .touchUpInside)
        pointChargeButton.isHidden        = true
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        self.activityIndicator!.hidesWhenStopped = true
    }
    
    private func getPoint(url: String!) {
        
        self.activityIndicator!.startAnimating()
        
        var code: Int! = 0
        
        let userId = myUserDefaults.integer(forKey: "userId")
        
        var parameters: Parameters!
        
        if url.contains("point/users") {
            parameters = [
                "userId" : userId
            ]
        } else if url.contains("point/chargers") {
            parameters = [
                "chargerId" : chargerId,
                "startDate" : receivedSearchingConditionObject.realChargingStartDate,
                "endDate" : receivedSearchingConditionObject.realChargingEndDate
            ]
        }
        
        AF.request(url, method: .get, parameters: parameters!, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
            
            switch response.result {
            
            case .success(let obj):
                
                self.activityIndicator!.stopAnimating()
                
                if code == 200 {
                    
                    let point: Int = obj as! Int
                    
                    if url.contains("point/users") {
                        
                        self.currentPointLabel.text = self.setComma(value: point) + " p"
                        
                        let expectedPointUrl = "http://211.253.37.97:8101/api/v1/point/chargers/\(self.chargerId)/calculate"
                        
                        self.getPoint(url: expectedPointUrl)
                        
                    } else if url.contains("point/chargers") {
                        
                        self.expectedPointLabel.text = self.setComma(value: point)
                        
                        if self.currentPointLabel.text != "-" && self.expectedPointLabel.text != "-" {
                            
                            let currentPoint: Int? = Int(self.currentPointLabel.text!.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: " p", with:""))
                            let expectedPoint = point
                            
                            self.resultPointLabel.text = self.setComma(value: currentPoint! - expectedPoint)
                            
                            self.setObject(enable : ( currentPoint! - expectedPoint ) >= 0)
                        
                            
                        }
                    }
                    
                } else {
                    self.currentPointLabel.text = "-"
                    
                    if url.contains("point/users") {
                        
                        self.currentPointLabel.text = "-"
                        
                    } else if url.contains("point/chargers") {
                        
                        self.expectedPointLabel.text = "-"
                    }
                }

            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("Error : \(code!)")
                    
                } else {
                    print("Error : \(code!)")
                }
                
                if url.contains("point/users") {
                    
                    self.currentPointLabel.text = "-"
                    
                } else if url.contains("point/chargers") {
                    
                    self.expectedPointLabel.text = "-"
                }
                
                self.activityIndicator!.stopAnimating()
            }
        })
    }
    
    private func setComma(value: Int) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: value))!
        
        return result
    }
    
    @objc func reservationButton(sender: UIButton!) {
        
        self.activityIndicator!.startAnimating()
        
        let userId: Int = myUserDefaults.integer(forKey: "userId")
        
        var code: Int! = 0
        
        let url = "http://211.253.37.97:8101/api/v1/reservation"
        
        let parameters: Parameters = [
            "chargerId" : chargerId,
            "startDate" : receivedSearchingConditionObject.realChargingStartDate,
            "endDate" : receivedSearchingConditionObject.realChargingEndDate,
            "cancelDate" : "",
            "expectPoint" : expectedPointLabel.text!.replacingOccurrences(of: ",", with: ""),
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
                        
                        self.receivedSearchingConditionObject.bleNumber = instanceData.bleNumber!
                        
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
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        print("viewWillAppear")
        
        //현재 포인트, 예상 포인트 가져오기
        let userId = myUserDefaults.integer(forKey: "userId")
        let currentPointUrl = "http://211.253.37.97:8101/api/v1/point/users/\(userId)"
        
        getPoint(url: currentPointUrl)
    }
    
    func setObject(enable : Bool){
    
        if enable {
            
            currentPointLabel.backgroundColor = Color3498DB
            resultPointLabel.textColor = Color3498DB
            reservationButton.backgroundColor = Color3498DB
            pointChargeButton.isHidden        = true
            reservationButton.isEnabled = true
            
        }else {
            
            currentPointLabel.backgroundColor = ColorE74C3C
            resultPointLabel.textColor = ColorE74C3C
            reservationButton.backgroundColor = ColorE0E0E0
            pointChargeButton.isHidden        = false
            reservationButton.isEnabled = false
            
        }

    }
    
    @objc func pointChargeButton(sender: UIView!) {
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PointCharge") else { return }
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}
