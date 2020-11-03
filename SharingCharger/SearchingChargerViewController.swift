//
//  SearchingChargerViewController.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/10/06.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import EvzBLEKit

class SearchingChargerViewController: UIViewController {
    
    var searchInfos: Array<String> = []
    
    let Color7F7F7F: UIColor! = UIColor(named: "Color_7F7F7F")
    
    @IBOutlet var stepTable: UIView!
    @IBOutlet var chargerSearch: UIButton!
    
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
        
        stepTable.layer.borderColor = Color7F7F7F?.cgColor
        stepTable.layer.borderWidth = 1
        
        chargerSearch.layer.cornerRadius = 7
        chargerSearch.addTarget(self, action: #selector(searchCharger(sender:)), for: .touchUpInside)
        
        //블루투스 권한 체크
        if hasBluetoothPermission() {
            
            //블루투스 on/off 체크
            if isOnBluetooth() {
                
                //BleManager.shared.bleScan()
                
            } else {
                showAlert(title: "블루투스 꺼짐", message: "충전을 하기 위해서는 블루투스가 켜져 있어야 합니다.\n확인후 재시도 바랍니다.", positiveTitle: "설정", negativeTitle: "닫기")
            }
            
        } else {
            showAlert(title: "블루투스 사용 권한 없음", message: "기기 블루투스 사용 권한이 없습니다.\n확인후 재시도 바랍니다.", positiveTitle: "확인", negativeTitle: nil)
        }
        
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
        
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        if positiveTitle != nil {
            
            if positiveTitle == "설정" {
                refreshAlert.addAction(UIAlertAction(title: positiveTitle, style: .default,  handler: { (action: UIAlertAction!) in
                    
                    let url = URL(string: "App-Prefs:root=Bluetooth") //for bluetooth setting
                    let app = UIApplication.shared
                    app.open(url!)
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
    
    @objc func searchCharger(sender: UIView!) {
        
        self.activityIndicator!.startAnimating()
        
        if BleManager.shared.isOnBluetooth() {
            
            BleManager.shared.bleScan()
            
        } else {
            showAlert(title: "블루투스 꺼짐", message: "충전을 하기 위해서는 블루투스가 켜져 있어야 합니다.\n확인후 재시도 바랍니다.", positiveTitle: "설정", negativeTitle: "닫기")
        }
    }
}

extension SearchingChargerViewController: BleDelegate {
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
                
                if let scanData = result as? [String] {
                    self.searchInfos = scanData
                    for bleID: String in self.searchInfos {
                        print("검색된 충전기 ID : \(bleID)\n")
                    }
                    
                    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Charge") as? ChargeViewController else { return }
                    viewController.bluetoothList = self.searchInfos
                    
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                
                break
            case .BleNotScanList:
                print("근처에 사용 가능한 충전기가 없음\n")
                showAlert(title: "사용 가능한 충전기 없음", message: "근처에 사용 가능한 충전기가 없습니다.\n다시 검색하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
                break
            case .BleConnect:
                guard let bleId = result as? String else {
                    print("충전기 접속 성공\n")
                    return
                }
                print("충전기 접속 성공 : \(bleId)\n")
                break
            case .BleDisconnect:
                print("충전기 접속 종료\n")
                break
            case .BleScanFail:
                print("충전기 검색 실패\n")
                showAlert(title: "충전기 검색 실패", message: "충전기 검색에 실패했습니다.\n다시 시도하여 주십시오.", positiveTitle: "확인", negativeTitle: nil)
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
                break
            case .BleUnPlug:
                print("충전 시작 실패, 플러그 연결 확인 후 재 접속 후 충전을 시작해주세요.\n")
                break
            case .BleAgainOtpAtuh:
                print("충전 시작 실패, 접속 종료 후 다시 충전기에 연결을 해주세요.\n")
                break
            case .BleChargeStop:
                print("충전 종료 성공\n")
                break
            case .BleChargeStartFail:
                print("충전 시작 실패\n")
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
                    for data: EvzBLETagData in tags {
                        print("\(data.toString())\n")
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
