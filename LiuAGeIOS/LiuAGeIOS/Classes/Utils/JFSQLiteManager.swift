//
//  JFSQLiteManager.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/12.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import FMDB

let NEWS_LIST_HOME_TOP = "jf_newslist_hometop"     // 首页 列表页 的 幻灯片 数据表
let NEWS_LIST_HOME_LIST = "jf_newslist_homelist"   // 首页 列表页 的 列表 数据表
let NEWS_LIST_OTHER_TOP = "jf_newslist_othertop"   // 其他分类 列表页 的 幻灯片 数据表
let NEWS_LIST_OTHER_LIST = "jf_newslist_otherlist" // 其他分类 列表页 的 列表 数据表
let NEWS_CONTENT = "jf_news_content"               // 资讯/图库 正文 数据表

class JFSQLiteManager: NSObject {
    
    /// FMDB单例
    static let shareManager = JFSQLiteManager()
    
    /// sqlite数据库名
    private let newsDBName = "news.db"
    
    let dbQueue: FMDatabaseQueue
    
    override init() {
        let documentPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
        let dbPath = "\(documentPath)/\(newsDBName)"
        print(dbPath)
        
        // 根据路径创建并打开数据库，开启一个串行队列
        dbQueue = FMDatabaseQueue(path: dbPath)
        super.init()
        
        // 创建数据表
        createNewsDataTable(NEWS_LIST_HOME_TOP)
        createNewsDataTable(NEWS_LIST_HOME_LIST)
        createNewsDataTable(NEWS_LIST_OTHER_TOP)
        createNewsDataTable(NEWS_LIST_OTHER_LIST)
        createNewsDataTable(NEWS_CONTENT)
    }
    
    /**
     创建资讯数据表 （列表和正文的表结构一样）
     
     - parameter tbname: 表名
     */
    private func createNewsDataTable(tbname: String) {
        
        let sql = "CREATE TABLE IF NOT EXISTS \(tbname) ( \n" +
            "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +                 // 列表是索引 正文是正文id
            "classid INTEGER, \n" +                                               // 分类id
            "news TEXT, \n" +                                                     // 资讯json字符串数据
            "createTime VARCHAR(30) DEFAULT (datetime('now', 'localtime')) \n" +  // 创建时间，用于管理缓存清理
        ");"
        
        dbQueue.inDatabase { (db) in
            if db.executeStatements(sql) {
                print("创建 \(tbname) 表成功")
            } else {
                print("创建 \(tbname) 表失败")
            }
        }
    }
    
}
