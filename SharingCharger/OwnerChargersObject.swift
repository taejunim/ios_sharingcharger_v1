//
//  OwnerChargersObject.swift
//  SharingCharger
//
//  Created by tjlim on 2020/12/30.
//  Copyright © 2020 metisinfo. All rights reserved.
//

class OwnerChargersObject: Codable {

    var content             : [InnerItem]
    
    struct InnerItem        : Codable {
        var id: Int?
        var ownerType: String?
        var ownerName: String?
        var name: String?
        var description: String?
        var zipcode: String?
        var address: String?
        var detailAddress: String?
        var gpsX: Double?
        var gpsY: Double?
        var parkingFeeFlag: Bool?
        var parkingFeeDescription: String?
        var bleNumber: String?
        var currentStatusType: String?
        var acceptType: String?
        var rangeOfFee: String?
        var cableFlag: Bool?
        var maker: String?
        var created: String?
        var updated: String?
    }
}
