//
//  Utils.swift
//  SharingCharger
//
//  Created by tjlim on 2020/10/10.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class Utils {
    
    private var superView: UIView?
    
    init(superView: UIView) {
        self.superView = superView
    }
    
    //Toast Message
    //How To Use : showToast(controller: self, message : "This is a test", seconds: 2.0)
    func showToast(controller: UIViewController, message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.red
        alert.view.alpha = 0.0
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
    //로딩 뷰
    lazy var activityIndicator: UIActivityIndicatorView = {
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = superView!.center
        activityIndicator.color = UIColor.darkGray
        // Also show the indicator even when the animation is stopped.
        activityIndicator.hidesWhenStopped = true
        //activityIndicator.style = UIActivityIndicatorView.Style.white
        activityIndicator.style = UIActivityIndicatorView.Style.large
        // Start animation.
        activityIndicator.stopAnimating()
        return activityIndicator }()
}
