//
//  ChargeObject.swift
//  SharingCharger
//
//  Created by tjlim on 2020/10/27.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class ChargeObject: Codable {

    var id: Int?
    var chargerId: Int?
    var chargerName: String?
    var username: String?
    var reservationStartDate: String?
    var reservationEndDate: String?
    var startRechargeDate: String?
    var endRechargeDate: String?
    var reservationPoint: Int?
    var rechargePoint: Int?
    var created: String?
    var updated: String?
}
