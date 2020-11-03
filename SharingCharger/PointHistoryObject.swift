//
//  PointHistoryObject.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/11/03.
//  Copyright © 2020 metisinfo. All rights reserved.
//
class PointHistoryObject: Codable {

    
    var numberOfElements    : Int?
    var content             : [InnerItem]
    
    struct InnerItem        : Codable {
        var id                   : Int?
        var username             : String?
        var type                 : String?
        var point                : Int?
        var created              : String?
    }
}
