//
//  MainViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/25.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialBottomSheet
import SideMenu
import GoneVisible
import Alamofire
import Toast_Swift
import CoreLocation

class MainViewController: UIViewController, MTMapViewDelegate, SearchingConditionProtocol, FavoriteProtocol, ReservationPopupProtocol , SearchingAddressProtocol{

    var delegate: SearchingConditionProtocol?
    
    let notificationCenter = NotificationCenter.default
    
    @IBOutlet var mapView: UIView!
    var mTMapView: MTMapView?
    var searchingConditionView = ShadowView()
    var chargerView: BottomSheetView?
    
    var shadowButton = ShadowButton()
    
    var chargerViewMinimumHeight: CGFloat = 0       //충전기 화면 최소 높이
    var chargerViewMaximumHeight: CGFloat = 0       //충전기 화면 최대 높이
    
    var currentSelectedPoiItem: MTMapPOIItem?       //현재 선택된 마커
    
    var bottomButton = CustomButton(type: .system)
    
    var isCurrentLocationTrackingMode = false
    
    let myUserDefaults = UserDefaults.standard
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    var poiArray = Array<MTMapPOIItem>()
    
    var selectedChargerObject: ChargerObject?
    var receivedSearchingConditionObject: SearchingConditionObject! = SearchingConditionObject()
    var receivedFavoriteObject: FavoriteObject? = nil
    var selectedAddressObject: SelectedPositionObject? = nil

    let locale = Locale(identifier: "ko")
    let dateFormatter = DateFormatter()
    let realDateFormatter = DateFormatter()
    let reservationStateBarDateFormatter = DateFormatter()
    let selectedTimePeriodDateFormatter = DateFormatter()
    let HHMMFormatter = DateFormatter()
    let HHFormatter = DateFormatter()
    let MMFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    var reservationStateBarStartDate = ""
    var selectedTimePeriod = ""
    
    let geoCoder = CLGeocoder()
    
    let addressView = ShadowButton(type: .system)
    var labelChange = true
    var currentLocationInit = true
    
    let locationManager = CLLocationManager()
    
    let bluePinOrigin: UIImage!  = UIImage(named: "pin_blue")
    let redPinOrigin: UIImage!  = UIImage(named: "pin_red")
    let pinSize = CGSize(width:30, height:30)
    var bluePin: UIImage?
    var redPin: UIImage?
    
    let ColorE0E0E0: UIColor! = UIColor(named: "Color_E0E0E0")  //회색
    let Color3498DB: UIColor! = UIColor(named: "Color_3498DB")  //파랑
    let Color1ABC9C: UIColor! = UIColor(named: "Color_1ABC9C")  //연두
    
    var currentPoint = 0
    var expectedPoint = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWillInitializeObjects()
    }
    
    func hasLocationPermission() -> Bool {
        var hasPermission = false
        
        switch locationManager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            hasPermission = false
        case .authorizedAlways, .authorizedWhenInUse:
            hasPermission = true
        default:
            print("GPS: Default")
        }
        
        return hasPermission
    }
    
    //위치 권한
    private func requestGPSPermission() {
            
        if !hasLocationPermission() {
            let alertController = UIAlertController(title: "위치 권한이 요구됨", message: "내 위치 확인을 위해 권한이 필요합니다.", preferredStyle: UIAlertController.Style.alert)

            let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                //Redirect to Settings app
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
            alertController.addAction(cancelAction)

            alertController.addAction(okAction)

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //object 초기화
    private func viewWillInitializeObjects() {
        
        requestGPSPermission()  //위치 권한
        
        //지도 설정
        mTMapView = MTMapView(frame: mapView.bounds)
        if let mTMapView = mTMapView {
            
            mTMapView.delegate = self
            mTMapView.baseMapType = .standard
            mapView.addSubview(mTMapView)
        }
        
        //메인 화면 버튼 추가
        addButton(buttonName: "menu", width: 40, height: 40, top: 15, left: 15, right: nil, bottom: nil, target: mapView)   //사이드 메뉴
        addButton(buttonName: "address", width: nil, height: 40, top: 15, left: 70, right: -15, bottom: nil, target: mapView)   //주소 검색
        addBottomButton(buttonName: "bottomButton", width: nil, height: 40, top: nil, left: 0, right: 0, bottom: 0, target: self.view, targetViewController: self)  //하단 버튼
        addCurrentLocationButton(buttonName: "currentLocation", width: 40, height: 40, top: 70, left: nil, right: -15, bottom: nil, target: mapView)    //현재 위치 버튼
        addSearchingConditionView(width: nil, height: 110, top: nil, left: 15, right: -15, bottom: 0, target: mapView)  //검색 조건 버튼
    
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        self.activityIndicator!.hidesWhenStopped = true
        
        if UIDevice().userInterfaceIdiom == .phone {
        
            chargerViewMinimumHeight = mapView.frame.height * 0.5
            chargerViewMaximumHeight = mapView.frame.height * 0.5
   
        }
        
        //현재 위치
        getCurrentLocation()
        
        //마커 이미지
        let renderer = UIGraphicsImageRenderer(size: pinSize)
        bluePin = renderer.image {_ in bluePinOrigin.draw(in: CGRect(origin: .zero, size: pinSize))}
        redPin = renderer.image {_ in redPinOrigin.draw(in: CGRect(origin: .zero, size: pinSize))}
        
        //delegate 에서 observer
        notificationCenter.addObserver(self, selector: #selector(updateSearchingCondition(_:)), name: .updateSearchingCondition, object: nil)
        notificationCenter.addObserver(self, selector: #selector(lookFavorite(_:)), name: .lookFavorite, object: nil)
        notificationCenter.addObserver(self, selector: #selector(reservationPopup(_:)), name: .reservationPopup, object: nil)
        notificationCenter.addObserver(self, selector: #selector(startCharge(_:)), name: .startCharge, object: nil)
        notificationCenter.addObserver(self, selector: #selector(searchingAddress(_:)), name: .searchAddress, object: nil)
        
        //DateFormatter
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        realDateFormatter.locale = locale
        realDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        selectedTimePeriodDateFormatter.locale = locale
        selectedTimePeriodDateFormatter.dateFormat = "HH:mm"
        
        HHMMFormatter.locale = locale
        HHMMFormatter.dateFormat = "HH시간 mm분"
        
        HHFormatter.locale = locale
        HHFormatter.dateFormat = "HH시간"
        
        MMFormatter.locale = locale
        MMFormatter.dateFormat = "mm분"
        
        timeFormatter.locale = locale
        timeFormatter.dateFormat = "HH:mm"
        
        reservationStateBarDateFormatter.locale = locale
        reservationStateBarDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        //검색 조건 초기화
        initializeSearchingConditionObject()
    }
    
    //검색 조건 초기화
    private func initializeSearchingConditionObject() {
        
        let calendar = Calendar.current
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .minute, value: 30, to: startDate)!
        
        let searchingConditionObject: SearchingConditionObject! = SearchingConditionObject()
        searchingConditionObject.chargingTime = "30분"
        searchingConditionObject.realChargingStartDate = realDateFormatter.string(from: startDate)
        searchingConditionObject.realChargingEndDate = realDateFormatter.string(from: endDate)
        searchingConditionObject.realChargingPeriod = dateFormatter.string(from: startDate) + " ~ " + dateFormatter.string(from: endDate)
        
        receivedSearchingConditionObject = searchingConditionObject
        
        let minute = calendar.component(.minute, from: startDate)
        let hour = calendar.component(.hour, from: startDate)
        
        var availableDate = Date()
        
        if minute >= 0 && minute < 30 {
            availableDate = calendar.date(bySettingHour: hour, minute: 30, second: 0, of: startDate)!
        } else {
            
            let tempDate = calendar.date(byAdding: .hour, value: 1, to: startDate)!
            let tempHour = calendar.component(.hour, from: tempDate)
            availableDate = calendar.date(bySettingHour: tempHour, minute: 0, second: 0, of: tempDate)!
        }
        
        reservationStateBarStartDate = reservationStateBarDateFormatter.string(from: availableDate)
        
        selectedTimePeriod = "\(selectedTimePeriodDateFormatter.string(from: startDate)) - \(selectedTimePeriodDateFormatter.string(from: endDate))"
        
        
        let periodFormatter = DateFormatter()
        periodFormatter.locale = locale
        periodFormatter.dateFormat = "MM/dd (E) HH:mm"
        
        let dayOfStartDate = calendar.component(.day, from: startDate)
        let dayOfEndDate = calendar.component(.day, from: endDate)
        
        if dayOfStartDate == dayOfEndDate {
            
            let chargingEndDate = timeFormatter.string(from: endDate)
            receivedSearchingConditionObject.chargingPeriod = "\(periodFormatter.string(from: startDate)) ~ \(chargingEndDate)"
            
        } else if dayOfStartDate != dayOfEndDate {
            
            receivedSearchingConditionObject.chargingPeriod = "\(periodFormatter.string(from: startDate)) ~ \(periodFormatter.string(from: endDate))"
            
        } else {
            
            receivedSearchingConditionObject.chargingPeriod = "\(periodFormatter.string(from: startDate)) ~ \(periodFormatter.string(from: endDate))"
        }
        
        currentPoint = 0
        expectedPoint = 0
    }
    
    //포인트API
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
                "chargerId" : currentSelectedPoiItem!.tag,
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
                        
                        self.currentPoint = point
                        
                        let expectedPointUrl = "http://211.253.37.97:8101/api/v1/point/chargers/\(self.currentSelectedPoiItem!.tag)/calculate"
                        
                        self.getPoint(url: expectedPointUrl)
                        
                    } else if url.contains("point/chargers") {
                        
                        self.expectedPoint = point
                        
                        //포인트 충전 화면으로 이동
                        if self.currentPoint == 0 || self.currentPoint < self.expectedPoint {
                        
                            let refreshAlert = UIAlertController(title: "포인트 부족", message: "잔여 포인트가 부족합니다.\n포인트를 충전하시겠습니까?\n잔여 포인트 : \(self.currentPoint)", preferredStyle: UIAlertController.Style.alert)
                            
                            refreshAlert.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action: UIAlertAction!) in
                                
                            }))
                            
                            refreshAlert.addAction(UIAlertAction(title: "충전", style: .default, handler: { (action: UIAlertAction!) in
                                
                                guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PointCharge") else { return }
                                self.navigationController?.pushViewController(viewController, animated: true)
                            }))
                            
                            self.present(refreshAlert, animated: true, completion: nil)
                        }
                        
                        //충전
                        else if self.currentPoint != 0 && self.currentPoint >= self.expectedPoint {
                            
                            self.reservation()
                        }
                        
                        //그 외 오류
                        else {
                            
                            let refreshAlert = UIAlertController(title: "알 수 없는 오류", message: "오류가 발생하여 충전에 실패했습니다\n문제가 지속될 시 고객센터로 문의주십시오.", preferredStyle: UIAlertController.Style.alert)
                            
                            refreshAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action: UIAlertAction!) in
                                
                            }))
                            
                            self.present(refreshAlert, animated: true, completion: nil)
                        }
                    }
                    
                } else {
                    
                    self.currentPoint = 0
                    
                    if url.contains("point/users") {
                        
                        self.currentPoint = 0
                        
                    } else if url.contains("point/chargers") {
                        
                        self.expectedPoint = 0
                    }
                }

            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("Unknown Error")
                    
                } else {
                    print("Unknown Error")
                }
                
                if url.contains("point/users") {
                    
                    self.currentPoint = 0
                    
                } else if url.contains("point/chargers") {
                    
                    self.expectedPoint = 0
                }
                
                self.activityIndicator!.stopAnimating()
            }
        })
    }
    
    private func reservation() {
        
        self.activityIndicator!.startAnimating()
        
        let userId: Int = myUserDefaults.integer(forKey: "userId")
        
        var code: Int! = 0
        
        let url = "http://211.253.37.97:8101/api/v1/reservation"
        
        let parameters: Parameters = [
            "chargerId" : currentSelectedPoiItem!.tag,
            "startDate" : receivedSearchingConditionObject.realChargingStartDate,
            "endDate" : receivedSearchingConditionObject.realChargingEndDate,
            "cancelDate" : "",
            "expectPoint" : expectedPoint,
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
                        self.myUserDefaults.set(instanceData.id, forKey: "reservationId")
                        self.myUserDefaults.set(try? PropertyListEncoder().encode(self.receivedSearchingConditionObject), forKey: "reservationInfo")
                        
                        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchingCharger") as? SearchingChargerViewController else { return }
                        
                        self.navigationController?.pushViewController(viewController, animated: true)
                        
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
    
    //마커 클릭했을 때
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        
        print("poi selected : \(poiItem.tag)")
        
        let reservationId = myUserDefaults.integer(forKey: "reservationId")
        
        //예약이 있을 경우 예약 팝업
        if reservationId > 0 {
            
            if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
                
                let reservationInfo: SearchingConditionObject? = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
                
                for item in poiArray {
                    
                    if item.tag == reservationInfo?.chargerId {
                        
                        mTMapView?.setMapCenter(item.mapPoint, zoomLevel: 1, animated: true)
                        
                        break
                    }
                }
            }
            
            presentReservationPopup()
        }
        
        //예약이 없으면 POI 상세 보여줌
        else {
            var code: Int! = 0
            
            let chargerId = poiItem.tag
            let url = "http://211.253.37.97:8101/api/v1/app/chargers/\(chargerId)"
            
            AF.request(url, method: .get, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
                
                code = response.response?.statusCode
                
                switch response.result {
                
                case .success(let obj):
                    print(obj)
                    do {
                        
                        let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        let instanceData = try JSONDecoder().decode(ChargerObject.self, from: JSONData)
                        
                        self.selectedChargerObject = instanceData
                        
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
                
                self.mTMapView?.setMapCenter(poiItem.mapPoint, zoomLevel: 1, animated: true)
                
                //충전기 화면 사라짐
                self.chargerView?.dismiss()
                
                let destinationLatitude = String(format : "%f", self.selectedChargerObject!.gpsY!)
                let destinationLongitude = String(format : "%f", self.selectedChargerObject!.gpsX!)
                var currentLatitude = ""
                var currentLongitude = ""
                
                if let userLatitude = self.locationManager.location?.coordinate.latitude , let userLongitude = self.locationManager.location?.coordinate.longitude{
                
                    currentLatitude = String(format : "%f", userLatitude as CVarArg)
                    currentLongitude = String(format : "%f", userLongitude as CVarArg)
                }
                
                //충전기 상세 뷰
                let chargerContentView = ChargerContentView()
                
                //현재 위치 좌표, 충전기 좌표 넘김
                chargerContentView.setNavigationParameter(destinationLatitude: destinationLatitude, destinationLongitude: destinationLongitude, currentLatitude: currentLatitude, currentLongitude: currentLongitude)
                
                //검색 조건 뷰 숨김
                self.searchingConditionView.isHidden = true
                self.searchingConditionView.gone()
                
                //충전하기, 예약하기 버튼 보이기
                self.bottomButton.visible()
                
                UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
                
                self.chargerView = BottomSheetView(
                    contentView: chargerContentView,
                    contentHeights: [self.chargerViewMinimumHeight, self.chargerViewMaximumHeight]
                )
                
                self.chargerView?.present(in: self.view)
                
                chargerContentView.changeValue(chargerNameText: poiItem.itemName, chargerId: poiItem.tag, chargerAddressText: self.selectedChargerObject?.address, rangeOfFeeText: self.selectedChargerObject?.rangeOfFee)
                
                //충전기에 대한 예약 불러오기
                self.getCurrentReservations(id: poiItem.tag, chargerContentView: chargerContentView)
                
                //현재 선택된 마커 저장
                self.currentSelectedPoiItem = poiItem
                
                //충전하기, 예약하기 버튼 앞으로 가져오기
                self.view.bringSubviewToFront(self.bottomButton)
            })
        }
        
        return false
    }
    
    //현재 예약 가져오기
    private func getCurrentReservations(id: Int!, chargerContentView: ChargerContentView!) {
        
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
                    
                    var availableTimeList = Array<AvailableTimeObject>()
                    
                    for chargerTimeAvailable in instanceData.chargerTimeAvailable {
                        
                        for time in chargerTimeAvailable.allowTimeOfDays {
                            let availableTime = AvailableTimeObject()
                            availableTime.id = time.id
                            availableTime.day = chargerTimeAvailable.day
                            availableTime.openTime = time.openTime
                            availableTime.closeTime = time.closeTime
                            
                            availableTimeList.append(availableTime)
                        }
                    }
                    
                    var reservationList = Array<CurrentReservationObject>()
                    
                    if instanceData.reservations.content.count > 0 {
                        for reservation in instanceData.reservations.content {
                            let currentReservation = CurrentReservationObject()
                            currentReservation.id = reservation.id
                            currentReservation.startDate = reservation.startDate
                            currentReservation.endDate = reservation.endDate
                            
                            reservationList.append(currentReservation)
                        }
                        
                    } else {
                        print("reservationList size 0")
                        
                    }
                    self.checkDisableTime(reservationList: reservationList)
                    
                    print("receivedSearchingConditionObject.chargingStartDate : \(self.receivedSearchingConditionObject.realChargingStartDate)")
                    
                    var countOfSelectedPeriod = 0
                    
                    let locale = Locale(identifier: "ko")
                    let dateFormatter = DateFormatter()
                    let calendar = Calendar.current
                    dateFormatter.locale = locale
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                    
                    let startDate = dateFormatter.date(from: self.receivedSearchingConditionObject.realChargingStartDate)
                    let endDate = dateFormatter.date(from: self.receivedSearchingConditionObject.realChargingEndDate)
                    
                    let offsetComps = calendar.dateComponents([.hour,.minute], from:startDate!, to:endDate!)
                    if case let (hour?, minute?) = (offsetComps.hour, offsetComps.minute) {
                        
                        //30분
                        if hour == 0 && minute != 0 {
                            countOfSelectedPeriod = 1
                        }
                        
                        //1시간 .. 2시간
                        else if hour != 0 && minute == 0 {
                            countOfSelectedPeriod = hour * 2
                        }
                        
                        //1시간 30분 .. 2시간 30분
                        else if hour != 0 && minute != 0 {
                            countOfSelectedPeriod = hour * 2 + 1
                        }
                    }
                    print("selectedTimePeriod: \(self.selectedTimePeriod)")
                    chargerContentView.setReservationStateBar(availableTimeList: availableTimeList, reservationList: reservationList, countOfSelectedPeriod: countOfSelectedPeriod, selectedStartDate: self.reservationStateBarStartDate, selectedTimePeriod: self.selectedTimePeriod)
                    
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

    //지도 클릭했을 때
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        
        print("singleTapOn ")
        
        showSearchingConditionView()
        
        selectedChargerObject = nil
    }
    
    func mapView(_ mapView: MTMapView!, dragEndedOn mapPoint: MTMapPoint!) {
        print("dragEndedOn")
    
        if selectedChargerObject != nil {
           
            showSearchingConditionView()
            selectedChargerObject = nil
        }
        
    }
    
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        print("finishedMapMoveAnimation \(mapCenterPoint.mapPointGeo())")
        
        changeAddressButtonText(latitude: mapCenterPoint.mapPointGeo().latitude, longitude: mapCenterPoint.mapPointGeo().longitude, placeName: nil)
        labelChange = true
        
        receivedSearchingConditionObject.gpxY = mapCenterPoint.mapPointGeo().latitude
        receivedSearchingConditionObject.gpxX = mapCenterPoint.mapPointGeo().longitude
        
        addPoiItem()
    }

    private func showSearchingConditionView() {
        //충전기 화면 사라짐
        chargerView?.dismiss()
        
        //검색 조건 버튼 올라옴
        searchingConditionView.isHidden = false
        searchingConditionView.visible()
        
        bottomButton.gone()
        
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
        
        //현재 선택된 마커 지움
        currentSelectedPoiItem = nil
        
        self.view.sendSubviewToBack(bottomButton)
    }
    
    private func addPoiItem() {
        
        var code: Int! = 0
        let url = "http://211.253.37.97:8101/api/v1/app/chargers"

        print("receivedSearchingConditionObject.realChargingStartDate : \(receivedSearchingConditionObject.realChargingStartDate)")
        print("receivedSearchingConditionObject.realChargingEndDate : \(receivedSearchingConditionObject.realChargingEndDate)")
        let parameters: Parameters = [
            
            "startDate":receivedSearchingConditionObject.realChargingStartDate,
            "endDate":receivedSearchingConditionObject.realChargingEndDate,
            "gpsX":receivedSearchingConditionObject.gpxX!,
            "gpsY":receivedSearchingConditionObject.gpxY!

        ]
        
        print(parameters)
        AF.request(url, method: .get, parameters: parameters,  encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode

            switch response.result {
            
            case .success(let obj):
                
                do {
                    
                    let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let instanceData = try JSONDecoder().decode([MarkersObject].self, from: JSONData)
                    
                    self.mTMapView?.removePOIItems(self.mTMapView?.poiItems)

                    
                    self.poiArray = Array<MTMapPOIItem>()
                    
                    for content in instanceData {

                        if(content.name != nil && content.gpsX != nil && content.gpsY != nil && content.id != nil){

                            let poiItem: MTMapPOIItem = MTMapPOIItem()
                            poiItem.itemName = content.name
                            poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: content.gpsY!, longitude: content.gpsX!))
                            poiItem.markerType = MTMapPOIItemMarkerType.customImage
                            
                            if(content.currentStatusType == "READY"){
                                
                                poiItem.customImage = self.bluePin
                                
                            } else {
                                
                                poiItem.customImage = self.redPin
                            }
                            
                            poiItem.tag = content.id!
                            self.poiArray.append(poiItem)
                        }
                    }
                    self.mTMapView?.addPOIItems(self.poiArray)
                    
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
    
    //하단 버튼
    @objc func reservationButton(sender: UIButton!) {
        print("MainViewController - instantChargeButton tapped")
        
        //즉시 충전
        if receivedSearchingConditionObject.isInstantCharge {
            instantCharge()
        }
        
        //예약
        else {
            print("MainViewController - reservationButton tapped")
            
            guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Reservation") as? ReservationViewController else { return }
            receivedSearchingConditionObject.chargerId = currentSelectedPoiItem!.tag
            receivedSearchingConditionObject.chargerName = currentSelectedPoiItem!.itemName
            receivedSearchingConditionObject.chargerAddress = selectedChargerObject?.address ?? ""
            receivedSearchingConditionObject.fee = selectedChargerObject?.rangeOfFee ?? "-"
            viewController.receivedSearchingConditionObject = receivedSearchingConditionObject
            viewController.chargerId = currentSelectedPoiItem!.tag
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private func instantCharge() {

        let startDate = Date()
        let calendar = Calendar.current
        
        let chargingTimeText = receivedSearchingConditionObject.chargingTime

        var formattedChargingTime = Date()

        //30분
        if !chargingTimeText.contains("시간") && chargingTimeText.contains("분") {

            formattedChargingTime = MMFormatter.date(from: chargingTimeText)!
        }

        //1시간 .. 2시간 .. 3시간
        else if chargingTimeText.contains("시간") && !chargingTimeText.contains("분") {

            formattedChargingTime = HHFormatter.date(from: chargingTimeText)!
        }

        //1시간 30분 .. 2시간 30분 .. 3시간 30분
        else {
            formattedChargingTime = HHMMFormatter.date(from: chargingTimeText)!
        }

        let minute = calendar.component(.minute, from: formattedChargingTime)
        let hour = calendar.component(.hour, from: formattedChargingTime)

        let dateAddedHour = calendar.date(byAdding: .hour, value: hour, to: startDate)!

        let endDate = calendar.date(byAdding: .minute, value: minute, to: dateAddedHour)!

        receivedSearchingConditionObject.realChargingStartDate = realDateFormatter.string(from: startDate)
        receivedSearchingConditionObject.realChargingEndDate = realDateFormatter.string(from: endDate)
        receivedSearchingConditionObject.realChargingPeriod = "\(timeFormatter.string(from: startDate)) ~ \(timeFormatter.string(from: endDate))"
        
        let message = "충전기명 : \(currentSelectedPoiItem!.itemName!)\n충전 시간 : \(receivedSearchingConditionObject.realChargingPeriod)"
        let refreshAlert = UIAlertController(title: "충전하기", message: "\(message)\n충전을 진행하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "충전", style: .default, handler: { (action: UIAlertAction!) in
            
            //현재 포인트, 예상 포인트 가져오기
            let userId = self.myUserDefaults.integer(forKey: "userId")
            let currentPointUrl = "http://211.253.37.97:8101/api/v1/point/users/\(userId)"
            
            self.getPoint(url: currentPointUrl)
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    //Side Menu
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToLeftMenu" {
            if let sideMenuNavigationController = segue.destination as? SideMenuNavigationController {
                
                sideMenuNavigationController.settings = makeSettings()
            }
        }
        
        if segue.identifier == "segueToAddress" {
            if let searchingAddressViewController = segue.destination as? SearchingAddressViewController {
                
                if let userLatitude = locationManager.location?.coordinate.latitude , let userLongitude = locationManager.location?.coordinate.longitude{
                
                    searchingAddressViewController.userLatitude = userLatitude
                    searchingAddressViewController.userLongitude = userLongitude
                }
                if let mapLatitude = mTMapView?.mapCenterPoint.mapPointGeo().latitude , let mapLongitude = mTMapView?.mapCenterPoint.mapPointGeo().longitude{
                    
                    searchingAddressViewController.mapLatitude = mapLatitude
                    searchingAddressViewController.mapLongitude = mapLongitude
                    
                }

                searchingAddressViewController.defaultAddress = (self.addressView.titleLabel?.text)!
                searchingAddressViewController.delegate       = self
            }
        }
    }
    
    private func selectedPresentationStyle() -> SideMenuPresentationStyle {
        
        return .menuSlideIn
    }
    
    private func makeSettings() -> SideMenuSettings {
        
        let presentationStyle = selectedPresentationStyle()
        presentationStyle.backgroundColor = .black
        presentationStyle.presentingEndAlpha = 0.5
        
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.menuWidth = self.view.frame.width * 0.85
        
        return settings
    }
    
    //사이드 메뉴 버튼
    @objc func menuButton(sender: UIButton!) {
        print("MainViewController - menuButton tapped")
        
        self.performSegue(withIdentifier: "segueToLeftMenu", sender: self)
    }
    
    //주소 찾기 버튼
    @objc func addressButton(sender: UIButton!) {
        print("MainViewController - addressButton tapped")
        self.performSegue(withIdentifier: "segueToAddress", sender: self)
        
    }
    
    //검색 조건 버튼
    @objc func searchingConditionButton(sender: UIView!) {
        print("MainViewController - searchingConditionButton tapped")
        
        let reservationId = myUserDefaults.integer(forKey: "reservationId")
        
        //예약이 있을 경우 예약 팝업
        if reservationId > 0 {
            
            presentReservationPopup()
        }
        
        //예약이 없으면 검색 조건 팝업
        else {
            
            let viewController: UIViewController!
            let bottomSheet: MDCBottomSheetController!
            
            viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchingCondition")
            bottomSheet = MDCBottomSheetController(contentViewController: viewController)
            bottomSheet.preferredContentSize = CGSize(width: mapView.frame.size.width, height: mapView.frame.size.height)
            
            let shapeGenerator = MDCCurvedRectShapeGenerator(cornerSize: CGSize(width: 15, height: 15))
            bottomSheet.setShapeGenerator(shapeGenerator, for: .preferred)
            bottomSheet.setShapeGenerator(shapeGenerator, for: .extended)
            bottomSheet.setShapeGenerator(shapeGenerator, for: .closed)
            
            present(bottomSheet, animated: true, completion: nil)
        }
    }
    
    //예약이 있을 경우 예약 팝업
    private func presentReservationPopup() {
        let viewController:ReservationPopupViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReservationPopup") as! ReservationPopupViewController
        
        if let userLatitude = self.locationManager.location?.coordinate.latitude , let userLongitude = self.locationManager.location?.coordinate.longitude{
        
            viewController.userLatitude = String(format : "%f", userLatitude as CVarArg)
            viewController.userLongitude = String(format : "%f", userLongitude as CVarArg)
        }
        
        let bottomSheet: MDCBottomSheetController! = MDCBottomSheetController(contentViewController: viewController)

        if checkDeviceFrame() > 1334 {
            bottomSheet.preferredContentSize = CGSize(width: mapView.frame.size.width, height: mapView.frame.size.height / 2)
        }
        
        //작은 화면들은 글자 잘리므로 예약 화면 팝업 height 를 더 크게함
        else {
            bottomSheet.preferredContentSize = CGSize(width: mapView.frame.size.width, height: mapView.frame.size.height / 2 * 1.1)
        }
        
        let shapeGenerator = MDCCurvedRectShapeGenerator(cornerSize: CGSize(width: 15, height: 15))
        bottomSheet.setShapeGenerator(shapeGenerator, for: .preferred)
        bottomSheet.setShapeGenerator(shapeGenerator, for: .extended)
        bottomSheet.setShapeGenerator(shapeGenerator, for: .closed)
        
        present(bottomSheet, animated: true, completion: nil)
    }
    
    //사이드메뉴, 주소 찾기 버튼 추가
    private func addButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
        if buttonName == "address" {
            
            mapView?.addSubview(addressView)
            
            addressView.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
            
        } else {
            let button = ShadowButton(type: .system)
            
            mapView?.addSubview(button)
            
            button.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
        }
    }
    
    //충전 버튼, 예약 버튼 추가
    private func addBottomButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject, targetViewController: AnyObject) {
        
        self.view.addSubview(bottomButton)
        
        bottomButton.setAttributes(buttonName: "bottomButton", width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target, targetViewController: targetViewController)
        
        bottomButton.gone()
        
        self.view.sendSubviewToBack(bottomButton)
    }
    
    private func addSearchingConditionView(width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
        mapView?.addSubview(searchingConditionView)
        
        searchingConditionView.setAttributes(width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
    }
    
    private func addCurrentLocationButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
        let view = ShadowCircleView()
        
        mapView?.addSubview(view)
        
        view.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
    }
    
    //검색조건 세팅
    func searchingConditionDelegate(data: SearchingConditionObject) {
        
        notificationCenter.post(name: .updateSearchingCondition, object: data, userInfo: nil)
    }
        
    @objc func updateSearchingCondition(_ notification: Notification) {
        
        receivedSearchingConditionObject = notification.object as? SearchingConditionObject
        
        searchingConditionView.setLabelText(chargingTimeText: receivedSearchingConditionObject.chargingTime, chargingPeriodText: receivedSearchingConditionObject.chargingPeriod)
        
        let calendar = Calendar.current
        let locale = Locale(identifier: "ko")
        let startDate = realDateFormatter.date(from: receivedSearchingConditionObject.realChargingStartDate)
        
        if receivedSearchingConditionObject.isInstantCharge {
            
            let minute = calendar.component(.minute, from: startDate!)
            let hour = calendar.component(.hour, from: startDate!)
            
            var availableDate = Date()
            
            if minute >= 0 && minute < 30 {
                availableDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: startDate!)!
            } else {
                availableDate = calendar.date(bySettingHour: hour, minute: 30, second: 0, of: startDate!)!
            }
            
            reservationStateBarDateFormatter.locale = locale
            reservationStateBarDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            reservationStateBarStartDate = reservationStateBarDateFormatter.string(from: availableDate)
            
            selectedTimePeriod = "\(selectedTimePeriodDateFormatter.string(from: Date())) - \(receivedSearchingConditionObject.chargingEndDate)"
            
            bottomButton.setTitle(title: "충전하기")
            
        } else {
            reservationStateBarStartDate = receivedSearchingConditionObject.realChargingStartDate.replacingOccurrences(of: ".000", with: "")
            selectedTimePeriod = "\(selectedTimePeriodDateFormatter.string(from: startDate!)) - \(receivedSearchingConditionObject.chargingEndDate)"
            bottomButton.setTitle(title: "예약하기")
        }
        
        print("selectedTimePeriod: \(selectedTimePeriod)")
    }
    
    //즐겨찾기에서 지도보기 클릭
    func favoriteDelegate(data: FavoriteObject) {
        
        notificationCenter.post(name: .lookFavorite, object: data, userInfo: nil)
    }
    
    @objc func lookFavorite(_ notification: Notification) {
        
        receivedFavoriteObject = notification.object as? FavoriteObject
    }
    
    func reservationPopupDelegate() {
        notificationCenter.post(name: .reservationPopup, object: nil, userInfo: nil)
        
    }
    
    @objc func reservationPopup(_ notification: Notification) {
        
        searchingConditionView.initializeLayer(chargingTime: self.receivedSearchingConditionObject.chargingTime, chargingPeriod: self.receivedSearchingConditionObject.chargingPeriod)
        addPoiItem()
    }
    
    func searchingAddressDelegate(data: SelectedPositionObject ) {
        print("searchingAddressDelegate")
        notificationCenter.post(name: .searchAddress, object: data, userInfo: nil)
        
    }
    
    @objc func searchingAddress(_ notification: Notification) {

        selectedAddressObject = notification.object as? SelectedPositionObject
       
        if let latitude = selectedAddressObject?.latitude , let longitude = selectedAddressObject?.longitude {

            let selectedAddress = MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude))
            moveMapView(mapPoint: selectedAddress!)
        }
        
        labelChange = false
        changeAddressButtonText(latitude: nil, longitude: nil, placeName: selectedAddressObject?.place_name)
        
    }
    
    func moveMapView(mapPoint : MTMapPoint){
        
        mTMapView?.setMapCenter( mapPoint, zoomLevel: 1, animated: true)
    
    }
    
    func startChargeDelegate() {
        notificationCenter.post(name: .startCharge, object: nil, userInfo: nil)
    }
    
    @objc func startCharge(_ notification: Notification) {
        
        print("충전 시작 ")
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchingCharger") as? SearchingChargerViewController else { return }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        
        let currentLocation = location?.mapPointGeo()
        if let latitude = currentLocation?.latitude, let longitude = currentLocation?.longitude{
            print("MTMapView updateCurrentLocation (\(latitude),\(longitude)) accuracy (\(accuracy))")
        }
    }
    
    func mapView(_ mapView: MTMapView?, updateDeviceHeading headingAngle: MTMapRotationAngle) {
        print("MTMapView updateDeviceHeading (\(headingAngle)) degrees")
    }
    
    //현재 위치 버튼
    @objc func currentLocationTrackingModeButton(sender: UIView!) {
        print("currentLocationTrackingModeButton")
        
        
        
        if hasLocationPermission() {
            
            if isCurrentLocationTrackingMode {
                
                mTMapView?.showCurrentLocationMarker = false
                mTMapView?.currentLocationTrackingMode = .off
                isCurrentLocationTrackingMode = false
                
            } else {

                mTMapView?.showCurrentLocationMarker = true
                mTMapView?.currentLocationTrackingMode = .onWithoutHeading
                isCurrentLocationTrackingMode = true
            }
        } else {
            requestGPSPermission()
        }
        
        
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
    }
    
    //현재 위치
    func getCurrentLocation(){
        
        if let latitude = locationManager.location?.coordinate.latitude , let longitude = locationManager.location?.coordinate.longitude{
            
            receivedSearchingConditionObject.gpxY = latitude
            receivedSearchingConditionObject.gpxX = longitude
        }
    }
    
    private func getReservation() {
     
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
                    print("예약 Obj : \(obj)")
                    
                    //현재 예약이 없을 때
                    if code == 204 {
                        
                        self.myUserDefaults.set(0, forKey: "reservationId")
                        self.myUserDefaults.set(nil, forKey: "reservationInfo")
                        self.myUserDefaults.set(0, forKey: "rechargeId")
                        self.myUserDefaults.set(false, forKey: "isCharging")
                        
                        self.searchingConditionView.initializeLayer(chargingTime: self.receivedSearchingConditionObject.chargingTime, chargingPeriod: self.receivedSearchingConditionObject.chargingPeriod)
                        
                    } else if code == 200 {
                        
                        let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        let instanceData = try JSONDecoder().decode(ReservationObject.self, from: JSONData)
                        
                        let reservationInfo: SearchingConditionObject! = SearchingConditionObject()
                        reservationInfo.realChargingStartDate = instanceData.startDate!
                        reservationInfo.realChargingEndDate = instanceData.endDate!
                        reservationInfo.chargerAddress = instanceData.chargerAddress!
                        reservationInfo.chargerId = instanceData.chargerId!
                        reservationInfo.chargerName = instanceData.chargerName!
                        reservationInfo.fee = instanceData.rangeOfFee!
                        reservationInfo.bleNumber = instanceData.bleNumber!
                        reservationInfo.gpxX = instanceData.gpsX!
                        reservationInfo.gpxY = instanceData.gpsY!
                        
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
                    }
                    
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)")
                    
                    self.myUserDefaults.set(0, forKey: "reservationId")
                    self.myUserDefaults.set(nil, forKey: "reservationInfo")
                    self.myUserDefaults.set(0, forKey: "rechargeId")
                    self.myUserDefaults.set(false, forKey: "isCharging")
                    
                    self.searchingConditionView.initializeLayer(chargingTime: self.receivedSearchingConditionObject.chargingTime, chargingPeriod: self.receivedSearchingConditionObject.chargingPeriod)
                }
            
            //예약이 없을 때
            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("예약 없음")
                    
                } else {
                    print("Unknown Error")
                }
                
                self.myUserDefaults.set(0, forKey: "reservationId")
                self.myUserDefaults.set(nil, forKey: "reservationInfo")
                self.myUserDefaults.set(0, forKey: "rechargeId")
                self.myUserDefaults.set(false, forKey: "isCharging")
                
                self.searchingConditionView.initializeLayer(chargingTime: self.receivedSearchingConditionObject.chargingTime, chargingPeriod: self.receivedSearchingConditionObject.chargingPeriod)
            }
            
            //메모리에 저장된 예약 정보 가져와서 예약한 화면 구성
            if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
                let reservationInfo: SearchingConditionObject? = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
                
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                print("ㅅㅂㅅㅂ. \(reservationInfo!.realChargingEndDate)")
                //충전 종료 일시
                //let realChargingEndDate = dateFormatter.date(from: reservationInfo!.realChargingEndDate)
                let realChargingEndDate = dateFormatter.date(from: reservationInfo!.realChargingEndDate)
                //현재 시간이 예약 종료 일시 보다 작으면 충전할 수 있게
                if Date() < realChargingEndDate! {
                    
                    self.searchingConditionView.setReservation(chargingTimeText: reservationInfo?.chargingTime, chargingPeriodText: reservationInfo?.chargingPeriod)
                    self.showSearchingConditionView()
                }
                
                //현재 시간이 예약 종료 일시보다 큰 경우 메모리의 예약 정보 초기화하고 검색조건 버튼 보이게
                else {
                    
                    self.myUserDefaults.set(0, forKey: "reservationId")
                    self.myUserDefaults.set(nil, forKey: "reservationInfo")
                    self.myUserDefaults.set(0, forKey: "rechargeId")
                    self.myUserDefaults.set(false, forKey: "isCharging")
                    
                    self.searchingConditionView.initializeLayer(chargingTime: self.receivedSearchingConditionObject.chargingTime, chargingPeriod: self.receivedSearchingConditionObject.chargingPeriod)
                }
            }
            
            self.activityIndicator!.stopAnimating()
        })
    }
   
    //view 가 나타난 후
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //즐겨찾기에서 지도보기 클릭 후 다시 메인으로 온 경우
        if receivedFavoriteObject != nil {
            
            for item in poiArray {
                
                if item.tag == receivedFavoriteObject?.chargerId {
                    
                    mTMapView?.setMapCenter(item.mapPoint, zoomLevel: 1, animated: true)
                    
                    receivedFavoriteObject = nil
                    break
                }
            }
        } else {
            if let defaultLatitude = locationManager.location?.coordinate.latitude , let defaultLongitude = locationManager.location?.coordinate.longitude{

                let DEFAULT_POSITION = MTMapPointGeo(latitude: defaultLatitude, longitude: defaultLongitude)
                mTMapView?.setMapCenter(MTMapPoint(geoCoord: DEFAULT_POSITION), zoomLevel: 1, animated: true)
            }

        }
        //예약 정보 가져오기
        getReservation()
    }
    
    func changeAddressButtonText(latitude : Double?, longitude : Double?, placeName : String?){
  
        if labelChange {
            if(latitude != nil && longitude != nil ){
            
                let location = CLLocation(latitude: latitude!, longitude: longitude!)
        
                geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            
                    if let addressInstance = placemarks?[0] {
                 
                        let address = addressInstance.name
                        self.addressView.setTitle(address, for: .normal)
                
                    }
                })
            }
        } else if placeName != nil {

            self.addressView.setTitle(placeName, for: .normal)
        }
        
    }
    
    
    private func checkDeviceFrame() -> CGFloat {
        
        let deviceHeight = UIScreen.main.nativeBounds.height

        if UIDevice().userInterfaceIdiom == .phone {
        
            switch deviceHeight {
            
            case 1136:
                print("iPhone 5 or 5S or 5C")
                
            case 1334:
                print("iPhone 6/6S/7/8")
                
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                
            case 2436:
                print("iPhone X/XS/11 Pro")
                
            case 2688:
                print("iPhone XS Max/11 Pro Max")
                
            case 1792:
                print("iPhone XR/ 11 ")
                
            default:
                print("Unknown")
            }
        }
        
        return deviceHeight
    }
    
    func checkDisableTime( reservationList: Array<CurrentReservationObject>){
        
        if reservationList == [] {
            
            disableReservationButton(able: true)
            return
            
        }
        
        for reservation in reservationList {
            
            let startDate = Calendar.current.date(byAdding: .minute, value: -30, to:realDateFormatter.date(from: reservation.startDate!+".000")!)
            let endDate = Calendar.current.date(byAdding: .minute, value: 30, to:realDateFormatter.date(from: reservation.endDate!+".000")!)
            
            if receivedSearchingConditionObject.realChargingStartDate >= realDateFormatter.string(from:startDate!) && receivedSearchingConditionObject.realChargingStartDate <= realDateFormatter.string(from:endDate!){
                    
                disableReservationButton(able: false)
                return
                
            } else if receivedSearchingConditionObject.realChargingEndDate >= realDateFormatter.string(from:startDate!) && receivedSearchingConditionObject.realChargingEndDate <= realDateFormatter.string(from:endDate!){
              
                disableReservationButton(able: false)
                return
                
            } else {
                
                disableReservationButton(able: true)
            }
            
        }
        
    }
    
    func disableReservationButton(able : Bool){
        
        bottomButton.isEnabled = able
        
        if able {
            
            bottomButton.layer.backgroundColor = Color3498DB?.cgColor
        
        } else {
        
            bottomButton.layer.backgroundColor = ColorE0E0E0?.cgColor
        }
       
    }
}
extension Notification.Name {
    static let updateSearchingCondition = Notification.Name("updateSearchingCondition")
    static let lookFavorite = Notification.Name("lookFavorite")
    static let reservationPopup = Notification.Name("reservationPopup")
    static let startCharge = Notification.Name("startCharge")
    static let searchAddress = Notification.Name("searchAddress")
}
