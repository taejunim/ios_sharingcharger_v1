//
//  OwnerChargeViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/12/30.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import EvzBLEKit
import Alamofire
import Toast_Swift

class OwnerChargeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var searchInfos: Array<String> = []
    var bluetoothList: Array<String> = []
    
    @IBOutlet var chargeStart: UIButton!
    @IBOutlet var chargeEnd: UIButton!
    @IBOutlet var searchCharger: UIButton!
    
    @IBOutlet var tableView: UITableView!
    var currentSelectedRow: Int?
    var currentSelectedChargerId: Int?
    
    let myUserDefaults = UserDefaults.standard
    var reservationInfo: SearchingConditionObject?
    
    let locale = Locale(identifier: "ko")
    let dateFormatter = DateFormatter()
    let HHMMFormatter = DateFormatter()
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    let callCenterNumber = "064-725-6800"

    var isChargeStop = false
    
    var ownerChargerList = Array<OwnerCharger>()
    var reservationList = Array<Reservation>()

    @IBOutlet var chargingTimeLabel: UILabel!
    
    let rightMenuOrigin: UIImage! = UIImage(named: "setting")
    var rightMenuImage : UIImage?
    
    let menuSize = CGSize(width:25, height:25)
    
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
        
        HHMMFormatter.locale = locale
        HHMMFormatter.dateFormat = "HH:mm"
    
        let renderer = UIGraphicsImageRenderer(size: menuSize)
        rightMenuImage = renderer.image {_ in rightMenuOrigin.draw(in: CGRect(origin: .zero, size: menuSize))}
        let rightBarButton = UIBarButtonItem.init(image: rightMenuImage,style: .plain , target: self, action: #selector(rightMenu))
        rightBarButton.tintColor = UIColor.black
        navigationItem.rightBarButtonItem   = rightBarButton
    
    }
    
    private func checkReservationState() {
        
        //블루투스 권한 체크
        if hasBluetoothPermission() {

            //블루투스 on/off 체크
            if isOnBluetooth() {

                reservationList.removeAll()
                
                for index in 0 ..< ownerChargerList.count {
                    
                    getCurrentReservations(id: ownerChargerList[index].id)
                }

            } else {
                showAlert(title: "블루투스 꺼짐", message: "충전을 하기 위해서는 블루투스가 켜져 있어야 합니다.\n확인후 재시도 바랍니다.", positiveTitle: "설정", negativeTitle: "닫기")
            }

        } else {
            showAlert(title: "블루투스 사용 권한 없음", message: "기기 블루투스 사용 권한이 없습니다.\n확인후 재시도 바랍니다.", positiveTitle: "확인", negativeTitle: nil)
        }
    }
    
    //목록의 충전기 선택해서 연결
    @objc func connectCharger(sender: UITapGestureRecognizer) {
        
        if currentSelectedRow != nil && currentSelectedRow! >= 0 {
            let cell = tableView.cellForRow(at: [0, currentSelectedRow!]) as! ChargerCell
            cell.connectionLabel.isHidden = true
        }
        
        let index = sender.view?.tag
        
        //블루투스 권한 체크
        if hasBluetoothPermission() {
            
            //블루투스 on/off 체크
            if isOnBluetooth() {
                
                self.activityIndicator!.startAnimating()

                BleManager.shared.bleConnect(bleID: bluetoothList[index!])
                
            } else {
                showAlert(title: "블루투스 꺼짐", message: "충전을 하기 위해서는 블루투스가 켜져 있어야 합니다.\n확인후 재시도 바랍니다.", positiveTitle: "설정", negativeTitle: "닫기")
            }
            
        } else {
            showAlert(title: "블루투스 사용 권한 없음", message: "기기 블루투스 사용 권한이 없습니다.\n확인후 재시도 바랍니다.", positiveTitle: "확인", negativeTitle: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bluetoothList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.bluetoothList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChargerCustomCell", for:indexPath) as! ChargerCell
        
        let chargerBleNumberLabelGesture = UITapGestureRecognizer(target: self, action: #selector(self.connectCharger(sender:)))
        
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(chargerBleNumberLabelGesture)
        
        cell.chargerBleNumberLabel.tag = indexPath.row
        cell.chargerBleNumberLabel?.text = row
        cell.connectionLabel.isHidden = true
        cell.connectionLabel.layer.cornerRadius = cell.connectionLabel.frame.height / 2
        cell.connectionLabel.layer.masksToBounds = true
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    @objc func chargeStart(sender: UIView!) {
        
        print("chargeStart")
            
        //블루투스 권한 체크
        if hasBluetoothPermission() {
            
            //블루투스 on/off 체크
            if isOnBluetooth() {
                
                if currentSelectedRow! >= 0 {
                    reservationList.removeAll()
                    
                    getCurrentReservationsBeforeChargeStart(id: currentSelectedChargerId)
                } else {
                    showAlert(title: "충전기 연결 상태 확인", message: "충전기를 연결후 재시도 바랍니다.", positiveTitle: "확인", negativeTitle: nil)
                }
                
            } else {
                showAlert(title: "블루투스 꺼짐", message: "충전을 하기 위해서는 블루투스가 켜져 있어야 합니다.\n확인후 재시도 바랍니다.", positiveTitle: "설정", negativeTitle: "닫기")
            }
            
        } else {
            showAlert(title: "블루투스 사용 권한 없음", message: "기기 블루투스 사용 권한이 없습니다.\n확인후 재시도 바랍니다.", positiveTitle: "확인", negativeTitle: nil)
        }
    }
    
    private func getChargingTime(startDate: Date!, endDate: Date!) -> String {

        var chargingTime = ""
        
        let calendar = Calendar.current
        let offsetComps = calendar.dateComponents([.hour,.minute], from:startDate!, to:endDate!)
        if case let (hour?, minute?) = (offsetComps.hour, offsetComps.minute) {

            //30분
            if hour == 0 && minute != 0 {
                chargingTime = String(minute) + "분"

            }

            //1시간 .. 2시간
            else if hour != 0 && minute == 0 {
                chargingTime = String(hour) + "시간"
            }

            //1시간 30분 .. 2시간 30분
            else if hour != 0 && minute != 0 {
                chargingTime = String(hour) + "시간 " + String(minute) + "분"
            }
        }
        
        return chargingTime
    }
    
    private func ownerReservation(startDate: String!, endDate: String!) {
        
        self.activityIndicator!.startAnimating()
        
        let userId: Int = myUserDefaults.integer(forKey: "userId")
        
        var code: Int! = 0
        
        let url = "http://211.253.37.97:8101/api/v1/reservation"
        
        let parameters: Parameters = [
            "chargerId" : currentSelectedChargerId!,
            "startDate" : startDate!,
            "endDate" : endDate!,
            "cancelDate" : "",
            "expectPoint" : 0,
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
                        
                        print(instanceData.id)
                        print(instanceData.bleNumber)
                        print(instanceData.chargerId)
                        //예약 정보 가져오기
                        self.ownerChargeStart()
                        
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
    
    @objc func chargeEnd(sender: UIView!) {
        
        print("chargeEnd")
        
        //메모리에 저장된 예약 정보 가져와서 예약한 화면 구성
        if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
            let reservationInfo: SearchingConditionObject? = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
            
            //블루투스 권한 체크
            if hasBluetoothPermission() {
                
                //블루투스 on/off 체크
                if isOnBluetooth() {
                    
                    isChargeStop = true
                    BleManager.shared.bleConnect(bleID: reservationInfo!.bleNumber)
                    
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
        
        scanCharger()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getOwnerChargers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.activityIndicator!.stopAnimating()
    }
    
    //view 가 나타난 후
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
            
            reservationInfo = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
        }
        
        let isCharging = myUserDefaults.bool(forKey: "isCharging")
        
        //현재 충전중이고 충전 종료 버튼 클릭하면 자동으로 충전기 연결해서 종료 처리
        if isCharging {
            chargeStart.backgroundColor = UIColor(named: "Color_BEBEBE")
            chargeEnd.backgroundColor = UIColor(named: "Color_E74C3C")
        }
    }
    
    private func getOwnerChargers() {
        
        let hostId = myUserDefaults.integer(forKey: "userId")
        let hostType = myUserDefaults.string(forKey: "userType")
        
        var code: Int! = 0
        let url = "http://211.253.37.97:8101/api/v1/chargers/owner/\(hostId)/\(hostType!)"

        let parameters: Parameters = [
            
            "hostId": hostId,
            "hostType": hostType!,
            
            "sort":"ASC",
            "acceptType":"ALL",
            "currentStatusType":"ALL",
            "page":1,
            "size":10
        ]
        
        ownerChargerList.removeAll()
        
        AF.request(url, method: .get, parameters: parameters,  encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode

            switch response.result {
            
            case .success(let obj):
                
                do {
                    
                    let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let instanceData = try JSONDecoder().decode(OwnerChargersObject.self, from: JSONData)
                    
                    for content in instanceData.content {

                        var ownerCharger = OwnerCharger()
                        ownerCharger.id = content.id
                        ownerCharger.name = content.name
                        ownerCharger.bleNumber = content.bleNumber
                        print("content.id : \(content.id)")
                        print("content.name : \(content.name)")
                        print("content.address : \(content.address)")
                        
                        self.ownerChargerList.append(ownerCharger)
                    }
                    
                    self.scanCharger()
                    
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)")
                    self.view.makeToast("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", duration: 2.0, position: .bottom)
                }
                
            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("400 Error.")
                    self.view.makeToast("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", duration: 2.0, position: .bottom)
                    
                } else {
                    print("Unknown Error")
                    self.view.makeToast("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : 알 수 없는 오류", duration: 2.0, position: .bottom)
                }
            }
            
            self.activityIndicator!.stopAnimating()
        })
    }
    
    private func ownerChargeStart() {
        
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
                        self.reservationInfo = reservationInfo
                        
                        let chargerId: Int! = reservationInfo!.chargerId
                        let url = "http://211.253.37.97:8101/api/v1/recharge/authenticate/charger/\(chargerId!)"
                        
                        self.postChargeStartData(postUrl: url)
                    }
                    
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)")
                    self.activityIndicator!.stopAnimating()
                    
                    self.isChargeStop = false
                    self.myUserDefaults.set(0, forKey: "reservationId")
                    self.myUserDefaults.set(nil, forKey: "reservationInfo")
                    self.myUserDefaults.set(0, forKey: "rechargeId")
                    self.myUserDefaults.set(false, forKey: "isCharging")
                    
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
                    print("Unknown Error")
                }
                
                self.activityIndicator!.stopAnimating()
                
                self.isChargeStop = false
                self.myUserDefaults.set(0, forKey: "reservationId")
                self.myUserDefaults.set(nil, forKey: "reservationInfo")
                self.myUserDefaults.set(0, forKey: "rechargeId")
                self.myUserDefaults.set(false, forKey: "isCharging")
                
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
                    print("충전 시작 데이터 obj : \(obj)")
                    do {
                        //충전 시작
                        if url.contains("recharge/start") {
                            let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                            let instanceData = try JSONDecoder().decode(ChargeObject.self, from: JSONData)
                            
                            if instanceData.id! > 0 && code == 201 {
                                
                                let instanceDataId:Int = instanceData.id!
                                let tagId = String(format: "%13d", instanceDataId)
                                
                                if tagId != "" && tagId != "fail" && tagId != "false" {
                                    self.myUserDefaults.set(instanceDataId, forKey: "rechargeId")
                                    self.myUserDefaults.set(true, forKey: "isCharging")
                                    BleManager.shared.bleSetTag(tag: tagId)
                                    print("bleSetTag tagId : \(tagId)")
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
                        print("Unknown Error")
                    }
                    
                    self.showAlert(title: "충전 사용자 인증 실패", message: "충전을 위한 사용자 인증에 실패하였습니다.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                    return
                }
            })
        }
    }
    
    //충전 종료 데이터 서버로 전송
    private func postChargeEndData(postUrl: String!, rechargeId: Int!, rechargeMinute: Int!, rechargeKwh: Double!, count: Int!, index: Int!, tagId: String!) {
        
        self.activityIndicator!.startAnimating()
        
        let url = "\(postUrl!)"
        print("url : \(url)")
        
        let parameters: Parameters = [
            "rechargeId" : rechargeId!,
            "rechargeMinute" : rechargeMinute!,
            "rechargePoint" : 0,
            "rechargeKwh" : rechargeKwh!
        ]
        
        var code: Int! = 0
        
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default,headers: ["Content-Type":"application/json"], interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
            
            switch response.result {
            
            case .success(let obj):
                print("충전 종료 데이터 obj : \(obj)")
                do {
                    
                    let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let instanceData = try JSONDecoder().decode(ChargeObject.self, from: JSONData)
                    
                    //비정상적 충전 종료건들 데이터 전송
                    if url.contains("unplanned") {
                        
                        if instanceData.id! > 0 && code == 200 {
                            
                            self.isChargeStop = false
                            
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
                                self.showAlert(title: "충전 종료", message: "충전이 종료되었습니다.", positiveTitle: "확인", negativeTitle: nil)
                            }
                        }
                    }
                    
                    //충전 종료
                    else {
                        
                        if instanceData.id! > 0 && code == 200 {
                            
                            self.isChargeStop = false
                            self.myUserDefaults.set(0, forKey: "reservationId")
                            self.myUserDefaults.set(nil, forKey: "reservationInfo")
                            self.myUserDefaults.set(0, forKey: "rechargeId")
                            self.myUserDefaults.set(false, forKey: "isCharging")
                            
                            if tagId != "" && tagId != "fail" && tagId != "false" {
                                
                                BleManager.shared.bleDeleteTargetTag(tag: tagId)
                                
                            } else {
                                print("**************************")
                                print("태그 삭제 실패")
                                print("**************************")
                                self.showAlert(title: "충전 종료 오류", message: "충전 종료 오류가 발생했습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", positiveTitle: "확인", negativeTitle: nil)
                                return
                            }
                            
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
                    print("Unknown Error")
                }
                
                self.showAlert(title: "서버 에러", message: "서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", positiveTitle: "확인", negativeTitle: nil)
                return
            }
        })
    }
    
    //충전기 검색
    private func scanCharger() {
        
        //블루투스 권한 체크
        if hasBluetoothPermission() {
            
            //블루투스 on 상태
            if BleManager.shared.isOnBluetooth() {
                
                BleManager.shared.bleScan()
                
            } else {
                showAlert(title: "블루투스 꺼짐", message: "충전을 하기 위해서는 블루투스가 켜져 있어야 합니다.\n확인후 재시도 바랍니다.", positiveTitle: "설정", negativeTitle: "닫기")
            }
            
        } else {
            showAlert(title: "블루투스 사용 권한 없음", message: "기기 블루투스 사용 권한이 없습니다.\n확인후 재시도 바랍니다.", positiveTitle: "확인", negativeTitle: nil)
        }
    }
    
    //현재 예약 가져오기
    private func getCurrentReservations(id: Int!) {
        
        var code: Int! = 0
        let chargerId = id!
        let url = "http://211.253.37.97:8101/api/v1/reservations/chargers/\(chargerId)"
        
        let parameters: Parameters = [
            "chargerId":chargerId,
            "sort":"ASC",
            "page":1,
            "size":10
        ]
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
            
            switch response.result {
            
            case .success(let obj):
                
                print("obj : \(obj)")
                do {
                    
                    let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let instanceData = try JSONDecoder().decode(ReservationStateObject.self, from: JSONData)
                    
                    if instanceData.reservations.content.count > 0 {
                        for item in instanceData.reservations.content {
                            var reservation = Reservation()
                            reservation.id = item.id
                            reservation.bleNumber = item.bleNumber
                            reservation.startDate = item.startDate
                            reservation.endDate = item.endDate
                            
                            self.reservationList.append(reservation)
                        }
                        
                    } else {
                        print("reservationList size 0")
                    }
                    
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)")
                    self.view.makeToast("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", duration: 2.0, position: .bottom)
                }
                
            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("400 Error.")
                    self.view.makeToast("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", duration: 2.0, position: .bottom)
                    
                } else {
                    print("Unknown Error")
                    self.view.makeToast("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : 알 수 없는 오류", duration: 2.0, position: .bottom)
                }
            }
            
            self.activityIndicator!.stopAnimating()
            
            if self.bluetoothList.count == 1 {
                self.activityIndicator!.startAnimating()
                BleManager.shared.bleConnect(bleID: self.bluetoothList[0])
                self.currentSelectedRow = 0
            } else if self.bluetoothList.count > 1 {
                self.showAlert(title: "충전기 선택", message: "충전기를 선택하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
            } else {
                self.showAlert(title: "사용 가능한 충전기 없음", message: "근처에 사용 가능한 충전기가 없습니다.\n다시 검색하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
            }
        })
    }
    
    //충전 시작전 현재 예약 가져오기
    private func getCurrentReservationsBeforeChargeStart(id: Int!) {
        
        var code: Int! = 0
        let chargerId = id!
        let url = "http://211.253.37.97:8101/api/v1/reservations/chargers/\(chargerId)"
        
        let parameters: Parameters = [
            "chargerId":chargerId,
            "sort":"ASC",
            "page":1,
            "size":10
        ]
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
            
            switch response.result {
            
            case .success(let obj):
                
                print("obj : \(obj)")
                do {
                    
                    let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let instanceData = try JSONDecoder().decode(ReservationStateObject.self, from: JSONData)
                    
                    if instanceData.reservations.content.count > 0 {
                        for item in instanceData.reservations.content {
                            var reservation = Reservation()
                            reservation.id = item.id
                            reservation.bleNumber = item.bleNumber
                            reservation.startDate = item.startDate
                            reservation.endDate = item.endDate
                            
                            self.reservationList.append(reservation)
                        }
                        
                    } else {
                        print("reservationList size 0")
                    }
                    
                    let calendar = Calendar.current
                    let currentDate = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = self.locale
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    
                    //예약이 있을 때
                    if self.reservationList.count > 0 {
                        
                        var reservationDateArray:[Date] = []
                        
                        for item in self.reservationList {
                            if self.bluetoothList[self.currentSelectedRow!] == item.bleNumber {
                                reservationDateArray.append(dateFormatter.date(from: item.startDate!)!)
                                reservationDateArray.append(dateFormatter.date(from: item.endDate!)!)
                            }
                        }
                        reservationDateArray.append(currentDate)
                        reservationDateArray = reservationDateArray.sorted(by: <)
                        
                        for index in 0 ..< reservationDateArray.count {
                            print(reservationDateArray[index])
                        }

                        var startDate = ""
                        var endDate = ""
                        
                        //예약 1건 -> startDate, endDate, currentDate => Array는 3개
                        if reservationDateArray.count == 3 {

                            //ex) 현재 10:00, 예약 시작 시간 12:00, 예약 종료 시간 14:00
                            if currentDate == reservationDateArray[0] {
                                startDate = dateFormatter.string(from: currentDate)
                                
                                let tempEndDate = Calendar.current.date(byAdding: .minute, value: -30, to: reservationDateArray[1])
                                endDate = dateFormatter.string(from: tempEndDate!)
                            }
                            
                            //ex) 현재 13:00, 예약 시작 시간 12:00, 예약 종료 시간 14:00
                            else {
                                // 14:00 이후로 충전 가능합니다 메시지 띄우고 리턴
                                
                                self.activityIndicator!.stopAnimating()
                                
                                self.view.makeToast("\(self.HHMMFormatter.string(from: reservationDateArray[2])) 이후로 충전이 가능합니다", duration: 2.0, position: .bottom) {didTap in
                                    
                                    if didTap {
                                        print("tap")
                                        
                                    } else {
                                        print("without tap")
                                    }
                                }
                                return
                            }
                        }
                        //예약 1건 이상 -> ex) 예약 2건 이면 => Array 는 5개
                        else if reservationDateArray.count > 3 {
                            
                            var index = -1
                            
                            for i in 0 ..< reservationDateArray.count {
                                if currentDate == reservationDateArray[i] {
                                    index = i
                                    break
                                }
                            }
                            
                            //ex) 현재 10:00, 예약 시작 시간 12:00, 예약 종료 시간 14:00
                            if index == 0 {
                                if currentDate < reservationDateArray[index+1] {
                                    startDate = dateFormatter.string(from: currentDate)
                                    endDate = dateFormatter.string(from: reservationDateArray[index+1])
                                }
                            }
                            
                            //ex) 현재 13:00, 예약 시작 시간 12:00, 예약 종료 시간 14:00, 두 번째 예약 시작 시간 17:00, 두 번째 예약 종료 시간 19:00
                            //=> startDate : 14:00 , endDate : 17:00
                            else {
                                if currentDate < reservationDateArray[index+1] {
                                    startDate = dateFormatter.string(from: reservationDateArray[index+1])
                                    endDate = dateFormatter.string(from: reservationDateArray[index+2])
                                }
                            }
                        }
                        
                        let chargingTime = self.getChargingTime(startDate: dateFormatter.date(from: startDate), endDate: dateFormatter.date(from: endDate))
                        let refreshAlert = UIAlertController(title: "충전하기", message: "\(chargingTime) 동안 충전을 진행하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action: UIAlertAction!) in
                            
                        }))
                        
                        refreshAlert.addAction(UIAlertAction(title: "충전", style: .default, handler: { (action: UIAlertAction!) in
                            
                            self.ownerReservation(startDate: startDate, endDate: endDate)
                        }))
                        
                        self.present(refreshAlert, animated: true, completion: nil)
                    }
                    
                    //예약이 없을 때 => 기본 시간만큼 충전 가능
                    else {
                        let maximumEndDate = calendar.date(byAdding: .hour, value: 8, to: currentDate)
                        self.ownerReservation(startDate: dateFormatter.string(from: currentDate), endDate: dateFormatter.string(from: maximumEndDate!))
                        
                    }
                    
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)")
                    self.view.makeToast("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", duration: 2.0, position: .bottom)
                }
                
            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("400 Error.")
                    self.view.makeToast("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", duration: 2.0, position: .bottom)
                    
                } else {
                    print("Unknown Error")
                    self.view.makeToast("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : 알 수 없는 오류", duration: 2.0, position: .bottom)
                }
            }
            
            self.activityIndicator!.stopAnimating()
        })
    }
    
    @objc func rightMenu() {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Setting") else { return }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

struct OwnerCharger {
    var id: Int?
    var name: String?
    var bleNumber: String?
}

struct Reservation {
    var id: Int?
    var bleNumber: String?
    var startDate: String?
    var endDate: String?
}

extension OwnerChargeViewController: BleDelegate {
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
                        checkReservationState()
                    }
                }
                
                break
            case .BleNotScanList:
                print("근처에 사용 가능한 충전기가 없음\n")
                showAlert(title: "사용 가능한 충전기 없음", message: "근처에 사용 가능한 충전기가 없습니다.\n다시 검색하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                break
            case .BleConnect:
                guard let bleId = result as? String else {
                    
                    return
                }
                
                let isCharging = myUserDefaults.bool(forKey: "isCharging")
                
                for ownerChager in ownerChargerList {
                    
                    if ownerChager.bleNumber == bluetoothList[currentSelectedRow!] {
                        currentSelectedChargerId = ownerChager.id
                        break
                    }
                }
                
                print("충전기 접속 성공 : \(bleId)\n isCharging : \(isCharging) \n currentSelectedChargerId : \(currentSelectedChargerId!)")
                
                //현재 충전중이고 충전 종료 버튼 클릭하면 자동으로 충전기 연결해서 종료 처리
                if isCharging && isChargeStop {
                    
                    for index in 0 ..< bluetoothList.count {
                        print(">>>>>>>>>>>>>\(index)")
                        if bleId == bluetoothList[index] {
                            print(">>>>>>>>>>>>>>>>\(bluetoothList[index])")
                            currentSelectedRow = index
                            break
                        }
                    }
                    
                    BleManager.shared.bleChargerStop()
                }
                
                //충전기 접속했을 때
                else {
                    let cell = tableView.cellForRow(at: [0, currentSelectedRow!]) as! ChargerCell
                    cell.connectionLabel.isHidden = false
                    
                    chargeStart.backgroundColor = UIColor(named: "Color_3498DB")
                    
                    BleManager.shared.bleGetTag()
                }
                
                break
            case .BleDisconnect:
                print("충전기 접속 종료\n")
                let cell = tableView.cellForRow(at: [0, currentSelectedRow!]) as! ChargerCell
                cell.connectionLabel.isHidden = true
                //currentSelectedRow = nil
                
                chargeStart.backgroundColor = UIColor(named: "Color_BEBEBE")
                
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
                let url = "http://211.253.37.97:8101/api/v1/recharge/start/charger/\(chargerId!)"
                
                postChargeStartData(postUrl: url)
                
                chargeStart.backgroundColor = UIColor(named: "Color_BEBEBE")
                chargeEnd.backgroundColor = UIColor(named: "Color_E74C3C")

                break
            case .BleUnPlug:
                print("충전 시작 실패, 플러그 연결 확인 후 재 접속 후 충전을 시작해주세요.\n")
                // UnPlug 값이 넘어오면 충전기 접속 종료 처리 해줘야 함
                // 안 그럼 Stop 이벤트가 추가적으로 들어와서 문제가 될 수 있음
                BleManager.shared.bleDisConnect()
                chargeStart.backgroundColor = UIColor(named: "Color_BEBEBE")
                chargeEnd.backgroundColor = UIColor(named: "Color_BEBEBE")
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
                    
                    let isCharging = myUserDefaults.bool(forKey: "isCharging")
                    let rechargeId = myUserDefaults.integer(forKey: "rechargeId")
                    let chargerId: Int! = currentSelectedChargerId
                    
                    var index:Int! = 0
                    for data: EvzBLETagData in tags {
                        print("tagData : \(data.toString())\n")
                        
                        index += 1
                        print(".BleGetTag tagId : \(data.tagNumber)")
                        let tagNumber: Int! = Int(data.tagNumber.replacingOccurrences(of: " ", with: ""))
                        let useTime: Int! = Int(data.useTime.replacingOccurrences(of: " ", with: ""))
                        let kwh: Double! = Double(data.kwh.replacingOccurrences(of: " ", with: ""))
                        
                        var url = ""
                        
                        print("tagNumber : \(tagNumber!)")
                        print("isCharging : \(isCharging)")
                        print("isChargeStop : \(isChargeStop)")
                        
                        //충전중
                        if isCharging && !isChargeStop && tagNumber == rechargeId {
                            print("충전중")
                            chargeStart.backgroundColor = UIColor(named: "Color_BEBEBE")
                            chargeEnd.backgroundColor = UIColor(named: "Color_E74C3C")
                        }
                        
                        //충전 종료 눌렀을 때 충전 정보 서버로 전송
                        else if isCharging && isChargeStop && tagNumber == rechargeId {
                            url = "http://211.253.37.97:8101/api/v1/recharge/end/charger/\(chargerId!)"
                            postChargeEndData(postUrl: url, rechargeId: tagNumber!, rechargeMinute: useTime!, rechargeKwh: kwh!, count: tags.count, index: index!, tagId: data.tagNumber)
                        }
                        
                        //이전에 비정상적인 충전 종료한 정보들 서버로 전송
                        else if !isChargeStop && tagNumber != rechargeId {
                            url = "http://211.253.37.97:8101/api/v1/recharge/end/charger/\(chargerId!)/unplanned"
                            postChargeEndData(postUrl: url, rechargeId: tagNumber!, rechargeMinute: useTime!, rechargeKwh: kwh!, count: tags.count, index: index!, tagId: data.tagNumber)
                            
                        }
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