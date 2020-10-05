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

class MainViewController: UIViewController, MTMapViewDelegate, SearchingConditionProtocol {
    
    @IBOutlet var mapView: UIView!
    var mTMapView: MTMapView?
    var searchingConditionView = ShadowView()
    
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
        addCurrentLocationButton(buttonName: "currentLocation", width: 40, height: 40, top: 70, left: nil, right: -15, bottom: nil, target: mapView)
        addView(width: nil, height: 110, top: nil, left: 15, right: -15, bottom: 0, target: mapView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSearchingCondition(_:)), name: .updateSearchingCondition, object: nil)
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
    
    @objc func menuButton(sender: UIButton!) {
        print("MainViewController - menuButton tapped")
        
        self.performSegue(withIdentifier: "segueToLeftMenu", sender: self)
    }
    
    @objc func addressButton(sender: UIButton!) {
        print("MainViewController - addressButton tapped")
    }
    
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
    
    @objc func currentLocationTrackingModeButton(sender: UIView!) {
        
        print("MainViewController - currentLocationTrackingModeButton tapped")
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "Reservation") else { return }
        
        self.navigationController?.pushViewController(uvc, animated: true)
    }
    
    private func addButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
        let button = ShadowButton(type: .system)
        
        mapView?.addSubview(button)
        
        button.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
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

    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
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
