//
//  FavoriteViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/10/13.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import RealmSwift

protocol FavoriteProtocol {
    func favoriteDelegate(data: FavoriteObject)
}

class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: FavoriteProtocol?
    
    @IBOutlet var tableView: UITableView!
    
    var favoriteArray:[FavoriteObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.delegate = MainViewController()    //선택한 검색 조건들을 MainViewController 로 넘김
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)  //table view margin 제거
        
        let realm = try! Realm()
        let favoriteObject = realm.objects(FavoriteObject.self)
        
        favoriteArray = Array(favoriteObject)
    }
    
    @objc func mapButton(sender: UIButton) {
        
        let favoriteObject = favoriteArray[sender.tag]
        
        delegate?.favoriteDelegate(data: favoriteObject)
        
        self.navigationController?.popViewController(animated: true)
        
        //카카오맵 실행
//        let kakaomap = "kakaomap://route?sp=37.537229,127.005515&ep=37.4979502,127.0276368&by=CAR"
//
//        if let appurl = URL(string: kakaomap) {
//            if  UIApplication.shared.canOpenURL(appurl){
//                UIApplication.shared.open(appurl, options: .init()) { (finished) in
//                    if finished {
//                        print("finished !!")
//                    }
//                }
//            }
//        }
    }
    
    @objc func deleteButton(sender: UIButton) {
        
        let refreshAlert = UIAlertController(title: "즐겨찾기 삭제", message: "해당 충전기를 즐겨찾기에서 삭제하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action: UIAlertAction!) in
            
            let realm = try! Realm()
            
            let favoriteObject = realm.objects(FavoriteObject.self).filter("chargerId == \(sender.tag)")
            
            try! realm.write {
                realm.delete(favoriteObject)
            }
            
            self.favoriteArray = Array(realm.objects(FavoriteObject.self))
            
            self.tableView.reloadData()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favoriteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.favoriteArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCustomCell", for:indexPath) as! FavoriteCell
        cell.chargerNameLabel?.text = row.chargerName
        cell.chargerAddressLabel?.text = row.chargerAddress
        cell.mapButton.addTarget(self, action: #selector(self.mapButton(sender:)), for: .touchUpInside)
        cell.mapButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(self.deleteButton(sender:)), for: .touchUpInside)
        cell.deleteButton.tag = row.chargerId
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120
    }
}
