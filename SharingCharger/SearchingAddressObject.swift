//
//  SearchingAddressObject.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/11/14.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class SearchingAddressObject: Codable {

    

    var documents: [Place]
    
    struct Place: Codable {
        var id                   : String?
        var place_name           : String?
        var category_name        : String?
        var category_group_code  : String?
        var category_group_name  : String?
        var phone                : String?
        var address_name         : String?
        var road_address_name    : String?
        var x                    : String?
        var y                    : String?
        var place_url            : String?
        var distance             : String?
    }
    
}
