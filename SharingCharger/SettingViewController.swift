//
//  SettingViewController.swift
//  SharingCharger
//
//  Created by chihong an on 2020/08/26.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var LogoutButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = UIColor.black  //백버튼 검은색으로
        self.navigationController?.navigationBar.topItem?.title = ""        //백버튼 텍스트 제거

        LogoutButton.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
