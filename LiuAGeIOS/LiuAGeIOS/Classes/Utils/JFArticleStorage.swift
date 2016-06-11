//
//  JFArticleStorage.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/8.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage
import CryptoSwift

class JFArticleStorage: NSObject {
    
    /**
     根据key获取文件路径
     
     - parameter key: 存储的key，YYWebImage是用url作为key
     
     - returns: 返回文件的路径
     */
    class func getFilePathForKey(key: String) -> String {
        
        // 文件名是key的md5
        let fileName = key.md5()
        return "\(JFArticleStorage.getArticleImageCache().diskCache.path)/data/\(fileName)"
    }
    
    /**
     获取自定义的文章图片缓存对象
     
     - returns: 返回自定义缓存对象
     */
    class func getArticleImageCache() -> YYImageCache {
        
        // 存储文章图片的目录
        var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
        path?.appendContentsOf("/article.image.cache")
        
        // 返回自定义缓存对象
        return YYImageCache(path: path!)!
    }
    
    
}
