//
//  AppDelegate.swift
//  Raja
//
//  Created by HTS-MAC on 11/06/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.setOwnProfileDetail()
        
        let localObj = LocalStorage()
        localObj.createDB()
        localObj.createTable()
        return true
    }
        
    func setOwnProfileDetail(){
        let ownProfileDetatils = NSMutableDictionary()
        ownProfileDetatils.setValue("raja", forKey: "userName")
        ownProfileDetatils.setValue("RAJA", forKey: "name")
        ownProfileDetatils.setValue("https://i.postimg.cc/ncLD0Swf/007.jpg", forKey: "userImageUrl")
        ownProfileDetatils.setValue("This is AlaguRaja From madurai", forKey: "bio")
        ownProfileDetatils.setValue("rajahook.com", forKey: "link")
        ownProfileDetatils.setValue("November 2022", forKey: "join_date")
        ownProfileDetatils.setValue("6", forKey: "following_count")
        ownProfileDetatils.setValue("3", forKey: "followers_count")
        UserDefaults.standard.setValue(ownProfileDetatils, forKey: "ownProfileDetatils")
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

