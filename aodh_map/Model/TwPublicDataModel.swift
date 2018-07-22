//
//  TwPublicDataModel.swift
//  aodh_map
//
//  Created by 宮川奈々 on 2018/07/21.
//  Copyright © 2018年 宮川奈々. All rights reserved.
//

import Foundation
struct TwPublicDataModel :Decodable {
    let publics : [Public]
    struct Public : Decodable {
        var Place_name = ""
        var Chinese_phonetic = ""
        var Common_phonetic = ""
        var Another_name = ""
        var County = ""
        var Town = ""
        var Village = ""
        var Place_mean = ""
        var Year_f = ""
        var Year_l = ""
        var Place_type = ""
        var Language = ""
        var Denominate = ""
        var Place_describe = ""
        var History_describe = ""
        var Place_content = ""
        var Map_ref = ""
        var X = 0.0
        var Y = 0.0
    }
    
}
