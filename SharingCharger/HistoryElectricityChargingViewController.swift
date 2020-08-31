//
//  HistoryElectricityChargingViewController.swift
//  SharingCharger
//
//  Created by chihong an on 2020/08/31.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class HistoryElectricityChargingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var arr:Array = ["1","2"]
    
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.allowsSelection = false
        
        self.navigationController?.navigationBar.tintColor = UIColor.black  //백버튼 검은색으로
        self.navigationController?.navigationBar.topItem?.title = ""        //백버튼 텍스트 제거
        
        let rightBarButton = UIBarButtonItem.init(title: "right", style: .done, target: self, action: #selector(rightMenu))

        
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    
    @objc func rightMenu() {
        
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "Setting") else { return }
            
        self.navigationController?.pushViewController(uvc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let Cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for:indexPath)
        
        return Cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return arr.count
    }

    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return 120
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
