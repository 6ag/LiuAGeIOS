//
//  AppDelegate.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, JPUSHRegisterDelegate {
    
    var window: UIWindow?
    
    // 给注册推送时用 - 因为注册推送想在主界面加载出来才询问是否授权
    var launchOptions: [AnyHashable: Any]?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupRootViewController() // 配置控制器
        setupGlobalStyle()        // 配置全局样式
        setupGlobalData()         // 配置全局数据
        setupKeyBoardManager()    // 配置键盘管理
        setupShareSDK()           // 配置shareSDK
        self.launchOptions = launchOptions
        return true
    }
    
    /**
     配置全局数据
     */
    fileprivate func setupGlobalData() {
        // 设置初始正文字体大小
        if UserDefaults.standard.integer(forKey: CONTENT_FONT_SIZE_KEY) == 0 || UserDefaults.standard.string(forKey: CONTENT_FONT_TYPE_KEY) == nil {
            // 字体  16小   18中   20大   22超大  24巨大   26极大  共6个等级，可以用枚举列举使用
            UserDefaults.standard.set(18, forKey: CONTENT_FONT_SIZE_KEY)
            UserDefaults.standard.set("", forKey: CONTENT_FONT_TYPE_KEY)
        }
        
        // 验证缓存的账号是否有效
        JFAccountModel.checkUserInfo({})
        
        // 是否需要更新本地搜索关键词列表
        JFNetworkTool.shareNetworkTool.shouldUpdateKeyboardList({ (update) in
            if update {
                JFNewsDALManager.shareManager.updateSearchKeyListData()
            }
        })
    }
    
    /**
     配置shareSDK
     */
    fileprivate func setupShareSDK() {
        
        ShareSDK.registerApp(SHARESDK_APP_KEY, activePlatforms:[
            SSDKPlatformType.typeSinaWeibo.rawValue,
            SSDKPlatformType.typeQQ.rawValue,
            SSDKPlatformType.typeWechat.rawValue],
                             onImport: { (platform : SSDKPlatformType) in
                                switch platform {
                                case SSDKPlatformType.typeWechat:
                                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                                case SSDKPlatformType.typeQQ:
                                    ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                                case SSDKPlatformType.typeSinaWeibo:
                                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                                default:
                                    break
                                }
                                
        }) { (platform : SSDKPlatformType, appInfo : NSMutableDictionary?) in
            
            switch platform {
            case SSDKPlatformType.typeWechat:
                // 微信
                appInfo?.ssdkSetupWeChat(byAppId: WX_APP_ID, appSecret: WX_APP_SECRET)
                
            case SSDKPlatformType.typeQQ:
                // QQ
                appInfo?.ssdkSetupQQ(byAppId: QQ_APP_ID,
                                     appKey : QQ_APP_KEY,
                                     authType : SSDKAuthTypeBoth)
            case SSDKPlatformType.typeSinaWeibo:
                appInfo?.ssdkSetupSinaWeibo(byAppKey: WB_APP_KEY,
                                            appSecret: WB_APP_SECRET,
                                            redirectUri: WB_REDIRECT_URL,
                                            authType: SSDKAuthTypeBoth)
            default:
                break
            }
            
        }
        
    }
    
    /**
     配置键盘管理者
     */
    fileprivate func setupKeyBoardManager() {
        IQKeyboardManager.sharedManager().enable = true
    }
    
    /**
     全局样式
     */
    fileprivate func setupGlobalStyle() {
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        JFProgressHUD.setupHUD() // 配置HUD
    }
    
    /**
     添加根控制器
     */
    fileprivate func setupRootViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let newsVc = UIStoryboard.init(name: "JFNewsViewController", bundle: nil).instantiateInitialViewController()
        
        // 这段代码是为了清除本地用户缓存，因为修改了字段，不清除会崩
        if isNewVersion() {
            //            window?.rootViewController =  JFNewFeatureViewController()
            window?.rootViewController = newsVc
        } else {
            window?.rootViewController = newsVc
        }
        
        window?.makeKeyAndVisible()
        
        // 添加帧数到窗口左下角
        //        window?.addSubview(JFFPSLabel(frame: CGRect(x: SCREEN_WIDTH - 60, y: 26, width: 50, height: 30)))
        
        // 启动图动画
        let launchVc = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!
        launchVc.view.frame = SCREEN_BOUNDS
        window?.addSubview(launchVc.view)
        
        UIView.animate(withDuration: 0.6, delay: 0.5, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            launchVc.view.alpha = 0
            launchVc.view.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        }) { (_) in
            launchVc.view.removeFromSuperview()
        }
    }
    
    /**
     判断是否是新版本
     */
    fileprivate func isNewVersion() -> Bool {
        // 获取当前的版本号
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        // 获取到之前的版本号
        let sandboxVersionKey = "sandboxVersionKey"
        let sandboxVersion = UserDefaults.standard.string(forKey: sandboxVersionKey)
        
        // 保存当前版本号
        UserDefaults.standard.set(currentVersion, forKey: sandboxVersionKey)
        UserDefaults.standard.synchronize()
        
        // 当前版本和沙盒版本不一致就是新版本
        return currentVersion != sandboxVersion
    }
    
    /**
     配置极光推送
     */
    func setupJPush() {
        if #available(iOS 10.0, *){
            let entiity = JPUSHRegisterEntity()
            entiity.types = Int(UNAuthorizationOptions.alert.rawValue |
                UNAuthorizationOptions.badge.rawValue |
                UNAuthorizationOptions.sound.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entiity, delegate: self)
        } else if #available(iOS 8.0, *) {
            let types = UIUserNotificationType.badge.rawValue |
                UIUserNotificationType.sound.rawValue |
                UIUserNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: types, categories: nil)
        } else {
            let type = UIRemoteNotificationType.badge.rawValue |
                UIRemoteNotificationType.sound.rawValue |
                UIRemoteNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: type, categories: nil)
        }
        JPUSHService.setup(withOption: launchOptions, appKey: JPUSH_APP_KEY, channel: JPUSH_CHANNEL, apsForProduction: JPUSH_IS_PRODUCTION)
        JPUSHService.crashLogON()
        
        // 延迟发送通知（app被杀死进程后收到通知，然后通过点击通知打开app在这个方法中发送通知）
        perform(#selector(sendNotification(_:)), with: launchOptions, afterDelay: 1.5)
    }
    
    /**
     如果app是未启动状态，点击了通知。在launchOptions会携带通知数据
     */
    @objc fileprivate func sendNotification(_ launchOptions: [AnyHashable: Any]?) {
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didReceiveRemoteNotificationOfJPush"), object: nil, userInfo: userInfo)
        }
    }
    
    /**
     注册 DeviceToken
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    /**
     注册远程通知失败
     */
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log("did Fail To Register For Remote Notifications With Error: \(error)")
    }
    
    /**
     将要显示
     */
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo = notification.request.content.userInfo
        if let trigger = notification.request.trigger {
            if trigger.isKind(of: UNPushNotificationTrigger.classForCoder()) {
                JPUSHService.handleRemoteNotification(userInfo)
            }
        }
        completionHandler(Int(UNAuthorizationOptions.alert.rawValue))
    }
    
    /**
     已经收到消息
     */
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        if let trigger = response.notification.request.trigger {
            if trigger.isKind(of: UNPushNotificationTrigger.classForCoder()) {
                JPUSHService.handleRemoteNotification(userInfo)
                // 处理远程通知
                remoteNotificationHandler(userInfo: userInfo)
            }
        }
        completionHandler()
    }
    
    /**
     iOS7后接收到远程通知
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        
        // 处理远程通知
        remoteNotificationHandler(userInfo: userInfo)
    }
    
    /// 处理远程通知
    ///
    /// - Parameter userInfo: 通知数据
    private func remoteNotificationHandler(userInfo: [AnyHashable : Any]) {
        
        if UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didReceiveRemoteNotificationOfJPush"), object: nil, userInfo: userInfo)
        } else if UIApplication.shared.applicationState == .active {
            let message = (userInfo as [AnyHashable : AnyObject])["aps"]!["alert"] as! String
            let alertC = UIAlertController(title: "收到新的消息", message: message, preferredStyle: UIAlertControllerStyle.alert)
            let confrimAction = UIAlertAction(title: "查看", style: UIAlertActionStyle.destructive, handler: { (action) in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "didReceiveRemoteNotificationOfJPush"), object: nil, userInfo: userInfo)
            })
            let cancelAction = UIAlertAction(title: "忽略", style: UIAlertActionStyle.default, handler: nil)
            alertC.addAction(confrimAction)
            alertC.addAction(cancelAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertC, animated: true, completion: nil)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        JFNewsDALManager.shareManager.clearCacheData()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
}

