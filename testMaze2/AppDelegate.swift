//
//  AppDelegate.swift
//  testMaze2
//
//  Created by Jenn Halvorsen on 8/9/17.
//  Copyright © 2017 Right Brothers. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var backgroundDelegate : MovingToBackgroundDelegate?
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
              Fabric.with([Crashlytics.self])
        
        let mazes = ["1-1","1-2","1-3","1-4","1-5","1-6","1-7","1-8","1-9",
                     "2-1","2-2","2-3","2-4","2-5","2-6","2-7","2-8","2-9",
                     "3-1","3-2","3-3","3-4","3-5","3-6","3-7","3-8","3-9",
                     "4-1","4-2","4-3","4-4","4-5","4-6","4-7","4-8","4-9",
                     "5-1","5-2","5-3","5-4","5-5","5-6","5-7","5-8","5-9",
                     "6-1","6-2","6-3","6-4","6-5","6-6","6-7","6-8","6-9",
                     "7-1","7-2","7-3","7-4","7-5","7-6","7-7","7-8","7-9",
                     "8-1","8-2","8-3","8-4","8-5","8-6","8-7","8-8","8-9",
                     "9-1","9-2","9-3","9-4","9-5","9-6","9-7","9-8","9-9",
                     "10-1","10-2","10-3","10-4","10-5","10-6","10-7","10-8","10-9",
                     "11-1","11-2","11-3","11-4","11-5","11-6","11-7","11-8","11-9"
        ]
        for items in mazes {
            Global.highScores[items] = UserDefaults.standard.integer(forKey: items)
        }
        print("highscores dictionary: \(Global.highScores)")
        if UserDefaults.standard.bool(forKey: "isWeaponsMember") {
            Global.isWeaponsMember = true
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let viewController = self.window?.rootViewController as! ViewController
        viewController.pause()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
        
        let viewController = self.window?.rootViewController as! ViewController
        viewController.run()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

