//
//  MainViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/25.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialBottomSheet

class MainViewController: UIViewController, MTMapViewDelegate {

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
        addView(buttonName: "searchingCondition", width: nil, height: 110, top: nil, left: 15, right: -15, bottom: 0, target: mapView)
    }
    
    @objc func menuButton(sender: UIButton!) {
        print("MainViewController - menuButton tapped")
    }
    
    @objc func addressButton(sender: UIButton!) {
        print("MainViewController - addressButton tapped")
    }
    
    @objc func searchingConditionButton(sender: UIView!) {
        print("MainViewController - searchingConditionButton tapped")
        
        searchingConditionView.setLabelText(chargingTimeText: "60", chargingDateText: "9/20 (금) 22:30 ~ 23:30")
        
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
    }
    
    private func addButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
        let button = ShadowButton(type: .system)
        
        mapView?.addSubview(button)
        
        button.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
    }
    
    private func addView(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
        mapView?.addSubview(searchingConditionView)
        
        searchingConditionView.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
    }
    
    private func addCurrentLocationButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject) {
        
        let view = ShadowCircleView()
        
        mapView?.addSubview(view)
        
        view.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target)
        
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
