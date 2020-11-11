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

class MainViewController: UIViewController, MTMapViewDelegate, SearchingConditionProtocol, FavoriteProtocol, ReservationPopupProtocol {
    
    var delegate: SearchingConditionProtocol?
    
    @IBOutlet var mapView: UIView!
    var mTMapView: MTMapView?
    var searchingConditionView = ShadowView()
    var chargerView: BottomSheetView?
    var chargerContentView = ChargerContentView()
    
    var chargerViewMinimumHeight: CGFloat = 0       //충전기 화면 최소 높이
    var chargerViewMaximumHeight: CGFloat = 0       //충전기 화면 최대 높이
    
    var currentSelectedPoiItem: MTMapPOIItem?       //현재 선택된 마커
    
    var reservationView = CustomButton(type: .system)
    
    var isCurrentLocationTrackingMode = false
    
    let myUserDefaults = UserDefaults.standard
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    var poiArray = Array<MTMapPOIItem>()
    
    var selectedChargerObject: ChargerObject?
    var receivedSearchingConditionObject: SearchingConditionObject! = SearchingConditionObject()
    var receivedFavoriteObject: FavoriteObject? = nil
    
    let dateFormatter = DateFormatter()
    let realDateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mTMapView = MTMapView(frame: mapView.bounds)
        if let mTMapView = mTMapView {
            
            mTMapView.delegate = self
            mTMapView.baseMapType = .standard
            mapView.addSubview(mTMapView)
        }
        
        let DEFAULT_POSITION = MTMapPointGeo(latitude: 33.4524448, longitude: 126.5676508)
        
        mTMapView?.setMapCenter(MTMapPoint(geoCoord: DEFAULT_POSITION), zoomLevel: 1, animated: true)
        
        addButton(buttonName: "menu", width: 40, height: 40, top: 15, left: 15, right: nil, bottom: nil, target: mapView)
        addButton(buttonName: "address", width: nil, height: 40, top: 15, left: 70, right: -15, bottom: nil, target: mapView)
        addReservationButton(buttonName: "reservation", width: nil, height: 40, top: nil, left: 0, right: 0, bottom: 0, target: self.view, targetViewController: self)
        addCurrentLocationButton(buttonName: "currentLocation", width: 40, height: 40, top: 70, left: nil, right: -15, bottom: nil, target: mapView)
        addView(width: nil, height: 110, top: nil, left: 15, right: -15, bottom: 0, target: mapView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSearchingCondition(_:)), name: .updateSearchingCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lookFavorite(_:)), name: .lookFavorite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reservationPopup(_:)), name: .reservationPopup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startCharge(_:)), name: .startCharge, object: nil)
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        self.activityIndicator!.hidesWhenStopped = true
        
        addPoiItem()
        
        chargerViewMinimumHeight = mapView.frame.height * 0.3
        chargerViewMaximumHeight = mapView.frame.height * 0.6
        
        viewWillInitializeObjects()
    }
    
    private func viewWillInitializeObjects() {
        
        let date = Date()
        let locale = Locale(identifier: "ko")
        
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        realDateFormatter.locale = locale
        realDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        receivedSearchingConditionObject.realChargingStartDate = realDateFormatter.string(from: date)

        let endDate = Calendar.current.date(byAdding: .minute, value: 30, to: date)!
        receivedSearchingConditionObject.realChargingEndDate = realDateFormatter.string(from: endDate)
        
        receivedSearchingConditionObject.realChargingPeriod = dateFormatter.string(from: date) + " ~ " + dateFormatter.string(from: endDate)
    }
    
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
            let url = "http://211.253.37.97:8101/api/v1/chargers/\(chargerId)"
            
            AF.request(url, method: .get, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
                
                code = response.response?.statusCode
                
                switch response.result {
                
                case .success(let obj):
                    
                    print("obj : \(obj)")
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
                        print("Error : \(code!)")
                        self.view.makeToast("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", duration: 2.0, position: .bottom)
                    }
                }
                
                self.mTMapView?.setMapCenter(poiItem.mapPoint, zoomLevel: 1, animated: true)
                
                //현재 선택된 마커가 있을 때 -> 뷰는 고정시킨 채로 데이터만 바꿔줌
                if self.currentSelectedPoiItem != nil {
                    
                    self.chargerContentView.changeValue(chargerNameText: poiItem.itemName, chargerId: poiItem.tag, chargerAddressText: self.selectedChargerObject?.address, rangeOfFeeText: self.selectedChargerObject?.rangeOfFee)
                }
                
                //검색 조건 버튼 숨기고 충전기 화면 올라옴
                else {
                    self.searchingConditionView.isHidden = true
                    self.searchingConditionView.gone()
                    
                    self.reservationView.visible()
                    
                    UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
                    
                    usleep(1000)
                    
                    self.chargerView = BottomSheetView(
                        contentView: self.chargerContentView,
                        contentHeights: [self.chargerViewMinimumHeight, self.chargerViewMaximumHeight]
                    )
                    
                    self.chargerView?.present(in: self.view)
                    
                    self.chargerContentView.changeValue(chargerNameText: poiItem.itemName, chargerId: poiItem.tag, chargerAddressText: self.selectedChargerObject?.address, rangeOfFeeText: self.selectedChargerObject?.rangeOfFee)
                }
                
                //현재 선택된 마커 저장
                self.currentSelectedPoiItem = poiItem
                
                self.view.bringSubviewToFront(self.reservationView)
                
                self.activityIndicator!.stopAnimating()
            })
        }
        
        return false
    }

    //지도 클릭했을 때
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        
        print("singleTapOn ")
        
        showSearchingConditionView()
        
        selectedChargerObject = nil
    }
    
    private func showSearchingConditionView() {
        //충전기 화면 사라짐
        chargerView?.dismiss()
        
        //검색 조건 버튼 올라옴
        searchingConditionView.isHidden = false
        searchingConditionView.visible()
        
        reservationView.gone()
        
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
        
        //현재 선택된 마커 지움
        currentSelectedPoiItem = nil
        
        self.view.sendSubviewToBack(reservationView)
    }
    
    private func addPoiItem() {
        
        var code: Int! = 0
        let url = "http://211.253.37.97:8101/api/v1/chargers"
        
        let parameters: Parameters = [
            "sort":"ASC",
            "acceptType":"ALL",
            "currentStatusType":"ALL",
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
                    let instanceData = try JSONDecoder().decode(MarkersObject.self, from: JSONData)
                    
                    self.poiArray = Array<MTMapPOIItem>()
                    
                    for content in instanceData.content {
                        
                        if(content.name != nil && content.gpsX != nil && content.gpsY != nil && content.id != nil){
                            
                            let poiItem: MTMapPOIItem = MTMapPOIItem()
                            poiItem.itemName = content.name
                            poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: content.gpsY!, longitude: content.gpsX!))
                            poiItem.markerType = MTMapPOIItemMarkerType.bluePin
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
                    print("Error : \(code!)")
                    self.view.makeToast("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", duration: 2.0, position: .bottom)
                }
            }
            
            self.activityIndicator!.stopAnimating()
        })
        
    }
    
    @objc func reservationButton(sender: UIButton!) {
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
    
    //Side Menu
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToLeftMenu" {
            if let sideMenuNavigationController = segue.destination as? SideMenuNavigationController {
                
                sideMenuNavigationController.settings = makeSettings()
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
        //UserDefaults.standard.set(0, forKey: "reservationId")
        //UserDefaults.standard.set(nil, forKey: "reservationInfo")
        let viewController: UIViewController!
        let bottomSheet: MDCBottomSheetController!
        
        viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddressPopup")
        bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: mapView.frame.size.width, height: mapView.frame.size.height)
        
        present(bottomSheet, animated: true, completion: nil)
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
        let viewController: UIViewController! = self.storyboard?.instantiateViewController(withIdentifier: "ReservationPopup")
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
        
        let button = ShadowButton(type: .system)
        
        mapView?.addSubview(button)
        
        button.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
    }
    
    //예약하기 버튼
    private func addReservationButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject, targetViewController: AnyObject) {
        
        self.view.addSubview(reservationView)
        
        reservationView.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target, targetViewController: targetViewController)
        reservationView.gone()
        self.view.sendSubviewToBack(reservationView)
    }
    
    private func addView(width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
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
        
        print("data.chargingTime : \(data.chargingTime)")
        print("data.chargingPeriod : \(data.chargingPeriod)")
        
        NotificationCenter.default.post(name: .updateSearchingCondition, object: data, userInfo: nil)
    }
    
    @objc func updateSearchingCondition(_ notification: Notification) {
        
        receivedSearchingConditionObject = notification.object as? SearchingConditionObject
        
        searchingConditionView.setLabelText(chargingTimeText: receivedSearchingConditionObject.chargingTime, chargingPeriodText: receivedSearchingConditionObject.chargingPeriod)
    }
    
    //즐겨찾기에서 지도보기 클릭
    func favoriteDelegate(data: FavoriteObject) {
        
        NotificationCenter.default.post(name: .lookFavorite, object: data, userInfo: nil)
    }
    
    @objc func lookFavorite(_ notification: Notification) {
        
        receivedFavoriteObject = notification.object as? FavoriteObject
    }
    
    func reservationPopupDelegate() {
        NotificationCenter.default.post(name: .reservationPopup, object: nil, userInfo: nil)
    }
    
    @objc func reservationPopup(_ notification: Notification) {
        
        searchingConditionView.initializeLayer()
    }
    
    func startChargeDelegate() {
        NotificationCenter.default.post(name: .startCharge, object: nil, userInfo: nil)
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
        
        if isCurrentLocationTrackingMode {
            
            mTMapView?.showCurrentLocationMarker = false
            mTMapView?.currentLocationTrackingMode = .off
            
            isCurrentLocationTrackingMode = false
            
        } else {
        
            mTMapView?.showCurrentLocationMarker = true
            mTMapView?.currentLocationTrackingMode = .onWithoutHeading
            
            isCurrentLocationTrackingMode = true
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
                    }
                    
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)")
                    
                    self.searchingConditionView.initializeLayer()
                }
            
            //예약이 없을 때
            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("예약 없음")
                    
                } else {
                    print("Error : \(code!)")
                }
                
                self.searchingConditionView.initializeLayer()
            }
            
            //메모리에 저장된 예약 정보 가져와서 예약한 화면 구성
            if let data = self.myUserDefaults.value(forKey: "reservationInfo") as? Data {
                let reservationInfo: SearchingConditionObject? = try? PropertyListDecoder().decode(SearchingConditionObject.self, from: data)
                
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                //충전 종료 일시
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
                    self.searchingConditionView.initializeLayer()
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
        }
        
        //예약 정보 가져오기
        getReservation()
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
}

extension Notification.Name {
    static let updateSearchingCondition = Notification.Name("updateSearchingCondition")
    static let lookFavorite = Notification.Name("lookFavorite")
    static let reservationPopup = Notification.Name("reservationPopup")
    static let startCharge = Notification.Name("startCharge")
}
