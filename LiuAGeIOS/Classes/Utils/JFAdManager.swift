//
//  JFAdArticleListModel.swift
//  PCBWorldIOS
//
//  Created by 周剑峰 on 2017/2/19.
//  Copyright © 2017年 六阿哥. All rights reserved.
//

import UIKit

class JFAdManager: NSObject {
    
    /// 广告模型单例
    static let shared = JFAdManager()
    
    /// 广告分类id
    let classid = "32"
    
    /// 广告软文集合
    var articleList = [JFArticleListModel]()
    
    /// 加载广告软文数据
    ///
    /// - Parameter isCache: 是否加载缓存
    func loadAdList(isCache: Bool) {
        
        // 模型找数据访问层请求数据 - 然后处理数据回调给调用者直接使用
        JFNewsDALManager.shareManager.loadNewsList(classid, pageIndex: 1, type: 1, cache: isCache) { (result, error) in
            
            guard let result = result, result.count >= 0, error == nil else {
                return
            }
            
            let data = result.arrayValue
            var articleList = [JFArticleListModel]()
            
            // 遍历转模型添加数据
            for article in data {
                let postModel = JFArticleListModel(dict: article.dictionaryObject!)
                if postModel.istop == "1" {
                    if let imageUrl = postModel.morepic?.first {
                        // 预下载广告启动图
                        if !XHLaunchAd.checkImageInCache(with: URL(string: imageUrl)!) {
                            XHLaunchAd.downLoadImageAndCache(withURLArray: [URL(string: imageUrl)!])
                        }
                    }
                }
                articleList.append(postModel)
            }
            self.articleList = articleList
        }
        
    }
    
    /// 加载本地启动页广告图 - 同步加载 - 阻塞主线程
    ///
    /// - Parameter finished: 加载回调
    func loadLaunchAd(finished: @escaping (_ isSuccess: Bool, _ articleModel: JFArticleListModel?) -> ()) {
        
        JFNewsDALManager.shareManager.loadNewsListFromLocation(classid) { (isSuccess, result, error) in
            
            guard let result = result, result.count >= 0, error == nil, isSuccess else {
                finished(false, nil)
                return
            }
            
            let data = result.arrayValue
            // 找出都是置顶的文章
            var istopArticleList = [JFArticleListModel]()
            
            // 遍历转模型添加数据
            for article in data {
                let postModel = JFArticleListModel(dict: article.dictionaryObject!)
                if postModel.istop == "1" && postModel.morepic?.count ?? 0 > 0 {
                    istopArticleList.append(postModel)
                }
            }
            
            // 如果有则随机选择一个作为启动广告
            if istopArticleList.count > 0 {
                let randNum = Int(arc4random_uniform(UInt32(istopArticleList.count)))
                finished(true, istopArticleList[randNum])
            } else {
                finished(false, nil)
            }
            
        }
        
    }
    
}
