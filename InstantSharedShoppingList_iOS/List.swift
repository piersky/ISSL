//
//  List.swift
//  InstantSharedShoppingList_iOS
//
//  Created by Pier Luigi Papeschi on 20/07/2019.
//  Copyright © 2019 Pier Luigi Papeschi. All rights reserved.
//

import Foundation

struct List {
    
    var name : String = ""
    var emailOwner : String = ""
    //var created: Date
    //var updated: Date
    //var createdBy: String //L'ID del proprietario
    // var lastUpdatedBy: String //L'ID di chi ha modificato la lista per ultimo
    
    var dictionary: [String: Any] {
        return[
            "name": name,
            "emailOwner": emailOwner
        ]
    }
}

extension List:DocumentSerializable {
        
    init?(dictionary: [String: Any]) {
        
        // The name must not be empty
        guard let name = dictionary["name"] as? String,
            let emailOwner = dictionary["emailOwner"] as? String
            else {
                return nil
        }
        
        self.init(name: name,
                  emailOwner: emailOwner)
    }
}
