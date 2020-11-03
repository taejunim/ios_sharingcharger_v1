//
//  ReservationPopupViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/10/23.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

protocol ReservationPopupProtocol {
    func reservationPopupDelegate()
    func startChargeDelegate()
}

class ReservationPopupViewController: UIViewController {

    var delegate: ReservationPopupProtocol?
    
    @IBOutlet var chargingTimeLabel: UILabel!
    @IBOutlet var chargingPeriodLabel: UILabel!
    @IBOutlet var chargerNameLabel: UILabel!
    @IBOutlet var favoriteButton: UIImageView!
    @IBOutlet var chargerAddressLabel: UILabel!
    @IBOutlet var navigationButton: UIImageView!
    @IBOutlet var feeLabel: UILabel!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var startButton: UIButton!
    
    let starOnImage = UIImage(named: "star_on")
    let starOffImage = UIImage(named: "star_off")
    
    var reservationInfo: SearchingConditionObject!
    
    let myUserDefaults = UserDefaults.standard
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewWillInitializeObjects()
    }
    
    private func viewWillInitializeObjects() {
        
        self.delegate = MainViewController()    //선택한 검색 조건들을 MainViewController 로 넘김
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        self.activityIndicator!.hidesWhenStopped = true
        
        cancelButton.layer.cornerRadius = 7
        startButton.layer.cornerRadius = 7
        
        cancelButton.addTarget(self, action: #selector(self.cancelReservation), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(self.startCharge), for: .touchUpInside)
        
        addButton(buttonName: "close", width: 40, height: 40, top: 15, left: 15, right: nil, bottom: nil, target: self.view, targetViewController: self)
        
        let favoriteButtonGesture = UITapGestureRecognizer(target: self, action: #selector(self.addFavorite(_:)))
        favoriteButton.isUserInteractionEnabled = true
        favoriteButton.addGestureRecognizer(favoriteButtonGesture)
        
        if let data = UserDefaults.standard.value(forKey: "reservationInfo") as? Data {
            
            reservationInfo = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
            
            chargingTimeLabel.text = "총 \(reservationInfo.chargingTime) 충전"
            chargingPeriodLabel.text = reservationInfo.chargingPeriod
            chargerNameLabel.text = reservationInfo.chargerName
            chargerAddressLabel.text = reservationInfo.chargerAddress
            feeLabel.text = "충전 요금 : 약 시간당 \(reservationInfo.fee)원"
        }
    }
    
    //예약 취소
    @objc func cancelReservation() {
        
        let refreshAlert = UIAlertController(title: "예약 취소", message: "해당 예약을 취소하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "예약 취소", style: .destructive,  handler: { (action: UIAlertAction!) in
            
            var code: Int! = 0
            
            let reservationId = self.myUserDefaults.integer(forKey: "reservationId")
            let url = "http://test.jinwoosi.co.kr:6066/api/v1/reservations/\(reservationId)/cancel"
            
            AF.request(url, method: .put, encoding: URLEncoding.default, interceptor: Interceptor(indicator: self.activityIndicator!)).validate().responseJSON(completionHandler: { response in
                
                code = response.response?.statusCode
                
                switch response.result {
                
                case .success(let obj):
                    
                    print("obj : \(obj)")
                    do {
                        
                        let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        let instanceData = try JSONDecoder().decode(ReservationObject.self, from: JSONData)
                        
                        if instanceData.id! > 0 && code == 200 {
                            self.view.makeToast("예약이 취소되었습니다.", duration: 1, position: .bottom) {didTap in
                                
                                UserDefaults.standard.set(0, forKey: "reservationId")
                                UserDefaults.standard.set(nil, forKey: "reservationInfo")
                                
                                if didTap {
                                    print("tap")
                                    self.delegate?.reservationPopupDelegate()
                                    self.dismiss(animated: true, completion: nil)
                                } else {
                                    print("without tap")
                                    self.delegate?.reservationPopupDelegate()
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
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
                        print("Error : \(code!)")
                        self.view.makeToast("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", duration: 2.0, position: .bottom)
                    }
                }
                
                self.activityIndicator!.stopAnimating()
            })
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
        
    }
    
    @objc func startCharge() {
        
        let refreshAlert = UIAlertController(title: "충전 시작", message: "충전을 시작하면 예약 취소 및 환불이 불가능합니다.\n충전을 시작하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "충전 시작", style: .destructive,  handler: { (action: UIAlertAction!) in
            
            print("충전 시작 버튼 클릭")
            self.dismiss(animated: true, completion: nil)
            self.delegate?.startChargeDelegate()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }

    //즐겨찾기 추가/삭제
    @objc func addFavorite(_ sender: UITapGestureRecognizer) {
        if reservationInfo != nil {
            let realm = try! Realm()
            
            let originFavorite = getFavoriteObject(chargerId: reservationInfo.chargerId)
            
            //즐겨찾기 추가된것을 삭제
            if originFavorite != nil {
                
                try! realm.write {
                    realm.delete(originFavorite!)
                }
                
                favoriteButton.image = starOffImage
            }
            
            //즐겨찾기 추가
            else {
                
                let favorite = FavoriteObject()
                
                favorite.chargerId = reservationInfo.chargerId
                favorite.chargerName = reservationInfo.chargerName
                favorite.chargerAddress = reservationInfo.chargerAddress
                
                try! realm.write {
                    realm.add(favorite)
                }
                
                favoriteButton.image = starOnImage
            }
        } else {
            print("************************************")
            print("Error : 예약 정보 없음")
            print("************************************")
        }
        
    }
    
    private func getFavoriteObject(chargerId: Int?) -> Results<FavoriteObject>? {
        
        let realm = try! Realm()
        
        let favoriteObject = realm.objects(FavoriteObject.self).filter("chargerId == \(chargerId!)")
        
        if favoriteObject.first?.chargerId != nil {
            return favoriteObject
        } else {
            return nil
        }
    }
    
    private func addButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject, targetViewController: AnyObject) {
        
        let button = CustomButton(type: .system)
        
        self.view.addSubview(button)
        
        button.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target, targetViewController: targetViewController)
    }
    
    @objc func closeButton(sender: UIButton!) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
