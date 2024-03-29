//
//  AppDelegate.swift
//  ShareTogether
//
//  Created by littlema on 2019/8/27.
//  Copyright © 2019 littema. All rights reserved.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var appCoordinator: AppCoordinator!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupThirdParty()
        
        setupPushNotification(application: application)
        
        loadDefaultData()
                    
        window = UIWindow.init(frame: UIScreen.main.bounds)
        
        appCoordinator = AppCoordinator(window: window!)
        
        window?.makeKeyAndVisible()
        
        window!.tintColor = .STTintColor
        
        window!.overrideUserInterfaceStyle = .light
        
        appCoordinator.start()
        
//        if CurrentManager.shared.user != nil {
//            self.window?.rootViewController = UIStoryboard.main.instantiateInitialViewController()!
//        } else {
//            self.window?.rootViewController = UIStoryboard.login.instantiateInitialViewController()!
//        }
//
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:])
        -> Bool {
            return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
      
    /// 推播失敗的訊息
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
      
    /// 取得 DeviceToken，通常 for 後台人員推播用
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        // 將 Data 轉成 String
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("deviceTokenString: \(deviceTokenString)")
        
    }
}

extension AppDelegate {
    
    func setupThirdParty() {
        IQKeyboardManager.shared.enable = true
        
        FirebaseApp.configure()
        
        Firestore.firestore()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        GIDSignIn.sharedInstance().delegate = AuthManager.shared
    }
    
    func setupPushNotification(application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self

            // 在程式一啟動即詢問使用者是否接受圖文(alert)、聲音(sound)、數字(badge)三種類型的通知
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge],
                                                                    completionHandler: { granted, error in
                    if granted {
                        print("允許...")
                    } else {
                        print("不允許...")
                    }
                })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func loadDefaultData() {
        //refactor
        if let data = UserDefaults.standard.value(forKey: DefaultConstant.user) as? Data,
            let userInfo = try? JSONDecoder().decode(UserInfo.self, from: data) {
            
            CurrentManager.shared.setCurrentUser(userInfo)
        }

        if let data = UserDefaults.standard.value(forKey: DefaultConstant.group) as? Data,
            let groupInfo = try? JSONDecoder().decode(GroupInfo.self, from: data) {
            
            CurrentManager.shared.setCurrentGroup(groupInfo)
        }
    }
    
    func showExpenseDetail(expenseID: String) {
        
        guard let tabbarVC = window?.rootViewController as? STTabBarController,
            let homeNC = tabbarVC.viewControllers?[0] as? STNavigationController else { return }
            
        FirestoreManager.shared.getExpense(expenseID: expenseID) { result in
            switch result {
                
            case .success(let expense):
                guard let expense = expense,
                    let nextVC = UIStoryboard.home.instantiateViewController(identifier: ExpenseDetailViewController.identifier)
                        as? ExpenseDetailViewController
                else { return }
                
                nextVC.expense = expense
                
                homeNC.pushViewController(nextVC, animated: true)
            case .failure:
                print("ERROR")
            }
        }
    }
    
    func showActivity() {
        
        guard let tabbarVC = window?.rootViewController as? STTabBarController else { return }
        
        tabbarVC.selectedIndex = 3
        
    }
    
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// App 在前景時推播送出時即會觸發的 delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        UIApplication.shared.applicationIconBadgeNumber += 1
        
        if let tabVC = window?.rootViewController as? STTabBarController {
            
            if let badgeValue = tabVC.viewControllers?[3].tabBarItem.badgeValue,
                let count = Int(badgeValue) {
                
                tabVC.viewControllers?[3].tabBarItem.badgeValue = "\(count + 1)"
                
            } else {
                
                tabVC.viewControllers?[3].tabBarItem.badgeValue = "1"
                
            }
            
        }
        
        completionHandler([.alert])//.badge, .sound,
    }
    
    /// 點擊推播訊息時所會觸發的 delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // 印出後台送出的推播訊息(JSON 格式)
        if let expenseID = response.notification.request.content.userInfo["expenseID"] as? String {
            showExpenseDetail(expenseID: expenseID)
        } else {
            showActivity()
        }
    
        completionHandler()
    }

}

extension AppDelegate: MessagingDelegate {
    
    /// iOS10 含以上的版本用來接收 firebase token 的 delegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        // 用來從 firebase 後台推送單一裝置所必須的 firebase token
        print("Firebase registration token: \(fcmToken)")
        
        CurrentManager.shared.fcmToken = fcmToken

    }
    
}
