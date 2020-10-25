//
//  HistoryPointViewController.swift
//  SharingCharger
//
//  Created by chihong an on 2020/08/27.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class HistoryPointViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    

    var arr:Array = ["1","2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.allowsSelection = false
        
        let rightBarButton = UIBarButtonItem.init(title: "right", style: .done, target: self, action: #selector(rightMenu))
        
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
                
        super.viewWillAppear(animated)
    }

    @objc func rightMenu() {
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Setting") else { return }
            
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let Cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for:indexPath)
        
        return Cell
    }
}
