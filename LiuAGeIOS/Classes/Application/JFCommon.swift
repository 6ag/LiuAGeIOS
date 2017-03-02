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

// MARK: - 各种全局方法
/// 打印日志封装 - 打包的时候注释掉
///
/// - Parameter string: 需要打印的字符串
func log(_ string: Any?) {
    print(string ?? "")
}

/// 基于iPhone6垂直方向适配
///
/// - Parameter size: iPhone6垂直方向尺寸
/// - Returns: 其他型号尺寸
func layoutVertical(iPhone6: CGFloat) -> CGFloat {
    
    var newHeight: CGFloat = 0
    
    switch iPhoneModel.getCurrentModel() {
    case .iPhone5:
        newHeight = iPhone6 * (568.0 / 667.0)
    case .iPhone6:
        newHeight = iPhone6
    case .iPhone6p:
        newHeight = iPhone6 * (736.0 / 667.0)
    default:
        newHeight = iPhone6 * (1024.0 / 667.0 * 0.9)
    }
    
    return newHeight
    
}

/// 基于iPhone6水平方向适配
///
/// - Parameter iPhone6: iPhone6水平方向尺寸
/// - Returns: 其他型号尺寸
func layoutHorizontal(iPhone6: CGFloat) -> CGFloat {
    
    var newWidth: CGFloat = 0
    
    switch iPhoneModel.getCurrentModel() {
    case .iPhone5:
        newWidth = iPhone6 * (320.0 / 375.0)
    case .iPhone6:
        newWidth = iPhone6
    case .iPhone6p:
        newWidth = iPhone6 * (414.0 / 375.0)
    default:
        newWidth = iPhone6 * (768.0 / 375.0 * 0.9)
    }
    
    return newWidth
    
}

/// 基于iPhone6字体的屏幕适配
///
/// - Parameter iPhone6: iPhone字体大小
/// - Returns: 其他型号字体
func layoutFont(iPhone6: CGFloat) -> CGFloat {
    
    var newFont: CGFloat = 0
    
    switch iPhoneModel.getCurrentModel() {
    case .iPhone5:
        newFont = iPhone6 * (320.0 / 375.0)
    case .iPhone6:
        newFont = iPhone6
    case .iPhone6p:
        newFont = iPhone6 * (414.0 / 375.0)
    default:
        newFont = iPhone6 * 1.2
    }
    
    return newFont
}

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
    return UserDefaults.standard.bool(forKey: NIGHT_KEY)
}

/**
 是否接收推送
 
 - returns: true 接收
 */
func isPush() -> Bool {
    return UserDefaults.standard.bool(forKey: PUSH_KEY)
}

/**
 给控件添加弹簧动画
 */
func jf_setupButtonSpringAnimation(_ view: UIView) {
    let sprintAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
    sprintAnimation?.fromValue = NSValue(cgPoint: CGPoint(x: 0.8, y: 0.8))
    sprintAnimation?.toValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
    sprintAnimation?.velocity = NSValue(cgPoint: CGPoint(x: 30, y: 30))
    sprintAnimation?.springBounciness = 20
    view.pop_add(sprintAnimation, forKey: "springAnimation")
}

/**
 快速创建上拉加载更多控件
 */
func setupFooterRefresh(_ target: AnyObject, action: Selector) -> MJRefreshAutoNormalFooter {
    let footerRefresh = MJRefreshAutoNormalFooter(refreshingTarget: target, refreshingAction: action)
    footerRefresh?.isAutomaticallyHidden = true
    footerRefresh?.setTitle("正在为您加载更多...", for: MJRefreshState.refreshing)
    footerRefresh?.setTitle("上拉即可加载更多...", for: MJRefreshState.idle)
    footerRefresh?.setTitle("没有更多数据啦...", for: MJRefreshState.noMoreData)
    return footerRefresh!
}

/**
 快速创建下拉加载最新控件
 */
func setupHeaderRefresh(_ target: AnyObject, action: Selector) -> MJRefreshNormalHeader {
    let headerRefresh = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: action)
    headerRefresh?.lastUpdatedTimeLabel.isHidden = true
    headerRefresh?.stateLabel.isHidden = true
    return headerRefresh!
}

/// 跳转到详情控制器
///
/// - Parameters:
///   - nav: 所在导航控制器
///   - articleModel: 文章列表模型
func jumpToDetailVc(nav: UINavigationController, articleModel: JFArticleListModel) {
    if articleModel.classid == JFAdManager.shared.classid && articleModel.isurl == "1" {
        let adWebViewVc = JFAdWebViewController()
        adWebViewVc.webParam = (articleModel.title!, articleModel.titleurl!, articleModel.titlepic)
        nav.pushViewController(adWebViewVc, animated: true)
    } else if articleModel.morepic?.count ?? 0 > 3 {
        let photoDetailVc = JFPhotoDetailViewController()
        photoDetailVc.photoParam = (articleModel.classid!, articleModel.id!)
        nav.pushViewController(photoDetailVc, animated: true)
    } else {
        let articleDetailVc = JFNewsDetailViewController()
        articleDetailVc.articleParam = (articleModel.classid!, articleModel.id!)
        nav.pushViewController(articleDetailVc, animated: true)
    }
}


// MARK: - 各种全局常量
/// 夜间模式的状态
let NIGHT_KEY = "night"
/// 正文字体名称
let CONTENT_FONT_TYPE_KEY = "contentFontType"
/// 正文字体大小
let CONTENT_FONT_SIZE_KEY = "contentFontSize"
/// 推送开关
let PUSH_KEY = "push"
/// 更新搜索关键词列表
let UPDATE_SEARCH_KEYBOARD = "updateSearchKeyboard"


/// 主色调 - 白色
let PRIMARY_COLOR = UIColor.white
/// 强调色，比如顶部标签选择颜色 - 橙色
let ACCENT_COLOR = UIColor.colorWithRGB(231, g: 129, b: 112)
/// 按钮禁用时的颜色 - 灰色
let DISENABLED_BUTTON_COLOR = UIColor.colorWithRGB(178, g: 178, b: 178)
/// 控制器背景颜色 - 接近白色
let BACKGROUND_COLOR = UIColor.colorWithHexString("#ECECF2") //UIColor.colorWithRGB(252, g: 252, b: 252)
/// 侧栏背景色 - 浅黑色
let LEFT_BACKGROUND_COLOR = UIColor(red:0.133,  green:0.133,  blue:0.133, alpha:1)
/// 设置界面分割线颜色
let SETTING_SEPARATOR_COLOR = UIColor(white: 0.5, alpha: 0.3)


/// 全局边距
let MARGIN: CGFloat = 12
/// 全局圆角
let CORNER_RADIUS: CGFloat = 5
/// 屏幕宽度
let SCREEN_WIDTH = UIScreen.main.bounds.width
/// 屏幕高度
let SCREEN_HEIGHT = UIScreen.main.bounds.height
/// 屏幕bounds
let SCREEN_BOUNDS = UIScreen.main.bounds
/// 全局遮罩透明度
let GLOBAL_SHADOW_ALPHA: CGFloat = 0.5


/// appStore中的应用id
let APPSTORE_ID = "1120896924"

/// 极光推送
let JPUSH_APP_KEY = "e34dffa33d4d8e4fc4aaeb61"
let JPUSH_MASTER_SECRET = "622ba4996a5bc0f25b200f70"
let JPUSH_CHANNEL = "Publish channel"
let JPUSH_IS_PRODUCTION = true

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

