//
//  AppDelegate.swift
//  iOS
//
//  Created by Nil Puig on 16/11/2018.
//  Copyright © 2018 Nil Puig. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()

    window = UIWindow(frame: UIScreen.main.bounds)
    window!.rootViewController =  LoginViewController()
    window!.makeKeyAndVisible()

    return true
  }

}

