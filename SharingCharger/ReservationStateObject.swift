//
//  ReservationStateObject.swift
//  SharingCharger
//
//  Created by tjlim on 2020/11/20.
//  Copyright © 2020 metisinfo. All rights reserved.
//

class ReservationStateObject: Codable {
    
    var chargerTimeAvailable: [chargerTimeAvailableArray]
    
    struct chargerTimeAvailableArray: Codable {
        var id: Int?
        var chargerId: Int?
        var day: String?
        var allowTimeOfDays: [allowTimeOfDaysArray]
        var created: String?
    }
    
    struct allowTimeOfDaysArray: Codable {
        var id: Int?
        var openTime: String?
        var closeTime: String?
        var created: String?
        var updated: String?
    }
    
    var reservations: reservationsObject
    
    struct reservationsObject: Codable {
        var content: [reservationList]
    }
    
    struct reservationList: Codable {
        var id: Int?
        var userId: Int?
        var username: String?
        var chargerId: Int?
        var chargerName: String?
        var chargerZipcode: String?
        var chargerAddress: String?
        var chargerDetailAddress: String?
        var rangeOfFee: String?
        var expectPoint: Int?
        var startDate: String?
        var endDate: String?
        var cancelDate: String?
        var state: String?
        var created: String?
        var updated: String?
        var gpsX: Double?
        var gpsY: Double?
        var bleNumber: String?
    }
    
}
