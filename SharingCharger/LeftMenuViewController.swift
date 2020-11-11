//
//  LeftMenuViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/09/28.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import Alamofire

class LeftMenuViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var pointLabel: UILabel!
    @IBOutlet var reservationStateLabel: UILabel!
    @IBOutlet var pointCharge: UIButton!
    @IBOutlet var chargingHistoryLabel: UILabel!
    @IBOutlet var pointHistoryLabel: UILabel!
    @IBOutlet var favoriteLabel: UILabel!
    @IBOutlet var callCenterLabel: UILabel!
    
    let myUserDefaults = UserDefaults.standard
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLeftMenu()
    }
    
    private func initializeLeftMenu() {
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        self.activityIndicator!.hidesWhenStopped = true
        
        pointCharge.addTarget(self, action: #selector(pointChargeButton(sender:)), for: .touchUpInside)
        nameLabel.text = myUserDefaults.string(forKey: "name")
        emailLabel.text = myUserDefaults.string(forKey: "email")
        
        let chargingHistoryGesture = UITapGestureRecognizer(target: self, action: #selector(self.chargingHistoryButton(_:)))
        chargingHistoryLabel.isUserInteractionEnabled = true
        chargingHistoryLabel.addGestureRecognizer(chargingHistoryGesture)
        
        let pointHistoryGesture = UITapGestureRecognizer(target: self, action: #selector(self.pointHistoryButton(_:)))
        pointHistoryLabel.isUserInteractionEnabled = true
        pointHistoryLabel.addGestureRecognizer(pointHistoryGesture)
        
        let favoriteGesture = UITapGestureRecognizer(target: self, action: #selector(self.favoriteButton(_:)))
        favoriteLabel.isUserInteractionEnabled = true
        favoriteLabel.addGestureRecognizer(favoriteGesture)
        
        let callCenterGesture = UITapGestureRecognizer(target: self, action: #selector(self.callCenterButton(_:)))
        callCenterLabel.isUserInteractionEnabled = true
        callCenterLabel.addGestureRecognizer(callCenterGesture)
    }
    
    private func getPoint() {
        
        self.activityIndicator!.startAnimating()
        
        var code: Int! = 0
        
        let userId = myUserDefaults.integer(forKey: "userId")
        let url = "http://211.253.37.97:8101/api/v1/point/users/\(userId)"
        
        print("url : \(url)")
        
        AF.request(url, method: .get, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
            
            switch response.result {
            
            case .success(let obj):
                
                self.activityIndicator!.stopAnimating()
                
                if code == 200 {
                    
                    let point: Int = obj as! Int
                    
                    self.pointLabel.text = self.setComma(value: point)
                    
                } else {
                    self.pointLabel.text = "-"
                }
                
            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("Error : \(code!)")
                    
                } else {
                    print("Error : \(code!)")
                }
                
                self.pointLabel.text = "-"
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
    
    private func getReservation() {
        
        self.activityIndicator!.startAnimating()
        
        let locale = Locale(identifier: "ko")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        var code: Int! = 0
        
        let userId = myUserDefaults.integer(forKey: "userId")
        let url = "http://211.253.37.97:8101/api/v1/reservation/user/\(userId)/currently"
        
        AF.request(url, method: .get, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
            
            switch response.result {
            
            case .success(let obj):
                
                do {
                    
                    let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let instanceData = try JSONDecoder().decode(ReservationObject.self, from: JSONData)
                    
                    if instanceData.id! > 0 && code == 200 {
                        let reservationInfo: SearchingConditionObject! = SearchingConditionObject()
                        reservationInfo.realChargingStartDate = instanceData.startDate!
                        reservationInfo.realChargingEndDate = instanceData.endDate!
                        reservationInfo.chargerAddress = instanceData.chargerAddress!
                        reservationInfo.chargerId = instanceData.chargerId!
                        reservationInfo.chargerName = instanceData.chargerName!
                        reservationInfo.fee = instanceData.rangeOfFee!
                        reservationInfo.bleNumber = instanceData.bleNumber!
                        
                        let calendar = Calendar.current
                        
                        let startDate = dateFormatter.date(from: instanceData.startDate!)
                        let endDate = dateFormatter.date(from: instanceData.endDate!)
                        
                        let offsetComps = calendar.dateComponents([.hour,.minute], from:startDate!, to:endDate!)
                        if case let (hour?, minute?) = (offsetComps.hour, offsetComps.minute) {
                            
                            //30분
                            if hour == 0 && minute != 0 {
                                reservationInfo.chargingTime = String(minute) + "분"
                                reservationInfo.realChargingTime = String(minute)
                            }
                            
                            //1시간 .. 2시간
                            else if hour != 0 && minute == 0 {
                                reservationInfo.chargingTime = String(hour) + "시간"
                                reservationInfo.realChargingTime = String(hour * 2 * 30)
                            }
                            
                            //1시간 30분 .. 2시간 30분
                            else if hour != 0 && minute != 0 {
                                reservationInfo.chargingTime = String(hour) + "시간 " + String(minute) + "분"
                                reservationInfo.realChargingTime = String(hour * 2 * 30 + minute)
                            }
                        }
                        
                        dateFormatter.dateFormat = "MM/dd (E) HH:mm"
                        
                        let dayOfStartDate = calendar.component(.day, from: startDate!)
                        let dayOfEndDate = calendar.component(.day, from: endDate!)
                        
                        if dayOfStartDate == dayOfEndDate {
                            
                            let timeFormatter = DateFormatter()
                            timeFormatter.locale = locale
                            timeFormatter.dateFormat = "HH:mm"
                            
                            let chargingEndDate = timeFormatter.string(from: endDate!)
                            reservationInfo.chargingPeriod = "\(dateFormatter.string(from: startDate!)) ~ \(chargingEndDate)"
                            
                        } else if dayOfStartDate != dayOfEndDate {
                            
                            reservationInfo.chargingPeriod = "\(dateFormatter.string(from: startDate!)) ~ \(dateFormatter.string(from: endDate!))"
                            
                        } else {
                            
                            reservationInfo.chargingPeriod = "\(dateFormatter.string(from: startDate!)) ~ \(dateFormatter.string(from: endDate!))"
                        }
                        
                        //현재 예약 정보 메모리에 저장
                        self.myUserDefaults.set(instanceData.id, forKey: "reservationId")
                        self.myUserDefaults.set(try? PropertyListEncoder().encode(reservationInfo), forKey: "reservationInfo")
                        
                        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
                        
                        self.reservationStateLabel.text = "\(dateFormatter.string(from: startDate!))\n\(instanceData.chargerName!)"
                    }
                    
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)")
                    self.activityIndicator!.stopAnimating()
                    
                    self.myUserDefaults.set(0, forKey: "reservationId")
                    self.myUserDefaults.set(nil, forKey: "reservationInfo")
                    
                    self.reservationStateLabel.text = ""
                    
                    let mainViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "Main") as! MainViewController
                    let navigationController = UINavigationController(rootViewController: mainViewController)
                    UIApplication.shared.windows.first?.rootViewController = navigationController
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
                
            //예약이 없을 때
            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("예약 없음")
                    
                } else {
                    print("Error : \(code!)")
                }
                
                self.activityIndicator!.stopAnimating()
                
                self.myUserDefaults.set(0, forKey: "reservationId")
                self.myUserDefaults.set(nil, forKey: "reservationInfo")
                
                self.reservationStateLabel.text = ""
            }
        })
    }
    
    @IBAction func settingButton(_ sender: Any) {
        print("LeftMenuViewController - Button tapped")
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Setting") else { return }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func pointChargeButton(sender: UIView!) {
        
        print("충전하기 이벤트")
        
    }
    
    @objc func chargingHistoryButton(_ sender: UITapGestureRecognizer) {
        
        print("chargingHistoryButton")
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChargingHistory") else { return }
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc func pointHistoryButton(_ sender: UITapGestureRecognizer) {
        
        print("pointHistoryButton")
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PointHistory") else { return }
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc func favoriteButton(_ sender: UITapGestureRecognizer) {
        
        print("favoriteButton")
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Favorite") else { return }
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc func callCenterButton(_ sender: UITapGestureRecognizer) {
        
        print("callCenterButton")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.black  //백버튼 검은색으로
        self.navigationController?.navigationBar.backItem?.title = ""       //백버튼 텍스트 제거
        self.navigationController?.navigationBar.barTintColor = .white      //navigationBar 배경 흰색으로
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        super.viewWillAppear(animated)
        
        //현재 포인트 가져오기
        getPoint()
        
        //현재 예약 가져오기
        getReservation()
    }
}
