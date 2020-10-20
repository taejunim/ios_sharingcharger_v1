//
//  ChargingHistoryObject.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/10/18.
//  Copyright © 2020 metisinfo. All rights reserved.
//
class ChargingHistoryObject: Codable {

    
    var content      : [InnerItem]
    
    struct InnerItem : Codable {
        var id                   : Int?
        var chargerId            : Int?
        var chargerName          : String?
        var username             : String?
        var reservationStartDate : String?
        var reservationEndDate   : String?
        var startRechargeDate    : String?
        var endRechargeDate      : String?
        var reservationPoint     : Int?
        var rechargePoint        : Int?
        var created              : String?
        var updated              : String?
    }
}
