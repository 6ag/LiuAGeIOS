//
//  JFArticleDetailModel.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFArticleDetailModel: NSObject {
    
    /// 文章内容 - 计算型数据，处理newstext
    var newscontent: String {
        guard var text = newstext else {
            return ""
        }
        
        var tempString = text as NSString
        // 匹配 <!--IMG#x-->，换成顺序标签。。麻蛋，接口写出来一直有问题，只能swift来写了
        // 使用正则表达式一定要加try语句
        do {
            // - 1、创建规则
            let pattern = "<!--IMG#x-->"
            // - 2、创建正则表达式对象
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
            // - 3、开始匹配
            let res = regex.matchesInString(text, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, text.characters.count))
            // 输出结果
            for (index, checkingRes) in res.enumerate() {
                tempString = tempString.stringByReplacingCharactersInRange(checkingRes.range, withString: "<!--IMG#\(index)-->")
            }
            text = tempString as String
            newstext = text
        } catch {
            print(error)
        }
        return text
    }
    
    /// 文章标题
    var title: String?
    
    /// 用户名
    var username: String?
    
    /// 最后编辑时间戳
    var newstime: String?
    
    /// 文章内容
    var newstext: String?
    
    /// 文章url
    var titleurl: String?
    
    /// 文章id
    var id: String?
    
    /// 当前子分类id
    var classid: String?
    
    /// 评论数量
    var plnum: String?
    
    /// 是否收藏
    var havefava: String?
    
    /// 文章简介
    var smalltext: String?
    
    /// 标题图片
    var titlepic: String?
    
    /// 所有图片
    var allphoto: [AnyObject]?
    
    /// 赞数量
    var isgood: Int = 0
    
    /// 信息来源 - 如果没有则返回空字符串，所以可以直接强拆
    var befrom: String?
    
    /// 是否赞过
    var isStar = false
    
    /**
     字典转模型构造方法
     */
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
}
