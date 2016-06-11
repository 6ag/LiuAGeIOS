//
//  JFArticleDetailModel.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFArticleDetailModel: NSObject {
    
    /// 顶贴数
    var top: String?
    
    /// 踩帖数
    var down: String?
    
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
    
    /// 是否收藏 1收藏  0未收藏
    var havefava: String?
    
    /// 文章简介
    var smalltext: String?
    
    /// 标题图片
    var titlepic: String?
    
    /// 所有图片
    var allphoto: [AnyObject]?
    
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
