//
//  JFCommon.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/1.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import pop
import MJRefresh

/**
 手机型号枚举
 */
enum iPhoneModel {
    
    case iPhone4
    case iPhone5
    case iPhone6
    case iPhone6p
    case iPad
    
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
            return .iPad
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

/**
 是否接收推送
 
 - returns: true 接收
 */
func isPush() -> Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey(PUSH_KEY)
}

/**
 给控件添加弹簧动画
 */
func jf_setupButtonSpringAnimation(view: UIView) {
    let sprintAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
    sprintAnimation.fromValue = NSValue(CGPoint: CGPoint(x: 0.8, y: 0.8))
    sprintAnimation.toValue = NSValue(CGPoint: CGPoint(x: 1, y: 1))
    sprintAnimation.velocity = NSValue(CGPoint: CGPoint(x: 30, y: 30))
    sprintAnimation.springBounciness = 20
    view.pop_addAnimation(sprintAnimation, forKey: "springAnimation")
}

/**
 快速创建上拉加载更多控件
 */
func setupFooterRefresh(target: AnyObject, action: Selector) -> MJRefreshAutoNormalFooter {
    let footerRefresh = MJRefreshAutoNormalFooter(refreshingTarget: target, refreshingAction: action)
    footerRefresh.automaticallyHidden = true
    footerRefresh.setTitle("正在为您加载更多...", forState: MJRefreshState.Refreshing)
    footerRefresh.setTitle("上拉即可加载更多...", forState: MJRefreshState.Idle)
    footerRefresh.setTitle("没有更多数据啦...", forState: MJRefreshState.NoMoreData)
    return footerRefresh
}

/**
 快速创建下拉加载最新控件
 */
func setupHeaderRefresh(target: AnyObject, action: Selector) -> MJRefreshNormalHeader {
    let headerRefresh = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: action)
    headerRefresh.lastUpdatedTimeLabel.hidden = true
    headerRefresh.stateLabel.hidden = true
    return headerRefresh
}

/// 保存夜间模式的状态的key
let NIGHT_KEY = "night"

/// 保存正文字体类型的key
let CONTENT_FONT_TYPE_KEY = "contentFontType"

/// 保存正文字体大小的key
let CONTENT_FONT_SIZE_KEY = "contentFontSize"

/// 推送开关
let PUSH_KEY = "push"

/// 更新搜索关键词列表的key
let UPDATE_SEARCH_KEYBOARD = "updateSearchKeyboard"

/// appStore中的应用id
let APPLE_ID = "1120896924"

/// 导航栏背景颜色 - （屎黄色）
let NAVIGATIONBAR_COLOR = UIColor(red:1,  green:0.792,  blue:0.027, alpha:1)

/// 比导航栏背景色更深一点的颜色
let NAVIGATIONBAR_COLOR_DARK = UIColor(red:0.896,  green:0.716,  blue:0.002, alpha:1)

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
let GLOBAL_SHADOW_ALPHA: CGFloat = 0.5

/// shareSDK
let SHARESDK_APP_KEY = "1385076478b60"
let SHARESDK_APP_SECRET = "6bcd79c14fd4379426c89cc54b388625"

/// 微信
let WX_APP_ID = "wx878f3a6e37859f9e"
let WX_APP_SECRET = "ec45fb9165b542deb40c6737dcd82ddb"

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

        