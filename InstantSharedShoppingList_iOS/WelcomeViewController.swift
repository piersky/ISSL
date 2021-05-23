//
//  ViewController.swift
//  InstantSharedShoppingList_iOS
//
//  Created by Pier Luigi Papeschi on 14/07/2019.
//  Copyright © 2019 Pier Luigi Papeschi. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "gotoItems", sender: self)
            }
        }
    }

    @IBAction func loginPressed(_ sender: Any) {
        performSegue(withIdentifier: "gotoLogin", sender: self)
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        performSegue(withIdentifier: "gotoRegister", sender: self)
    }
    
}

