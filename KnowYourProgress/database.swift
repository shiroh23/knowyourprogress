//
//  database.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 10. 13..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import RealmSwift

class database: Object {
    
// Specify properties to ignore (Realm won't persist these)
    dynamic var name = ""
    dynamic var specimenDescription = ""
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var created = NSDate()
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
