//
//  User.swift
//  InstantSharedShoppingList_iOS
//
//  Created by Pier Luigi Papeschi on 20/07/2019.
//  Copyright © 2019 Pier Luigi Papeschi. All rights reserved.
//

import Foundation

class User {
    
    var name : String = ""
    var email : String = ""
    var created : String = ""
    
    init?(name: String, email: String) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        guard !email.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.email = email
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        self.created = dateFormatter.string(from: Date())
    }
    
    func toArray() -> [String] {
        
        return [name, email, created]
    }
}
