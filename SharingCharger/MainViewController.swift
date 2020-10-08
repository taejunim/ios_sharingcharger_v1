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

class MainViewController: UIViewController, MTMapViewDelegate, SearchingConditionProtocol {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mTMapView = MTMapView(frame: mapView.bounds)
        if let mTMapView = mTMapView {
            
            mTMapView.delegate = self
            mTMapView.baseMapType = .standard
            mapView.addSubview(mTMapView)
        }
        
        let DEFAULT_POSITION = MTMapPointGeo(latitude: 33.491450, longitude: 126.535555)
        
        mTMapView?.setMapCenter(MTMapPoint(geoCoord: DEFAULT_POSITION), zoomLevel: 1, animated: true)
        
        addButton(buttonName: "menu", width: 40, height: 40, top: 15, left: 15, right: nil, bottom: nil, target: mapView)
        addButton(buttonName: "address", width: nil, height: 40, top: 15, left: 70, right: -15, bottom: nil, target: mapView)
        addReservationButton(buttonName: "reservation", width: nil, height: 40, top: nil, left: 0, right: 0, bottom: 0, target: self.view)
        addCurrentLocationButton(buttonName: "currentLocation", width: 40, height: 40, top: 70, left: nil, right: -15, bottom: nil, target: mapView)
        addView(width: nil, height: 110, top: nil, left: 15, right: -15, bottom: 0, target: mapView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSearchingCondition(_:)), name: .updateSearchingCondition, object: nil)
        
        addPoiItem()
        
        chargerViewMinimumHeight = mapView.frame.height * 0.3
        chargerViewMaximumHeight = mapView.frame.height * 0.6
        
        print("chargerViewMinimumHeight : \(chargerViewMinimumHeight), chargerViewMaximumHeight : \(chargerViewMaximumHeight)")
    }
    
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        
        print("poi selected : \(poiItem.tag)")
        
        //현재 선택된 마커가 있을 때 -> 뷰는 고정시킨 채로 데이터만 바꿔줌
        if currentSelectedPoiItem != nil {
            
            chargerContentView.changeValue(chargerNameText: poiItem.itemName)
        }
        
        //검색 조건 버튼 숨기고 충전기 화면 올라옴
        else {
            searchingConditionView.isHidden = true
            searchingConditionView.gone()
            
            reservationView.visible()
            
            UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
            
            usleep(1000)
            
            chargerView = BottomSheetView(
                contentView: chargerContentView,
                contentHeights: [chargerViewMinimumHeight, chargerViewMaximumHeight]
            )
            
            chargerView?.present(in: view)
            
            chargerContentView.changeValue(chargerNameText: poiItem.itemName)
        }
        
        //현재 선택된 마커 저장
        currentSelectedPoiItem = poiItem
        
        self.view.bringSubviewToFront(reservationView)
        
        return false
    }

    //지도 클릭했을 때
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        
        print("singleTapOn ")
        
        //충전기 화면 사라짐
        chargerView?.dismiss()
        
        //검색 조건 버튼 올라옴
        searchingConditionView.isHidden = false
        searchingConditionView.visible()
        
        reservationView.gone()
        
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
        
        //현재 선택된 마커 지움
        currentSelectedPoiItem = nil
    }
    
    private func addPoiItem() {
        
        let poiItem: MTMapPOIItem = MTMapPOIItem()
        poiItem.itemName = "충전기1"
        poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: 33.491450, longitude: 126.535555))
        poiItem.markerType = MTMapPOIItemMarkerType.bluePin
        poiItem.tag = 1
        
        var poiArray = Array<MTMapPOIItem>()
        poiArray.append(poiItem)
        
        let poiItem2: MTMapPOIItem = MTMapPOIItem()
        poiItem2.itemName = "충전기2"
        poiItem2.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: 33.491550, longitude: 126.536655))
        poiItem2.markerType = MTMapPOIItemMarkerType.bluePin
        poiItem2.tag = 2
        
        poiArray.append(poiItem2)
        
        mTMapView?.addPOIItems(poiArray)
    }
    
    @objc func reservationButton(sender: UIButton!) {
        print("MainViewController - Button tapped")
        
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "Reservation") else { return }
        
        self.navigationController?.pushViewController(uvc, animated: true)
        
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
    }
    
    //검색 조건 버튼
    @objc func searchingConditionButton(sender: UIView!) {
        print("MainViewController - searchingConditionButton tapped")
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchingCondition") else { return }
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: mapView.frame.size.width, height: mapView.frame.size.height)
        
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
    private func addReservationButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
        self.view.addSubview(reservationView)
        
        reservationView.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
        reservationView.gone()
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
    
    func searchingConditionDelegate(data: SearchingConditionObject) {
        
        print("data.chargingTime : \(data.chargingTime)")
        print("data.chargingPeriod : \(data.chargingPeriod)")
        
        NotificationCenter.default.post(name: .updateSearchingCondition, object: data, userInfo: nil)
    }
    
    @objc func updateSearchingCondition(_ notification: Notification) {
        
        let data = notification.object as! SearchingConditionObject
        print("data : \(data)")
        
        searchingConditionView.setLabelText(chargingTimeText: data.chargingTime, chargingDateText: data.chargingPeriod)
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
    
}

extension Notification.Name {
    static let updateSearchingCondition = Notification.Name("updateSearchingCondition")
}
