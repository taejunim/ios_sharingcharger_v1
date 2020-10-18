//
//  FavoriteObject.swift
//  SharingCharger
//
//  Created by tjlim on 2020/10/13.
//  Copyright © 2020 metisinfo. All rights reserved.
//


import RealmSwift

class FavoriteObject: Object {
    
    @objc dynamic var chargerId: Int = 0
    @objc dynamic var chargerName: String = ""
    @objc dynamic var chargerAddress: String = ""
    
    // 기본키 설정
    override class func primaryKey() -> String? {
        return "chargerId"
    }
}
