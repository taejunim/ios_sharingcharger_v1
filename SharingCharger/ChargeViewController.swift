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
    
    @IBOutlet var tableView: UITableView!
    var currentSelectedRow: Int?
    
    @IBOutlet var chargeId: UILabel!
    @IBOutlet var chargingTimeLabel: UILabel!
    
    let myUserDefaults = UserDefaults.standard
    var reservationInfo: SearchingConditionObject?
    
    let locale = Locale(identifier: "ko")
    let dateFormatter = DateFormatter()
    let clockDateFormatter = DateFormatter()
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?

    var isChargeStop = false

    let clockInterval = 1.0
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWillInitializeObjects()

        dateFormatter.locale = locale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

    }
    
    private func viewWillInitializeObjects() {
        
        clockDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        clockDateFormatter.locale = locale
        timer = Timer.scheduledTimer(timeInterval: clockInterval, target: self, selector: #selector(setClock), userInfo: nil, repeats: true)
        
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
        
        let margin = chargeStart.frame.width * 0.2
        let bottomMargin = chargeStart.frame.width * 0.15
        chargeStart.setImage(UIImage(named: "charge_start"), for: .normal)
        chargeStart.imageEdgeInsets = UIEdgeInsets(top: margin, left: margin, bottom: bottomMargin, right: margin)
        chargeEnd.setImage(UIImage(named: "charge_end"), for: .normal)
        chargeEnd.imageEdgeInsets = UIEdgeInsets(top: margin, left: margin, bottom: bottomMargin, right: margin)
        
        chargeStart.addTarget(self, action: #selector(chargeStart(sender:)), for: .touchUpInside)
        chargeEnd.addTarget(self, action: #selector(chargeEnd(sender:)), for: .touchUpInside)
        searchCharger.addTarget(self, action: #selector(searchCharger(sender:)), for: .touchUpInside)
        
    }
    
    private func checkState() {
        
        //메모리에 저장된 예약 정보 가져와서 예약한 화면 구성
        if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
            
            reservationInfo = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
            
            //블루투스 권한 체크
            if hasBluetoothPermission() {
                
                //블루투스 on/off 체크
                if isOnBluetooth() {
                    
                    //충전 종료 일시
                    let realChargingEndDate = dateFormatter.date(from: reservationInfo!.realChargingEndDate)
                    
                    //현재 시간이 예약 종료 일시 보다 작으면 충전할 수 있게
                    if Date() < realChargingEndDate! {
                        
                        if bluetoothList.count == 1 && reservationInfo!.bleNumber == bluetoothList[0] {
                            self.activityIndicator!.startAnimating()
                            currentSelectedRow = 0
                            BleManager.shared.bleConnect(bleID: bluetoothList[0])
                        } else if bluetoothList.count > 1 {
                            showAlert(title: "충전기 선택", message: "예약한 충전기를 연결하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                        } else {
                            showAlert(title: "사용 가능한 충전기 없음", message: "근처에 사용 가능한 충전기가 없습니다.\n다시 검색하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                        }
                    }
                    
                    //현재 시간이 예약 종료 일시보다 큰 경우 종료 처리
                    else {
                        
                        isChargeStop = true
                        BleManager.shared.bleConnect(bleID: reservationInfo!.bleNumber)
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
        
        if currentSelectedRow != nil && currentSelectedRow! >= 0 {
            removeConnectedLabel()
        }
        
        let index = sender.view?.tag
        
        //메모리에 저장된 예약 정보 가져와서 예약한 화면 구성
        if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
            let reservationInfo: SearchingConditionObject? = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
            
            //블루투스 권한 체크
            if hasBluetoothPermission() {
                
                //블루투스 on/off 체크
                if isOnBluetooth() {
                    if reservationInfo!.bleNumber != bluetoothList[index!]  {
                        showAlert(title: "잘못된 충전기", message: "예약한 충전기와 선택한 충전기가 다릅니다.\n다시 연결하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                        return;
                    }
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    
                    //충전 종료 일시
                    let realChargingEndDate = dateFormatter.date(from: reservationInfo!.realChargingEndDate)
                    
                    //현재 시간이 예약 종료 일시 보다 작으면 충전할 수 있게
                    if Date() < realChargingEndDate! {
                        
                        self.activityIndicator!.startAnimating()
                        print("bluetoothList[index!] \(bluetoothList[index!])")
                        BleManager.shared.bleConnect(bleID: bluetoothList[index!])
                        currentSelectedRow = index
                    }
                    
                    //현재 시간이 예약 종료 일시보다 큰 경우 종료 처리
                    else {
                        
                        isChargeStop = true
                        BleManager.shared.bleConnect(bleID: reservationInfo!.bleNumber)
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
        var showBleNumber = ""
        
        if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
            
            reservationInfo = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
           
            if row == reservationInfo?.bleNumber {
                
                if let chargerName = reservationInfo?.chargerName {
                    cell.chargerNameLabel?.text = chargerName + " - "
                }
                
                let bleNumber = String(row.replacingOccurrences(of: ":", with: ""))
                let startIndex = bleNumber.index(bleNumber.endIndex, offsetBy: -4)
                showBleNumber = String(bleNumber[startIndex...])
                cell.chargerBleNumberLabel?.text = showBleNumber
                
            } else {
                
                showBleNumber = row
                cell.chargerNameLabel?.text = row
                cell.chargerBleNumberLabel?.text = ""
            }
            
            if let chargerAddress = reservationInfo?.chargerAddress {
                cell.addressLabel?.text = chargerAddress
            }
            
            if let startDate = reservationInfo?.realChargingStartDate {
                cell.startDateLabel?.text = getChargingPeriod(date: startDate)
            }
            
            if let endDate = reservationInfo?.realChargingEndDate {
                cell.endDateLabel?.text = getChargingPeriod(date: endDate)
            }
        }
        
        let chargerBleNumberLabelGesture = UITapGestureRecognizer(target: self, action: #selector(self.connectCharger(sender:)))
        cell.itemView?.isUserInteractionEnabled = true
        cell.itemView?.addGestureRecognizer(chargerBleNumberLabelGesture)
        cell.itemView.tag = indexPath.row
        
        return cell
    }
    
    func getChargingPeriod(date: String) -> String {
        let dateString = date.replacingOccurrences(of: "T", with: " ")
        
        let dateFirstIndex = dateString.index(dateString.startIndex, offsetBy: 0)
        let dateLastIndex = dateString.index(dateString.startIndex, offsetBy: 16)
        
        return "\(dateString[dateFirstIndex..<dateLastIndex])"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    @objc func chargeStart(sender: UIView!) {
        
        print("chargeStart")
        
        if currentSelectedRow! >= 0 {
            //메모리에 저장된 예약 정보 가져와서 예약한 화면 구성
            if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
                let reservationInfo: SearchingConditionObject? = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
                
                let isCharging = myUserDefaults.bool(forKey: "isCharging")
                
                if isCharging {
                    self.view.makeToast("현재 충전 진행중입니다.\n문제 발생시 고객센터로 문의주십시오.", duration: 2.0, position: .bottom)
                } else {
                
                    //블루투스 권한 체크
                    if hasBluetoothPermission() {
                        
                        //블루투스 on/off 체크
                        if isOnBluetooth() {
                            
                            let chargerId: Int! = reservationInfo!.chargerId
                            let url = "http://211.253.37.97:8101/api/v1/recharge/authenticate/charger/\(chargerId!)"
                            
                            postChargeStartData(postUrl: url)
                            
                        } else {
                            showAlert(title: "블루투스 꺼짐", message: "충전을 하기 위해서는 블루투스가 켜져 있어야 합니다.\n확인후 재시도 바랍니다.", positiveTitle: "설정", negativeTitle: "닫기")
                        }
                        
                    } else {
                        showAlert(title: "블루투스 사용 권한 없음", message: "기기 블루투스 사용 권한이 없습니다.\n확인후 재시도 바랍니다.", positiveTitle: "확인", negativeTitle: nil)
                    }
                }
            }
            
            //예약 정보가 없을 경우
            else {
                showAlert(title: "예약 정보 없음", message: "예약 정보가 존재하지 않습니다.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
            }
        } else {
            showAlert(title: "충전 시작 실패", message: "충전기와 연결이 되어 있지 않습니다.\n예약한 충전기를 연결하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
        }
        
    }
    
    @objc func chargeEnd(sender: UIView!) {
        
        endCharging()
    }
    
    private func endCharging() {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        self.activityIndicator!.stopAnimating()        
    }
    
    //view 가 나타난 후
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //예약 정보 가져오기
        getReservation()
    
        //충전기 연걸, 충전 시작, 충전 종료 버튼 색 변경&클릭 불가 처리, 충전중이면 충전기 연결 버튼 회색으로 변경하고 클릭 불가
        switchSearchCharger()
    }
    
    //충전기 연걸, 충전 시작, 충전 종료 버튼 색 변경&클릭 불가 처리, 충전중이면 충전기 연결 버튼 회색으로 변경하고 클릭 불가
    private func switchSearchCharger() {
        
        self.activityIndicator!.stopAnimating()
        
        let isCharging = myUserDefaults.bool(forKey: "isCharging")
        
        if isCharging {
            searchCharger.backgroundColor = UIColor(named: "Color_BEBEBE")
            searchCharger.isEnabled = false
            
            chargeStart.backgroundColor = UIColor(named: "Color_BEBEBE")
            chargeStart.isEnabled = false
            
            chargeEnd.backgroundColor = UIColor(named: "Color_E74C3C")
            chargeEnd.isEnabled = true
        } else {
            searchCharger.backgroundColor = UIColor(named: "Color_69AD93")
            searchCharger.isEnabled = true
            
            chargeStart.backgroundColor = UIColor(named: "Color_3498DB")
            chargeStart.isEnabled = true
            
            chargeEnd.backgroundColor = UIColor(named: "Color_BEBEBE")
            chargeEnd.isEnabled = false
        }
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
                        
                        self.scanCharger()
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
                    self.myUserDefaults.set(nil, forKey: "startRechargeDate")
                    self.myUserDefaults.set(nil, forKey: "endRechargeDate")
                    self.myUserDefaults.set(0, forKey: "reservationPoint")
                    
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
                self.myUserDefaults.set(nil, forKey: "startRechargeDate")
                self.myUserDefaults.set(nil, forKey: "endRechargeDate")
                self.myUserDefaults.set(0, forKey: "reservationPoint")
                
                let mainViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "Main") as! MainViewController
                let navigationController = UINavigationController(rootViewController: mainViewController)
                UIApplication.shared.windows.first?.rootViewController = navigationController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
            
            //충전기 연걸, 충전 시작, 충전 종료 버튼 색 변경&클릭 불가 처리, 충전중이면 충전기 연결 버튼 회색으로 변경하고 클릭 불가
            self.switchSearchCharger()
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
                                    self.chargeId.text = "충전 번호 : \(String(instanceDataId))"
                                    self.chargeId.isHidden = false
                                    self.myUserDefaults.set(instanceDataId, forKey: "rechargeId")
                                    self.myUserDefaults.set(true, forKey: "isCharging")
                                    self.myUserDefaults.set(instanceData.reservationPoint, forKey: "reservationPoint")
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
                                
                                let calendar = Calendar.current
                                let currentDate = Date()
                                let endDate = self.dateFormatter.date(from: self.reservationInfo!.realChargingEndDate)
                                
                                let offsetComps = calendar.dateComponents([.minute], from:currentDate, to:endDate!)
                                if case let (minute?) = (offsetComps.minute) {
                                    
                                    let useTime = String(minute)
                                    BleManager.shared.bleChargerStart(useTime: useTime)
                                }
                                
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
                                
                                //충전기 연걸, 충전 시작, 충전 종료 버튼 색 변경&클릭 불가 처리, 충전중이면 충전기 연결 버튼 회색으로 변경하고 클릭 불가
                                self.switchSearchCharger()
                                
                                self.showAlert(title: "서버 에러", message: "서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", positiveTitle: "확인", negativeTitle: nil)
                                return
                            }
                            
                            print("********************************")
                            print("비정상적 충전 종료 count : \(count!), index : \(index!) ")
                            print("********************************")
                        }
                    }
                    
                    //충전 종료
                    else {
                        
                        let startRechargeDate = self.myUserDefaults.string(forKey: "startRechargeDate")
                        if instanceData.id! > 0 && code == 200 {
                            
                            self.isChargeStop = false
                            self.myUserDefaults.set(0, forKey: "reservationId")
                            self.myUserDefaults.set(nil, forKey: "reservationInfo")
                            self.myUserDefaults.set(0, forKey: "rechargeId")
                            self.myUserDefaults.set(false, forKey: "isCharging")
                            self.myUserDefaults.set(nil, forKey: "startRechargeDate")
                            self.myUserDefaults.set(nil, forKey: "endRechargeDate")
                            self.myUserDefaults.set(0, forKey: "reservationPoint")
                            
                            if tagId != "" && tagId != "fail" && tagId != "false" {
                                
                                BleManager.shared.bleDeleteTargetTag(tag: tagId)
                                
                            } else {
                                print("**************************")
                                print("태그 삭제 실패")
                                print("**************************")
                                
                                //충전기 연걸, 충전 시작, 충전 종료 버튼 색 변경&클릭 불가 처리, 충전중이면 충전기 연결 버튼 회색으로 변경하고 클릭 불가
                                self.switchSearchCharger()
                                
                                self.showAlert(title: "충전 종료 오류", message: "충전 종료 오류가 발생했습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", positiveTitle: "확인", negativeTitle: nil)
                                return
                            }
                            
                            if count == index {
                                self.showChargeEndPopup(result : instanceData, startRechargeDate: startRechargeDate!)
                            }
                        }
                    }
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)")
                
                    //충전기 연걸, 충전 시작, 충전 종료 버튼 색 변경&클릭 불가 처리, 충전중이면 충전기 연결 버튼 회색으로 변경하고 클릭 불가
                    self.switchSearchCharger()
                    
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
                //충전기 연걸, 충전 시작, 충전 종료 버튼 색 변경&클릭 불가 처리, 충전중이면 충전기 연결 버튼 회색으로 변경하고 클릭 불가
                self.switchSearchCharger()
                
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
    
    func showChargeEndPopup(result : ChargeObject, startRechargeDate : String) {
        
        let viewController:ChargeEndPopupViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChargeEndPopup") as! ChargeEndPopupViewController
        viewController.preferredContentSize = CGSize(width: view.frame.size.width, height: 1.2 * view.frame.size.height / 2)
        
        let realStartDate = dateFormatter.date(from: startRechargeDate)
        let date = Date()
        var diff = Int((date.timeIntervalSince(realStartDate!)))
        var timerText = ""
        
        let hour = (diff/3600)
        if hour < 10 {
            timerText = "0" + String(hour) + ":"
        } else {
            timerText = String(hour) + ":"
        }
            
        diff = diff % 3600
            
        let minute = (diff/60)
            
        if minute < 10{
            timerText += "0"
            timerText += String(minute)
        } else {
            timerText += String(minute)
        }
        timerText += ":"
    
        let second = (diff%60)
            
        if second < 10 {
            timerText += "0" + String(second)
        }else {
            timerText += String(second)
        }
        
        viewController.reservationPoint = result.reservationPoint!
        viewController.refundPoint = result.reservationPoint! - result.rechargePoint!
        viewController.realUsedPoint = result.rechargePoint!
        viewController.startRechargeDate = startRechargeDate.replacingOccurrences(of: "T", with: " ")
        viewController.endRechargeDate = clockDateFormatter.string(from: date)
        viewController.rechargePeriod = timerText
        viewController.userType = "General"
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.setValue(viewController, forKey: "contentViewController")
        
        self.present(alert, animated: false)
    }
    
    @objc func setClock(){

        if let endRechargeDate = myUserDefaults.string(forKey: "endRechargeDate"){
            let date = Date()
            let endDate = dateFormatter.date(from: endRechargeDate)

            var diff = Int(((endDate?.timeIntervalSince(date))!))
            
            if diff <= 0 {
                chargingTimeLabel.text = "00 : 00 : 00"
                
                let chargeObject = ChargeObject()
                
                chargeObject.reservationPoint = self.myUserDefaults.integer(forKey: "reservationPoint")
                chargeObject.startRechargeDate = self.myUserDefaults.string(forKey: "startRechargeDate")
                chargeObject.endRechargeDate = endRechargeDate
                chargeObject.rechargePoint = self.myUserDefaults.integer(forKey: "reservationPoint")
                    
                self.showChargeEndPopup(result : chargeObject, startRechargeDate: self.myUserDefaults.string(forKey: "startRechargeDate")!)
                return
            }
            var timerText = ""
    
            let hour = (diff/3600)
                
                
            if hour < 10 {
                timerText = "0" + String(hour) + " : "
            } else {
                timerText = String(hour) + " : "
            }
                
            diff = diff % 3600
            
            let minute = (diff/60)
                
            if minute < 10{
                    
                timerText += "0"
                timerText += String(minute)
            } else {
                    
                timerText += String(minute)
            }
                
            timerText += " : "
            
            let second = (diff%60)
                
            if second < 10 {
                    
                timerText += "0" + String(second)
            }else {
                
                timerText += String(second)
            }
            
            chargingTimeLabel.text = String(timerText)
        } else {
        
            chargingTimeLabel.text = "00 : 00 : 00"
        }
    }
    
    //연결됨 라벨 표시
    private func addConnectedLabel() {
        
        let cell = tableView.cellForRow(at: [0, currentSelectedRow!]) as! ChargerCell
        
        let connectionLabel = UILabel()
        connectionLabel.translatesAutoresizingMaskIntoConstraints = false
        connectionLabel.text = "연결됨"
        connectionLabel.textColor = .white
        connectionLabel.backgroundColor = UIColor(named: "Color_1ABC9C")
        connectionLabel.layer.cornerRadius = cell.chargerNameLabel.frame.height / 2
        connectionLabel.layer.masksToBounds = true
        connectionLabel.textAlignment = .center
        connectionLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        connectionLabel.tag = 1 //태그값을 줘서 나중에 연결됨 라벨을 제거할 때 찾기 위함
        
        cell.itemView.addSubview(connectionLabel)
        
        connectionLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        connectionLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        connectionLabel.rightAnchor.constraint(equalTo: cell.itemView.rightAnchor, constant: -5).isActive = true
        connectionLabel.centerYAnchor.constraint(equalTo: cell.itemView.centerYAnchor).isActive = true
    }
    
    //연결됨 라벨 숨김
    private func removeConnectedLabel() {
        let cell = tableView.cellForRow(at: [0, currentSelectedRow!]) as! ChargerCell
        
        for subview in cell.itemView.subviews {
            if (subview.tag == 1) {
                subview.removeFromSuperview()
            }
        }
    }
    
}

extension ChargeViewController: BleDelegate {
    func bleResult(code: BleResultCode, result: Any?) {
        
        //충전기 연걸, 충전 시작, 충전 종료 버튼 색 변경&클릭 불가 처리, 충전중이면 충전기 연결 버튼 회색으로 변경하고 클릭 불가
        switchSearchCharger()
        
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
                bluetoothList.removeAll()
                BleManager.shared.bleScanStop()
                if let scanData = result as? [String] {
                    self.searchInfos = scanData
                    for bleID: String in self.searchInfos {
                        print("검색된 충전기 ID : \(bleID)\n")
                        if reservationInfo!.bleNumber == bleID {
                            bluetoothList.append(bleID)
                            break
                        }
                    }
                    
                    self.tableView.reloadData()
                    
                    if bluetoothList.count > 0 {
                        checkState()
                    } else {
                        showAlert(title: "사용 가능한 충전기 없음", message: "근처에 예약하신 충전기가 없습니다.", positiveTitle: "확인", negativeTitle: nil)
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
                
                print("충전기 접속 성공 : \(bleId)\n isCharging : \(isCharging)")
                
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
                    
                    //연결됨 라벨 표시
                    addConnectedLabel()
                    
                    showAlert(title: "충전기 연결 성공", message: "\(bleId) 충전기와 연결되었습니다.", positiveTitle: "확인", negativeTitle: nil)
                    
                    BleManager.shared.bleGetTag()
                }
                
                break
            case .BleDisconnect:
                print("충전기 접속 종료\n")
                
                //연결됨 라벨 숨김
                removeConnectedLabel()
                currentSelectedRow = -1
                chargeStart.backgroundColor = UIColor(named: "Color_BEBEBE")
                chargeEnd.backgroundColor = UIColor(named: "Color_BEBEBE")
                
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
                
                let currentDate = Date()
                let endDate = self.dateFormatter.date(from: self.reservationInfo!.realChargingEndDate)
                
                self.myUserDefaults.set(self.dateFormatter.string(from: currentDate), forKey: "startRechargeDate")
                self.myUserDefaults.set(self.dateFormatter.string(from: endDate!), forKey: "endRechargeDate")
                
                showAlert(title: "충전 시작", message: "충전이 시작되었습니다.\n충전이 완료될 때까지 플러그를 제거하지마십시오.", positiveTitle: "확인", negativeTitle: nil)
                
                let chargerId:Int! = reservationInfo!.chargerId
                let url = "http://211.253.37.97:8101/api/v1/recharge/start/charger/\(chargerId!)"
                
                postChargeStartData(postUrl: url)
                
                break
            case .BleUnPlug:
                print("충전 시작 실패, 플러그 연결 확인 후 재 접속 후 충전을 시작해주세요.\n")
                // UnPlug 값이 넘어오면 충전기 접속 종료 처리 해줘야 함
                // 안 그럼 Stop 이벤트가 추가적으로 들어와서 문제가 될 수 있음
                BleManager.shared.bleDisConnect()
                showAlert(title: "충전 시작 실패", message: "플러그 연결 확인 후 재접속 후 충전을 시작해주세요.\n문제가 지속될 시 고객센터로 문의 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                break
            case .BleAgainOtpAtuh:
                print("충전 시작 실패, 접속 종료 후 다시 충전기에 연결을 해주세요.\n")
                break
            case .BleChargeStop:
                print("충전 종료 성공\n")
                isChargeStop = true
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
                    let chargerId: Int! = reservationInfo!.chargerId
                    
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
