//
//  Item.swift
//  InstantSharedShoppingList_iOS
//
//  Created by Pier Luigi Papeschi on 20/07/2019.
//  Copyright © 2019 Pier Luigi Papeschi. All rights reserved.
//

import Foundation
import Firebase

struct Item {
    
    var id : String = ""
    var name : String = ""
    var isChecked : Bool = false
    var order : Int = 0
    var category : String = ""
    var count : Int = 0
    var supermarket : String = ""
    var date : Date
    //var addedBy: String //L'ID di chi l'ha aggiunto
    
    var dictionary: [String: Any] {
        return[
            "id": id,
            "name": name,
            "isChecked": isChecked,
            "order": order,
            "category": category,
            "count": count,
            "supermarket": supermarket,
            "timestamp": date
        ]
    }
}

extension Item: DocumentSerializable {
    
    init?(dictionary: [String: Any]) {
        
        // The name must not be empty
        guard let name = dictionary["name"] as? String,
            let id = dictionary["id"] as? String,
            let isChecked = dictionary["isChecked"] as? Bool,
            let order = dictionary["order"] as? Int,
            let category = dictionary["category"] as? String,
            let count = dictionary["count"] as? Int,
            let supermarket = dictionary["supermarket"] as? String,
            let date = dictionary["timestamp"] as? Timestamp
            else {
                return nil
        }
        
        self.init(id: id,
                  name: name,
                  isChecked: isChecked,
                  order: order,
                  category: category,
                  count: count,
                  supermarket: supermarket,
                  date: date.dateValue())
    }
}

