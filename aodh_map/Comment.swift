//
//  Comment.swift
//  aodh_map
//
//  Created by 海崎惇志 on 2018/07/21.
//  Copyright © 2018年 宮川奈々. All rights reserved.
//

import Foundation
import Firebase

struct Comment {
    var text: String!
    var goodCount: Int!
    var badCount: Int!
    var createdAt: Date!
    var documentID: String!
    var photo: String?
    var geopoint: GeoPoint!
    var name: String?
    
    
    init(document: QueryDocumentSnapshot) {
        text = document.get("text") as! String
        goodCount = document.get("good_count") as! Int
        badCount = document.get("bad_count") as! Int
        createdAt = document.get("created_at") as! Date
        documentID = document.documentID
        photo = document.get("photo") as? String
        geopoint = document.get("geopoint") as! GeoPoint
        name = document.get("name") as? String
    }
    
    init () {
        
    }
}
