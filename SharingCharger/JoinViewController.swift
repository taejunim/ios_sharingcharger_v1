//
//  JoinViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/10.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var tfName: CustomTextField!
    @IBOutlet weak var tfEmail: CustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.topItem?.title = ""
        
//        var image = UIImage(named: "LaunchImage")
//        image = image?.withRenderingMode(.alwaysOriginal)
//        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style:.plain, target: nil, action: nil)
//        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(image: image, style:.plain, target: nil, action: nil)
        
        let yourBackImage = UIImage(named: "btn_back")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        //self.navigationController?.navigationBar.backItem?.title = "Custom"
        
        tfEmail.setCurrentType(type: 1, target: self)
//        tfName.type = 0
//        tfEmail.type = 1
//        labelName.text = "이름"
//        labelEmail.text = "이메일"
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func buttonAction(sender: UIButton!) {
      print("Button tapped")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = false
  //      self.navigationController?.navigationBar.barTintColor = .gray

        

    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        self.navigationController?.isNavigationBarHidden = true
//
//    }

}
