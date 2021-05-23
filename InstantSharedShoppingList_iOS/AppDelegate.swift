//
//  AppDelegate.swift
//  InstantSharedShoppingList_iOS
//
//  Created by Pier Luigi Papeschi on 14/07/2019.
//  Copyright © 2019 Pier Luigi Papeschi. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

