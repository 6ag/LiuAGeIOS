//
//  JFArticleListModel.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/14.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFArticleListModel: NSObject {
    
    /// 文章分类id
    var classid: String?
    
    /// 文章id
    var id: String?
    
    /// 文章标题
    var title: String?
    
    /// 文章来源
    var befrom: String?
    
    /// 点击量
    var onclick: String?
    
    /// 创建文章时间戳
    var newstime: String?
    
    /// 标题图片url
    var titlepic: String?
    
    /// 多图数组
    var morepic: [String]?
    
    /// 缓存行高
    var rowHeight: CGFloat = 0.0
    
    /// 时间戳转换成时间
    var newstimeString: String {
        return newstime!.timeStampToString()
    }
    
    /**
     字典转模型构造方法
     */
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /**
     加载资讯数据
     
     - parameter classid:   资讯分类id
     - parameter pageIndex: 加载分页
     - parameter finished:  数据回调
     */
    class func loadNews(classid: Int, pageIndex: Int, finished: (articleListModels: [JFArticleListModel]?, error: NSError?) -> ()) {
        
        JFNetworkTool.shareNetworkTool.loadNews(classid, pageIndex: pageIndex) { (success, result, error) in
            if success == false || error != nil || result == nil {
                finished(articleListModels: nil, error: error)
                return
            }
            
            let data = result!.arrayValue
            var articleListModels = [JFArticleListModel]()
            
            // 遍历转模型添加数据
            for article in data {
                let postModel = JFArticleListModel(dict: article.dictionaryObject!)
                articleListModels.append(postModel)
            }
            
            finished(articleListModels: articleListModels, error: nil)
        }
    }
    
}