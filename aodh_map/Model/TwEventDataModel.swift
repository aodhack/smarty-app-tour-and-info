//
//  TwEventDataModel.swift
//  aodh_map
//
//  Created by 宮川奈々 on 2018/07/21.
//  Copyright © 2018年 宮川奈々. All rights reserved.
//

import Foundation

struct TwEventDataModel : Decodable{
    let models : [Events]
    struct Events : Decodable {
        var actId = 0
        var actName = ""
        var levelName = ""
        var grade1 = ""
        var grade2 = ""
        var grade3 = ""
        var grade4 = ""
        var grade5 = ""
        var grade6 = ""
        var description = ""
        var participation = ""
        var cityId = 0
        var address = ""
        var tel = ""
        var org = ""
        var startTime = ""
        var endTime = ""
        var cycle = ""
        var noncycle = ""
        var website = ""
        var longitude = 0.0
        var latitude = 0.0
        var class1 = 0
        var class2 = 0
        var map = ""
        var travellinginfo = ""
        var parkinginfo = ""
        var charge = ""
        var remarks = ""
        var cityName = ""
        var imageUrl = ""
    }
}
