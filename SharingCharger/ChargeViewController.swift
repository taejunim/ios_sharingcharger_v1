//
//  ChargeViewController.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/10/06.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import EvzBLEKit
import Alamofire

class ChargeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var searchInfos: Array<String> = []
    var bluetoothList: Array<String> = []
    
    @IBOutlet var chargeStart: UIButton!
    @IBOutlet var chargeEnd: UIButton!
    @IBOutlet var searchCharger: UIButton!
    @IBOutlet var customerCenter: UIButton!
    
    @IBOutlet var tableView: UITableView!
    var currentSelectedRow: Int?
    
    let myUserDefaults = UserDefaults.standard
    var reservationInfo: SearchingConditionObject?
    
    let locale = Locale(identifier: "ko")
    let dateFormatter = DateFormatter()
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWillInitializeObjects()
    }
    
    private func viewWillInitializeObjects() {
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        self.activityIndicator!.hidesWhenStopped = true
        
        
        BleManager.shared.setBleDelegate(delegate: self)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
        
        chargeStart.layer.cornerRadius = chargeStart.frame.height / 2
        chargeEnd.layer.cornerRadius = chargeEnd.frame.height / 2
        searchCharger.layer.cornerRadius = 7
        
        chargeStart.addTarget(self, action: #selector(chargeStart(sender:)), for: .touchUpInside)
        chargeEnd.addTarget(self, action: #selector(chargeEnd(sender:)), for: .touchUpInside)
        searchCharger.addTarget(self, action: #selector(searchCharger(sender:)), for: .touchUpInside)
        customerCenter.addTarget(self, action: #selector(contactCustomerCenter(sender:)), for: .touchUpInside)
    }
    
    private func checkState() {
        
        //메모리에 저장된 예약 정보 가져와서 예약한 화면 구성
        if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
            
            reservationInfo = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
            
            //블루투스 권한 체크
            if hasBluetoothPermission() {
                
                //블루투스 on/off 체크
                if isOnBluetooth() {
                    
                    dateFormatter.locale = locale
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    //충전 종료 일시
                    let realChargingEndDate = dateFormatter.date(from: reservationInfo!.realChargingEndDate)
                    
                    //현재 시간이 예약 종료 일시 보다 작으면 충전할 수 있게
                    if Date() < realChargingEndDate! {
                        
                        if bluetoothList.count == 1 && reservationInfo!.bleNumber.replacingOccurrences(of: ":", with: "") == bluetoothList[0].replacingOccurrences(of: ":", with: "") {
                            currentSelectedRow = 0
                            BleManager.shared.bleConnect(bleID: bluetoothList[0])
                        } else if bluetoothList.count > 1 {
                            showAlert(title: "충전기 선택", message: "예약한 충전기를 연결하여 주십시오", positiveTitle: "확인", negativeTitle: nil)
                        } else {
                            showAlert(title: "사용 가능한 충전기 없음", message: "근처에 사용 가능한 충전기가 없습니다.\n다시 검색하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                        }
                    }
                    
                    //현재 시간이 예약 종료 일시보다 큰 경우 메모리의 예약 정보 초기화하고 검색조건 버튼 보이게
                    else {
                        
                        self.myUserDefaults.set(0, forKey: "reservationId")
                        self.myUserDefaults.set(nil, forKey: "reservationInfo")
                        showAlert(title: "충전 만료", message: "충전 시간이 만료되었습니다.\n다시 예약하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                    }
                    
                } else {
                    showAlert(title: "블루투스 꺼짐", message: "충전을 하기 위해서는 블루투스가 켜져 있어야 합니다.\n확인후 재시도 바랍니다.", positiveTitle: "설정", negativeTitle: "닫기")
                }
                
            } else {
                showAlert(title: "블루투스 사용 권한 없음", message: "기기 블루투스 사용 권한이 없습니다.\n확인후 재시도 바랍니다.", positiveTitle: "확인", negativeTitle: nil)
            }
            
        }
        
        //예약 정보가 없을 경우
        else {
            showAlert(title: "예약 정보 없음", message: "예약 정보가 존재하지 않습니다.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
        }
    }
    
    //목록의 충전기 선택해서 연결
    @objc func connectCharger(sender: UITapGestureRecognizer) {
        
        let index = sender.view?.tag
        
        //메모리에 저장된 예약 정보 가져와서 예약한 화면 구성
        if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
            let reservationInfo: SearchingConditionObject? = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
            
            //블루투스 권한 체크
            if hasBluetoothPermission() {
                
                //블루투스 on/off 체크
                if isOnBluetooth() {
                    
                    if reservationInfo!.bleNumber.replacingOccurrences(of: ":", with: "") != bluetoothList[index!].replacingOccurrences(of: ":", with: "")  {
                        showAlert(title: "잘못된 충전기", message: "예약한 충전기와 선택한 충전기가 다릅니다.\n다시 연결하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                        return;
                    }
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    
                    //충전 종료 일시
                    let realChargingEndDate = dateFormatter.date(from: reservationInfo!.realChargingEndDate)
                    
                    //현재 시간이 예약 종료 일시 보다 작으면 충전할 수 있게
                    if Date() < realChargingEndDate! {
                        
                        
                        
                        
                        self.activityIndicator!.startAnimating()
                        
                        BleManager.shared.bleConnect(bleID: bluetoothList[index!])
                        currentSelectedRow = index
                    }
                    
                    //현재 시간이 예약 종료 일시보다 큰 경우 메모리의 예약 정보 초기화하고 검색조건 버튼 보이게
                    else {
                        
                        self.myUserDefaults.set(0, forKey: "reservationId")
                        self.myUserDefaults.set(nil, forKey: "reservationInfo")
                        showAlert(title: "충전 만료", message: "충전 시간이 만료되었습니다.\n다시 예약하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                    }
                    
                } else {
                    showAlert(title: "블루투스 꺼짐", message: "충전을 하기 위해서는 블루투스가 켜져 있어야 합니다.\n확인후 재시도 바랍니다.", positiveTitle: "설정", negativeTitle: "닫기")
                }
                
            } else {
                showAlert(title: "블루투스 사용 권한 없음", message: "기기 블루투스 사용 권한이 없습니다.\n확인후 재시도 바랍니다.", positiveTitle: "확인", negativeTitle: nil)
            }
        }
        
        //예약 정보가 없을 경우
        else {
            showAlert(title: "예약 정보 없음", message: "예약 정보가 존재하지 않습니다.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bluetoothList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.bluetoothList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChargerCustomCell", for:indexPath) as! ChargerCell
        
        
        let chargerBleNumberLabelGesture = UITapGestureRecognizer(target: self, action: #selector(self.connectCharger(sender:)))
        cell.chargerBleNumberLabel?.isUserInteractionEnabled = true
        cell.chargerBleNumberLabel?.addGestureRecognizer(chargerBleNumberLabelGesture)
        cell.chargerBleNumberLabel.tag = indexPath.row
        cell.chargerBleNumberLabel?.text = row
        cell.connectionLabel.isHidden = true
        cell.connectionLabel.layer.cornerRadius = cell.connectionLabel.frame.height / 2
        cell.connectionLabel.layer.masksToBounds = true
        
        print("indexPath.row : \(indexPath.row)")
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    
    @objc func chargeStart(sender: UIView!) {
        
        print("chargeStart")
        
        //메모리에 저장된 예약 정보 가져와서 예약한 화면 구성
        if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
            let reservationInfo: SearchingConditionObject? = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
            
            //블루투스 권한 체크
            if hasBluetoothPermission() {
                
                //블루투스 on/off 체크
                if isOnBluetooth() {
                    
                    let chargerId: Int! = reservationInfo!.chargerId
                    let url = "http://test.jinwoosi.co.kr:6066/api/v1/recharge/authenticate/charger/\(chargerId!)"
                    
                    postChargeStartData(postUrl: url)
                    
                } else {
                    showAlert(title: "블루투스 꺼짐", message: "충전을 하기 위해서는 블루투스가 켜져 있어야 합니다.\n확인후 재시도 바랍니다.", positiveTitle: "설정", negativeTitle: "닫기")
                }
                
            } else {
                showAlert(title: "블루투스 사용 권한 없음", message: "기기 블루투스 사용 권한이 없습니다.\n확인후 재시도 바랍니다.", positiveTitle: "확인", negativeTitle: nil)
            }
        }
        
        //예약 정보가 없을 경우
        else {
            showAlert(title: "예약 정보 없음", message: "예약 정보가 존재하지 않습니다.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
        }
    }
    
    @objc func chargeEnd(sender: UIView!) {
        
        print("chargeEnd")
        
        //메모리에 저장된 예약 정보 가져와서 예약한 화면 구성
        if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
            
            //블루투스 권한 체크
            if hasBluetoothPermission() {
                
                //블루투스 on/off 체크
                if isOnBluetooth() {
                    
                    BleManager.shared.bleChargerStop()
                    
                } else {
                    showAlert(title: "블루투스 꺼짐", message: "충전을 하기 위해서는 블루투스가 켜져 있어야 합니다.\n확인후 재시도 바랍니다.", positiveTitle: "설정", negativeTitle: "닫기")
                }
                
            } else {
                showAlert(title: "블루투스 사용 권한 없음", message: "기기 블루투스 사용 권한이 없습니다.\n확인후 재시도 바랍니다.", positiveTitle: "확인", negativeTitle: nil)
            }
        }
        
        //예약 정보가 없을 경우
        else {
            showAlert(title: "예약 정보 없음", message: "예약 정보가 존재하지 않습니다.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
        }
    }
    
    @objc func searchCharger(sender: UIView!) {
        
        print("searchCharger")
        
        scanCharger()
        
    }
    
    @objc func contactCustomerCenter(sender: UIView!) {
        
        print("contactCustomerCenter")
        
    }
    
    private func hasBluetoothPermission() -> Bool {
        if BleManager.shared.hasPermission() {
            print("Permission : 블루투스 사용 권한 있음\n")
            return true
            
        } else {
            print("Permission : 블루투스 사용 권한 없음\n")
            return false
        }
    }
    
    private func isOnBluetooth() -> Bool {
        
        if BleManager.shared.isOnBluetooth() {
            print("Permission : 블루투스 ON\n")
            return true
            
        } else {
            print("Permission : 블루투스 OFF\n")
            return false
        }
    }
    
    private func showAlert(title: String?, message: String?, positiveTitle: String?, negativeTitle: String?) {
        
        self.activityIndicator!.stopAnimating()
        //self.activityIndicator!.isHidden = true
        
        //        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        //
        //        if positiveTitle != nil {
        //
        //            if positiveTitle == "설정" {
        //                refreshAlert.addAction(UIAlertAction(title: positiveTitle, style: .default,  handler: { (action: UIAlertAction!) in
        //
        //                    let url = URL(string: "App-Prefs:root=Bluetooth") //for bluetooth setting
        //                    let app = UIApplication.shared
        //                    app.open(url!)
        //                    self.dismiss(animated: true, completion: nil)
        //                }))
        //
        //            } else if positiveTitle != "설정" && title == "충전 종료" {
        //                refreshAlert.addAction(UIAlertAction(title: positiveTitle, style: .default,  handler: { (action: UIAlertAction!) in
        //
        //                    let mainViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "Main") as! MainViewController
        //                    let navigationController = UINavigationController(rootViewController: mainViewController)
        //                    UIApplication.shared.windows.first?.rootViewController = navigationController
        //                    UIApplication.shared.windows.first?.makeKeyAndVisible()
        //
        //                    self.dismiss(animated: true, completion: nil)
        //                }))
        //
        //            } else {
        //                refreshAlert.addAction(UIAlertAction(title: positiveTitle, style: .default,  handler: { (action: UIAlertAction!) in
        //
        //                    self.dismiss(animated: true, completion: nil)
        //                }))
        //            }
        //        }
        //
        //        if negativeTitle != nil {
        //            refreshAlert.addAction(UIAlertAction(title: negativeTitle, style: .cancel, handler: { (action: UIAlertAction!) in
        //                self.dismiss(animated: true, completion: nil)
        //            }))
        //        }
        //
        //
        //        if title == "충전 종료" {
        //            present(refreshAlert, animated: true, completion: {
        //                let mainViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "Main") as! MainViewController
        //                let navigationController = UINavigationController(rootViewController: mainViewController)
        //                UIApplication.shared.windows.first?.rootViewController = navigationController
        //                UIApplication.shared.windows.first?.makeKeyAndVisible()
        //            })
        //        } else {
        //            present(refreshAlert, animated: true, completion: nil)
        //        }
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        if positiveTitle != nil {
            
            if positiveTitle == "설정" {
                refreshAlert.addAction(UIAlertAction(title: positiveTitle, style: .default,  handler: { (action: UIAlertAction!) in
                    
                    let url = URL(string: "App-Prefs:root=Bluetooth") //for bluetooth setting
                    let app = UIApplication.shared
                    app.open(url!)
                    self.dismiss(animated: true, completion: nil)
                }))
                
            } else if positiveTitle != "설정" && title == "충전 종료" {
                refreshAlert.addAction(UIAlertAction(title: positiveTitle, style: .default,  handler: { (action: UIAlertAction!) in
                    
                    let mainViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "Main") as! MainViewController
                    let navigationController = UINavigationController(rootViewController: mainViewController)
                    UIApplication.shared.windows.first?.rootViewController = navigationController
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                    
                    self.dismiss(animated: true, completion: nil)
                }))
                
            } else {
                refreshAlert.addAction(UIAlertAction(title: positiveTitle, style: .default,  handler: { (action: UIAlertAction!) in
                    
                    self.dismiss(animated: true, completion: nil)
                }))
            }
        }
        
        if negativeTitle != nil {
            refreshAlert.addAction(UIAlertAction(title: negativeTitle, style: .cancel, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }))
        }
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    //view 가 나타난 후
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //예약 정보 가져오기
        getReservation()
    }
    
    private func getReservation() {
        
        self.activityIndicator!.startAnimating()
        //self.activityIndicator!.isHidden = false
        
        let locale = Locale(identifier: "ko")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        var code: Int! = 0
        
        let userId = myUserDefaults.integer(forKey: "userId")
        let url = "http://test.jinwoosi.co.kr:6066/api/v1/reservation/user/\(userId)/currently"
        
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
                        
                        self.scanCharger()
                    }
                    
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)")
                    self.activityIndicator!.stopAnimating()
                    
                    self.myUserDefaults.set(0, forKey: "reservationId")
                    self.myUserDefaults.set(nil, forKey: "reservationInfo")
                    
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
                
                let mainViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "Main") as! MainViewController
                let navigationController = UINavigationController(rootViewController: mainViewController)
                UIApplication.shared.windows.first?.rootViewController = navigationController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        })
    }
    
    //충전 시작 데이터 서버로 전송
    private func postChargeStartData(postUrl: String!) {
        
        self.activityIndicator!.startAnimating()
        
        //메모리에 저장된 예약 정보 가져와서 예약한 화면 구성
        if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
            
            reservationInfo = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
            
            let rechargeStartDate: String! = reservationInfo!.realChargingStartDate
            let reservationId:Int! = myUserDefaults.integer(forKey: "reservationId")
            let userId:Int! = myUserDefaults.integer(forKey: "userId")
            
            let url = "\(postUrl!)"
            
            let parameters: Parameters = [
                "rechargeStartDate" : rechargeStartDate!,
                "reservationId" : reservationId!,
                "userId" : userId!
            ]
            
            var code: Int! = 0
            
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"], interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
                
                code = response.response?.statusCode
                
                switch response.result {
                
                case .success(let obj):
                    print("충전 인증 데이터 obj : \(obj)")
                    do {
                        //충전 시작
                        if url.contains("recharge/start") {
                            let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                            let instanceData = try JSONDecoder().decode(ChargeObject.self, from: JSONData)
                            
                            if instanceData.id! > 0 && code == 201 {
                                
                                let instanceDataId:Int = instanceData.id!
                                let tagId = String(format: "%13d", instanceDataId)
                                
                                if tagId != "" && tagId != "fail" && tagId != "false" {
                                    BleManager.shared.bleSetTag(tag: tagId)
                                    return
                                } else {
                                    print("**************************")
                                    print("태그 세팅 실패")
                                    print("**************************")
                                    self.activityIndicator!.stopAnimating()
                                }
                            }
                        }
                        
                        //충전 시작전 인증
                        else if url.contains("recharge/authenticate") {
                            
                            print("obj as! Int : \(obj as! Int)")
                            
                            //정상 인증
                            if obj as! Int == 1 {
                                
                                let useTime = self.reservationInfo!.realChargingTime
                                BleManager.shared.bleChargerStart(useTime: useTime)
                                return
                            }
                            
                            //실패
                            else {
                                self.showAlert(title: "충전 사용자 인증 실패", message: "충전을 위한 사용자 인증에 실패하였습니다.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                                return
                            }
                        }
                        
                    } catch {
                        print("error : \(error.localizedDescription)")
                        print("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)")
                        
                        self.showAlert(title: "충전 사용자 인증 실패", message: "충전을 위한 사용자 인증에 실패하였습니다.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                        return
                    }
                    
                //실패
                case .failure(let err):
                    
                    print("response : \(response)")
                    print("error is \(String(describing: err))")
                    
                    if code == 400 {
                        print("실패")
                    } else {
                        print("Error : \(code!)")
                    }
                    
                    self.showAlert(title: "충전 사용자 인증 실패", message: "충전을 위한 사용자 인증에 실패하였습니다.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                    return
                }
            })
        }
    }
    
    //충전 종료 데이터 서버로 전송
    private func postChargeEndData(postUrl: String!, rechargeId: Int!, rechargeMinute: Int!, rechargeWh: Double!, count: Int!, index: Int!) {
        
        self.activityIndicator!.startAnimating()
        
        let url = "\(postUrl!)"
        
        let parameters: Parameters = [
            "rechargeId" : rechargeId!,
            "rechargeMinute" : rechargeMinute!,
            "rechargePoint" : 0,
            "rechargeWh" : rechargeWh!
        ]
        
        var code: Int! = 0
        
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default,headers: ["Content-Type":"application/json"], interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
            
            switch response.result {
            
            case .success(let obj):
                print("충전 인증 데이터 obj : \(obj)")
                do {
                    //충전 시작
                    if url.contains("recharge/end") {
                        let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        let instanceData = try JSONDecoder().decode(ChargeObject.self, from: JSONData)
                        
                        if instanceData.id! > 0 && code == 200 {
                            
                            self.myUserDefaults.set(0, forKey: "reservationId")
                            self.myUserDefaults.set(nil, forKey: "reservationInfo")
                            
                            let tagId = String(format: "%13d", rechargeId)
                            
                            if tagId != "" && tagId != "fail" && tagId != "false" {
                                BleManager.shared.bleDeleteTargetTag(tag: tagId)
                                
                            } else {
                                print("**************************")
                                print("태그 삭제 실패")
                                print("**************************")
                                self.showAlert(title: "서버 에러", message: "서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", positiveTitle: "확인", negativeTitle: nil)
                                return
                            }
                            
                            print("********************************")
                            print("count : \(count), index : \(index) ")
                            print("********************************")
                            if count == index {
                                self.showAlert(title: "충전 종료", message: "충전이 종료되었습니다.\n이용해주셔서 감사합니다.", positiveTitle: "확인", negativeTitle: nil)
                            }
                        }
                    }
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)")
                    
                    self.showAlert(title: "서버 에러", message: "서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", positiveTitle: "확인", negativeTitle: nil)
                    return
                }
                
            //실패
            case .failure(let err):
                
                print("response : \(response)")
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("실패")
                } else {
                    print("Error : \(code!)")
                }
                
                self.showAlert(title: "서버 에러", message: "서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", positiveTitle: "확인", negativeTitle: nil)
                return
            }
        })
    }
    
    //충전기 검색
    private func scanCharger() {
        
        let reservationId = self.myUserDefaults.integer(forKey: "reservationId")
        
        //예약 정보가 존재할 경우
        if reservationId > 0 {
            print("ChargeViewController reservationId : \(reservationId)")
            
            //블루투스 on 상태
            if BleManager.shared.isOnBluetooth() {
                
                BleManager.shared.bleScan()
                
            } else {
                showAlert(title: "블루투스 꺼짐", message: "충전을 하기 위해서는 블루투스가 켜져 있어야 합니다.\n확인후 재시도 바랍니다.", positiveTitle: "설정", negativeTitle: "닫기")
            }
        }
        
        //예약 정보가 없을 경우
        else {
            showAlert(title: "예약 정보 없음", message: "예약 정보가 존재하지 않습니다.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
        }
    }
    
}

extension ChargeViewController: BleDelegate {
    func bleResult(code: BleResultCode, result: Any?) {
        
        self.activityIndicator!.stopAnimating()
        
        switch code {
        case .BleAuthorized:
            print("블루투스 사용권한 획득한 상태\n")
            break
        case .BleUnAuthorized:
            print("블루투스 사용권한이 없거나 거부 상태\n")
            showAlert(title: "블루투스 사용 권한 없음", message: "기기 블루투스 사용 권한이 없습니다.\n확인후 재시도 바랍니다.", positiveTitle: "확인", negativeTitle: nil)
            break
        case .BleOff:
            print("블루투스 사용 설정이 꺼져있음\n")
            let url = URL(string: "App-Prefs:root=Bluetooth") //for bluetooth setting
            let app = UIApplication.shared
            app.open(url!)
            break
        case .BleScan:
            print("충전기 스캔 성공\n")
            BleManager.shared.bleScanStop()
            if let scanData = result as? [String] {
                self.searchInfos = scanData
                for bleID: String in self.searchInfos {
                    print("검색된 충전기 ID : \(bleID)\n")
                }
                
                bluetoothList = self.searchInfos
                
                self.tableView.reloadData()
                
                if bluetoothList.count > 0 {
                    checkState()
                }
            }
            
            break
        case .BleNotScanList:
            print("근처에 사용 가능한 충전기가 없음\n")
            showAlert(title: "사용 가능한 충전기 없음", message: "근처에 사용 가능한 충전기가 없습니다.\n다시 검색하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
            break
        case .BleConnect:
            guard let bleId = result as? String else {
                print("충전기 접속 성공\n")
                
                //connect -> getTag -> 서버로 보내고 -> delTag -> 인증 -> true 이면 시작 버튼 활성화
                //시작 누르면 -> bleStart -> success 뜨면 서버로 시작데이터 날리고 setTag ->
                return
            }
            print("충전기 접속 성공 : \(bleId)\n")
            
            let cell = tableView.cellForRow(at: [0, currentSelectedRow!]) as! ChargerCell
            cell.connectionLabel.isHidden = false
            
            chargeStart.backgroundColor = UIColor(named: "Color_3498DB")
            
            showAlert(title: "충전기 연결 성공", message: "\(bleId) 충전기와 연결되었습니다.", positiveTitle: "확인", negativeTitle: nil)
            
            BleManager.shared.bleGetTag()
            
            break
        case .BleDisconnect:
            print("충전기 접속 종료\n")
            let cell = tableView.cellForRow(at: [0, currentSelectedRow!]) as! ChargerCell
            cell.connectionLabel.isHidden = true
            currentSelectedRow = nil
            break
        case .BleScanFail:
            print("충전기 검색 실패\n")
            break
        case .BleConnectFail:
            print("충전기 접속 실패\n")
            break
        case .BleOtpCreateFail:
            print("OTP 생성 실패(서버에서 OTP 생성 실패)\n")
            break
        case .BleOtpAuthFail:
            print("OTP 인증 실패(서버에서 받은 OTP 정보로 인증 실패 함)\n")
            break
        case .BleAccessServiceFail:
            print("충전기와 서비스 인증정보 획득 실패\n")
            break
        case .BleChargeStart:
            print("충전 시작 성공\n")
            
            showAlert(title: "충전 시작", message: "충전이 시작되었습니다.\n충전이 완료될 때까지 플러그를 제거하지마십시오.", positiveTitle: "확인", negativeTitle: nil)
            
            let chargerId:Int! = reservationInfo!.chargerId
            let url = "http://test.jinwoosi.co.kr:6066/api/v1/recharge/start/charger/\(chargerId!)"
            
            postChargeStartData(postUrl: url)
            
            //            if tagId != "" && tagId != "fail" && tagId != "false" {
            //                BleManager.shared.bleSetTag(tag: tagId)
            //            } else {
            //                print("**************************")
            //                print("태그 세팅 실패")
            //                print("**************************")
            //                self.activityIndicator!.stopAnimating()
            //            }
            
            chargeStart.backgroundColor = UIColor(named: "Color_BEBEBE")
            chargeEnd.backgroundColor = UIColor(named: "Color_E74C3C")
            
            break
        case .BleUnPlug:
            print("충전 시작 실패, 플러그 연결 확인 후 재 접속 후 충전을 시작해주세요.\n")
            showAlert(title: "충전 시작 실패", message: "플러그 연결 확인 후 재접속 후 충전을 시작해주세요.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
            break
        case .BleAgainOtpAtuh:
            print("충전 시작 실패, 접속 종료 후 다시 충전기에 연결을 해주세요.\n")
            break
        case .BleChargeStop:
            print("충전 종료 성공\n")
            BleManager.shared.bleGetTag()
            break
        case .BleChargeStartFail:
            print("충전 시작 실패\n")
            showAlert(title: "충전 시작 실패", message: "충전 시작에 실패하였습니다.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
            break
        case .BleChargeStopFail:
            print("충전 종료 실패(태그 설정을 안하거나, 정상 종료처리가 안되었음)\n")
            break
        case .BleSetTag:
            print("태그 설정 성공\n")
            break
        case .BleGetTag:
            print("태그 정보 획득 성공\n")
            
            if let tags = result as? [EvzBLETagData] {
                
                var index:Int! = 0
                for data: EvzBLETagData in tags {
                    print("tagData : \(data.toString())\n")
                    
                    index += 1
                    
                    let tagNumber: Int! = Int(data.tagNumber.replacingOccurrences(of: " ", with: ""))
                    let useTime: Int! = Int(data.useTime.replacingOccurrences(of: " ", with: ""))
                    let kwh: Double! = Double(data.kwh.replacingOccurrences(of: " ", with: ""))
                    
                    //                        print("tagNumber : \(tagNumber)")
                    //                        print("kwh : \(kwh)")
                    //                        print("useTime : \(useTime)")
                    
                    //                        myUserDefaults.set(tagNumber!, forKey: "tagNumber")
                    //                        myUserDefaults.set(kwh!, forKey: "kwh")
                    //                        myUserDefaults.set(useTime!, forKey: "useTime")
                    
                    let chargerId: Int! = reservationInfo!.chargerId
                    let url = "http://test.jinwoosi.co.kr:6066/api/v1/recharge/end/charger/\(chargerId!)"
                    
                    postChargeEndData(postUrl: url, rechargeId: tagNumber!, rechargeMinute: useTime!, rechargeWh: kwh!, count: tags.count, index: index!)
                }
            }
            
            break
        case .BleAllDeleteTag:
            print("전체 태그 삭제 성공\n")
            break
        case .BleDeleteTag:
            print("선택 태그 삭제 성공\n")
            break
        case .BleSetTagFail:
            print("태그 설정 실패\n")
            break
        case .BleWrongTagLength:
            print("설정 태그 길이가 13자가 넘음\n")
            break
        case .BleGetTagFail:
            print("태그 정보 획득 실패\n")
            break
        case .BleAllDeleteTagFail:
            print("전체 태그 삭제 실패\n")
            break
        case .BleDeleteTagFail:
            print("선택 태그 삭제 실패\n")
            break
        case .BleNotConnect:
            print("충전기에 접속이 안되어있음\n")
            break
        case .BleUnknownError:
            print("알수 없는 에러\n")
            break
        case .BleUnSupport:
            print("블루투스가 지원 안됨\n")
            break
        default:
            
            break
        }
    }
}
