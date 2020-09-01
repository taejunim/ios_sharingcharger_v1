//
//  ViewController.swift
//  SampleElectronic
//
//  Created by Jin Salon on 2020/08/04.
//  Copyright © 2020 Charzin. All rights reserved.
//

import UIKit
import EvzBLEKit

class SampleViewController: UIViewController {

    let listText: Array = Array(arrayLiteral:
                                "Bluetooth Permission Check",
                                "Bluetooth On/Off",
                                "Scan",
                                "Scan Stop",
                                "Connect",
                                "DisConnect",
                                "Charger Start",
                                "Charger Stop",
                                "SetTagData",
                                "GetTagData",
                                "DeleteAllTag",
                                "DeleteTargetTag")
    
    var searchInfos: Array<String> = []
    
    @IBOutlet var tbList: UITableView!
    
    @IBOutlet var tvLog: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        initView()
    }
    
    private func initData() {
        BleManager.shared.setBleDelegate(delegate: self)
    }
    
    private func initView() {
        self.tbList.dataSource = self
        self.tbList.delegate = self
        
        self.tvLog.layer.borderColor = UIColor.black.cgColor
        self.tvLog.layer.borderWidth = 1
    }
}

extension SampleViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listText.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SampleTableViewCell", for: indexPath) as! SampleTableViewCell
        cell.lblText.text = listText[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // Bluetooth Permission Check
            if BleManager.shared.hasPermission() {
                self.tvLog.text.append(contentsOf: "Permission : 블루투스 사용 권한 있음\n")
            } else {
                self.tvLog.text.append(contentsOf: "Permission : 블루투스 사용 권한 없음\n")
            }
            break
        case 1: // Bluetooth On/Off
            if BleManager.shared.isOnBluetooth() {
                self.tvLog.text.append(contentsOf: "Permission : 블루투스 ON\n")
            } else {
                self.tvLog.text.append(contentsOf: "Permission : 블루투스 OFF\n")
            }
            break
        case 2: // Scan
            self.tvLog.text.append(contentsOf: "충전기 검색 시작\n")
            BleManager.shared.bleScan()
            break
        case 3: // Scan Stop
            self.tvLog.text.append(contentsOf: "충전기 검색 중단\n")
            BleManager.shared.bleScanStop()
            break
        case 4: // Connect
            if self.searchInfos.count == 0 {
                self.tvLog.text.append(contentsOf: "충전기를 검색해주세요.\n")
                return
            }
            
            self.tvLog.text.append(contentsOf: "충전기에 접속 요청 : \(self.searchInfos[0])\n")
            BleManager.shared.bleConnect(bleID: self.searchInfos[0])
            break
        case 5: // DisConnect
            self.tvLog.text.append(contentsOf: "충전기에 접속 종료 요청\n")
            BleManager.shared.bleDisConnect()
            break
        case 6: // Charger Start
            self.tvLog.text.append(contentsOf: "충전 시작 요청 사용 시간 5분\n")
            BleManager.shared.bleChargerStart(useTime: "5")
            break
        case 7: // Charger Stop
            self.tvLog.text.append(contentsOf: "충전 종료 요청\n")
            BleManager.shared.bleChargerStop()
            break
        case 8: // SetTagData
            self.tvLog.text.append(contentsOf: "태그 셋팅 요청\n")
            BleManager.shared.bleSetTag(tag: "1234567890123")
            break
        case 9: // GetTagData
            self.tvLog.text.append(contentsOf: "충전기에 저장된 태그 정보 요청\n")
            BleManager.shared.bleGetTag()
            break
        case 10: // DeleteAllTag
            self.tvLog.text.append(contentsOf: "충전기에 저장된 태그 전체 삭제 요청\n")
            BleManager.shared.bleDeleteAllTag()
            break
        case 11: // DeleteTargetTag
            self.tvLog.text.append(contentsOf: "충전기에 저장된 태그(요청한 태그값) 삭제 요청\n")
            BleManager.shared.bleDeleteTargetTag(tag: "1234567890123")
            break
        default:
            break
        }
    }
}

extension SampleViewController: BleDelegate {
    func bleResult(code: BleResultCode, result: Any?) {
        switch code {
            case .BleAuthorized:
                self.tvLog.text.append(contentsOf: "블루투스 사용권한 획득한 상태\n")
                break
            case .BleUnAuthorized:
                self.tvLog.text.append(contentsOf: "블루투스 사용권한이 없거나 거부 상태\n")
                break
            case .BleOff:
                self.tvLog.text.append(contentsOf: "블루투스 사용 설정이 꺼져있음\n")
                break
            case .BleScan:
                self.tvLog.text.append(contentsOf: "충전기 스캔 성공\n")
                if let scanData = result as? [String] {
                    self.searchInfos = scanData
                    for bleID: String in self.searchInfos {
                        self.tvLog.text.append(contentsOf: "검색된 충전기 ID : \(bleID)\n")
                    }
                }
                break
            case .BleNotScanList:
                self.tvLog.text.append(contentsOf: "근처에 사용 가능한 충전기가 없음\n")
                break
            case .BleConnect:
                guard let bleId = result as? String else {
                    self.tvLog.text.append(contentsOf: "충전기 접속 성공\n")
                    return
                }
                self.tvLog.text.append(contentsOf: "충전기 접속 성공 : \(bleId)\n")
                break
            case .BleDisconnect:
                self.tvLog.text.append(contentsOf: "충전기 접속 종료\n")
                break
            case .BleScanFail:
                self.tvLog.text.append(contentsOf: "충전기 검색 실패\n")
                break
            case .BleConnectFail:
                self.tvLog.text.append(contentsOf: "충전기 접속 실패\n")
                break
            case .BleOtpCreateFail:
                self.tvLog.text.append(contentsOf: "OTP 생성 실패(서버에서 OTP 생성 실패)\n")
                break
            case .BleOtpAuthFail:
                self.tvLog.text.append(contentsOf: "OTP 인증 실패(서버에서 받은 OTP 정보로 인증 실패 함)\n")
                break
            case .BleAccessServiceFail:
                self.tvLog.text.append(contentsOf: "충전기와 서비스 인증정보 획득 실패\n")
                break
            case .BleChargeStart:
                self.tvLog.text.append(contentsOf: "충전 시작 성공\n")
                break
            case .BleChargeStop:
                self.tvLog.text.append(contentsOf: "충전 종료 성공\n")
                break
            case .BleChargeStartFail:
                self.tvLog.text.append(contentsOf: "충전 시작 실패\n")
                break
            case .BleChargeStopFail:
                self.tvLog.text.append(contentsOf: "충전 종료 실패\n")
                break
            case .BleSetTag:
                self.tvLog.text.append(contentsOf: "태그 설정 성공\n")
                break
            case .BleGetTag:
                self.tvLog.text.append(contentsOf: "태그 정보 획득 성공\n")
                if let tags = result as? [EvzBLETagData] {
                    for data: EvzBLETagData in tags {
                        self.tvLog.text.append("\(data.toString())\n")
                    }
                }
                break
            case .BleAllDeleteTag:
                self.tvLog.text.append(contentsOf: "전체 태그 삭제 성공\n")
                break
            case .BleDeleteTag:
                self.tvLog.text.append(contentsOf: "선택 태그 삭제 성공\n")
                break
            case .BleSetTagFail:
                self.tvLog.text.append(contentsOf: "태그 설정 실패\n")
                break
            case .BleWrongTagLength:
                self.tvLog.text.append(contentsOf: "설정 태그 길이가 13자가 넘음\n")
                break
            case .BleGetTagFail:
                self.tvLog.text.append(contentsOf: "태그 정보 획득 실패\n")
                break
            case .BleAllDeleteTagFail:
                self.tvLog.text.append(contentsOf: "전체 태그 삭제 실패\n")
                break
            case .BleDeleteTagFail:
                self.tvLog.text.append(contentsOf: "선택 태그 삭제 실패\n")
                break
            case .BleNotConnect:
                self.tvLog.text.append(contentsOf: "충전기에 접속이 안되어있음\n")
                break
            case .BleUnknownError:
                self.tvLog.text.append(contentsOf: "알수 없는 에러\n")
                break
            case .BleUnSupport:
                self.tvLog.text.append(contentsOf: "블루투스가 지원 안됨\n")
                break
            default:
            
            break
        }
    }
}
