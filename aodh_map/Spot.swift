//
//  Spot.swift
//  aodh_map
//
//  Created by 海崎惇志 on 2018/07/22.
//  Copyright © 2018年 宮川奈々. All rights reserved.
//

import Foundation
import Firebase

struct Spot {
    var title = ""
    var photo = ""
    var description = ""
    var geopoint = GeoPoint(latitude: 0, longitude: 0)
    var documentID = ""
    
    
    init(document: QueryDocumentSnapshot) {
        title = document.get("title") as! String
        photo = document.get("photo") as! String
        description = document.get("description") as! String
        geopoint = document.get("geopoint") as! GeoPoint
        documentID = document.documentID
    }
    
    init() {
        
    }
}
