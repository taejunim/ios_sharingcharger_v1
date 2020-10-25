//
//  ReservationObject.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/10/13.
//  Copyright © 2020 metisinfo. All rights reserved.
//
class ReservationObject: Codable {
    
    var bleNumber: String?
    var cancelDate: String?
    var chargerId: Int?
    var chargerName: String?
    var created: String?
    var endDate: String?
    var expectPoint: Int?
    var id: Int?
    var startDate: String?
    var state: String?
    var updated: String?
    var userId: Int?
    var username: String?
    var gpsX: Double?
    var gpsY: Double?
    var reservationType: String?
    var chargerZipcode: String?
    var chargerAddress: String?
    var chargerDetailAddress: String?
    var rangeOfFee: String?
}
