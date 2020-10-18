//
//  RechargeObject.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/10/18.
//  Copyright © 2020 metisinfo. All rights reserved.
//
class ChargingHistoryObject: Codable {

    
    var content      : [InnerItem]
    
    struct InnerItem : Codable {
        var chargerId            : Int?
        var chargerName          : String?
        var created              : String?
        var endRechargeDate      : String?
        var chargerZipcode       : String?
        var endDate              : String?
        var expectPoint          : Int?
        var gpsX                 : Double?
        var gpsY                 : Double?
        var id                   : Int?
        var rangeOfFee           : String?
        var startDate            : String?
        var state                : String?
        var updated              : String?
        var userId               : Int?
        var username             : String?
    }
}
