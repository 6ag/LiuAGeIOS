//
//  JFCommon.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/1.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

/**
 手机型号枚举
 */
enum iPhoneModel {
    case iPhone4
    case iPhone5
    case iPhone6
    case iPhone6p
    
    /**
     获取当前手机型号
     
     - returns: 返回手机型号枚举
     */
    static func getCurrentModel() -> iPhoneModel {
        switch SCREEN_HEIGHT {
        case 480:
            return .iPhone4
        case 568:
            return .iPhone5
        case 667:
            return .iPhone6
        case 736:
            return .iPhone6p
        default:
            return .iPhone6
        }
    }
}

/**
 是否是夜间模式
 
 - returns: true 是夜间模式
 */
func isNight() -> Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey(NIGHT_KEY)
}

/// 保存夜间模式的状态的key
let NIGHT_KEY = "night"

/// appStore中的应用id
let APPLE_ID = "1120896924"

/// 检查是否登录的key
let IS_LOGIN = "isLogin"

/// 保存正文字体大小的key
let CONTENT_FONT_SIZE = "contentFontSize"

/// 导航栏背景颜色 - （屎黄色）
let NAVIGATIONBAR_COLOR = UIColor(red:0.996,  green:0.816,  blue:0.012, alpha:1)

/// 控制器背景颜色
let BACKGROUND_COLOR = UIColor(red:0.933,  green:0.933,  blue:0.933, alpha:1)

/// 侧栏背景色
let LEFT_BACKGROUND_COLOR = UIColor(red:0.133,  green:0.133,  blue:0.133, alpha:1)

/// 全局边距
let MARGIN: CGFloat = 12

/// 全局圆角
let CORNER_RADIUS: CGFloat = 5

/// 屏幕宽度
let SCREEN_WIDTH = UIScreen.mainScreen().bounds.width

/// 屏幕高度
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.height

/// 屏幕bounds
let SCREEN_BOUNDS = UIScreen.mainScreen().bounds

/// 全局遮罩透明度
let GLOBAL_SHADOW_ALPHA: CGFloat = 0.6

/// shareSDK
let SHARESDK_APP_KEY = "1385076478b60"
let SHARESDK_APP_SECRET = "6bcd79c14fd4379426c89cc54b388625"

/// 微信 - 未修改
let WX_APP_ID = "wx2e1f6f0887148b6c"
let WX_APP_SECRET = "7ad13c3c6dae53e1584c205bf32146f9"

/// QQ
let QQ_APP_ID = "1105449274"
let QQ_APP_KEY = "VXxtcb0KlgFcKXGY"

/// 微博
let WB_APP_KEY = "3574168239"
let WB_APP_SECRET = "3f7cc901506fd3c1c3255a78398ed340"
let WB_REDIRECT_URL = "https://blog.6ag.cn"

/// 极光推送
let JPUSH_APP_KEY = "e34dffa33d4d8e4fc4aaeb61"
let JPUSH_MASTER_SECRET = "622ba4996a5bc0f25b200f70"
let JPUSH_CHANNEL = "Publish channel"
let JPUSH_IS_PRODUCTION = true

        