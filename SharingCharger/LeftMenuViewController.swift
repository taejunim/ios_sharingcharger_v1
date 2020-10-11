//
//  LeftMenuViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/09/28.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class LeftMenuViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var pointLabel: UILabel!
    @IBOutlet var reservationStateLabel: UILabel!
    @IBOutlet var pointCharge: UIButton!
    @IBOutlet var chargingHistoryLabel: UILabel!
    @IBOutlet var pointHistoryLabel: UILabel!
    @IBOutlet var favoriteLabel: UILabel!
    @IBOutlet var callCenterLabel: UILabel!
    
    let myUserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLeftMenu()
    }
    
    private func initializeLeftMenu() {
        
        //print("LeftMenuViewController - initializeLeftMenu")
        
        pointCharge.addTarget(self, action: #selector(pointChargeButton(sender:)), for: .touchUpInside)
        nameLabel.text = myUserDefaults.string(forKey: "name")
        emailLabel.text = myUserDefaults.string(forKey: "email")
        
        let chargingHistoryGesture = UITapGestureRecognizer(target: self, action: #selector(self.chargingHistoryButton(_:)))
        chargingHistoryLabel.isUserInteractionEnabled = true
        chargingHistoryLabel.addGestureRecognizer(chargingHistoryGesture)
        
        let pointHistoryGesture = UITapGestureRecognizer(target: self, action: #selector(self.pointHistoryButton(_:)))
        pointHistoryLabel.isUserInteractionEnabled = true
        pointHistoryLabel.addGestureRecognizer(pointHistoryGesture)
        
        let favoriteGesture = UITapGestureRecognizer(target: self, action: #selector(self.favoriteButton(_:)))
        favoriteLabel.isUserInteractionEnabled = true
        favoriteLabel.addGestureRecognizer(favoriteGesture)
        
        let callCenterGesture = UITapGestureRecognizer(target: self, action: #selector(self.callCenterButton(_:)))
        callCenterLabel.isUserInteractionEnabled = true
        callCenterLabel.addGestureRecognizer(callCenterGesture)
        
    }
    
    @IBAction func settingButton(_ sender: Any) {
        print("LeftMenuViewController - Button tapped")
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "Setting") else { return }
        
        self.navigationController?.pushViewController(uvc, animated: true)
    }
    
    @objc func pointChargeButton(sender: UIView!) {
        
        print("충전하기 이벤트")

    }
    
    @objc func chargingHistoryButton(_ sender: UITapGestureRecognizer) {
        
        print("chargingHistoryButton")
        
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "ChargingHistory") else { return }
        
        self.navigationController?.pushViewController(uvc, animated: true)

    }
    
    @objc func pointHistoryButton(_ sender: UITapGestureRecognizer) {
        
        print("pointHistoryButton")
        
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "PointHistory") else { return }
        
        self.navigationController?.pushViewController(uvc, animated: true)

    }
    
    @objc func favoriteButton(_ sender: UITapGestureRecognizer) {
        
        print("favoriteButton")

    }
    
    @objc func callCenterButton(_ sender: UITapGestureRecognizer) {
        
        print("callCenterButton")

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
