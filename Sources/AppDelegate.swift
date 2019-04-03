//
//  AppDelegate.swift
//  Browser
//
//  Created by Simon Whitty on 3/4/19.
//  Copyright © 2019 Simon Whitty. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let nav = UINavigationController(rootViewController: ViewController())
        nav.setToolbarHidden(false, animated: false)

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}

