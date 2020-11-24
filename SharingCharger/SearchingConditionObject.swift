//
//  SearchingConditionObject.swift
//  SharingCharger
//
//  Created by tjlim on 2020/09/25.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class SearchingConditionObject: Codable {

    var chargingPeriod: String = ""
    var chargingStartDate: String = ""
    var chargingEndDate: String = ""
    var chargingTime: String = ""
    //var chargingTime: String = "30분"
    var isInstantCharge: Bool = true
    
    //예약 화면용 변수
    var realChargingStartDate: String = ""
    var realChargingEndDate: String = ""
    var realChargingPeriod: String = ""
    var realChargingTime: String = ""
    
    var chargerId: Int = 0
    var chargerAddress: String = ""
    var chargerName: String = ""
    var fee: String = ""
    
    var bleNumber: String = ""
    
    //예약된 충전기의 좌표를 카카오맵으로 넘기기 위한 변수
    var gpxX: Double?
    var gpxY: Double?
    
    init() {
        let date = Date()
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "ko")
        dateFormatter.dateFormat = "MM/dd (E) HH:mm"
        
        timeFormatter.locale = Locale(identifier: "ko")
        timeFormatter.dateFormat = "HH:mm"
        
        chargingStartDate = dateFormatter.string(from: date)

        let endDate = Calendar.current.date(byAdding: .minute, value: 30, to: date)!
        chargingEndDate = dateFormatter.string(from: endDate)
        
        chargingPeriod = dateFormatter.string(from: date) + " ~ " + timeFormatter.string(from: endDate)
    }
}
