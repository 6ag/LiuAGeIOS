//
//  JFNewsDALManager.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/12.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import SwiftyJSON

/// DAL: data access layer 数据访问层
class JFNewsDALManager: NSObject {
    
    static let shareManager = JFNewsDALManager()
    
    /// 过期时间间隔 从缓存开始计时，单位秒 7天
    fileprivate let timeInterval: TimeInterval = 86400 * 7
    
    /// 在退出到后台的时候，根据缓存时间自动清除过期的缓存数据
    func clearCacheData() {
        
        // 计算过期时间
        let overDate = Date(timeIntervalSinceNow: -timeInterval)
        log("时间低于 \(overDate) 的都清除")
        
        // 记录时间格式 2016-06-13 02:29:37
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let overString = df.string(from: overDate)
        
        // 生成sql语句
        let sql = "DELETE FROM \(NEWS_LIST_HOME_TOP) WHERE createTime < '\(overString)';" +
            "DELETE FROM \(NEWS_LIST_HOME_LIST) WHERE createTime < '\(overString)';" +
            "DELETE FROM \(NEWS_LIST_OTHER_TOP) WHERE createTime < '\(overString)';" +
            "DELETE FROM \(NEWS_LIST_OTHER_LIST) WHERE createTime < '\(overString)';" +
        "DELETE FROM \(NEWS_CONTENT) WHERE createTime < '\(overString)';"
        
        JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) -> () in
            if db?.executeStatements(sql) == true {
                log("清除缓存数据成功")
            }
        }
    }
}

// MARK: - 搜索关键词数据管理
extension JFNewsDALManager {
    
    /**
     从本地查询搜索关键词列表数据
     
     - parameter keyboard: 关键词
     - parameter finished: 数据回调
     */
    func loadSearchKeyListFromLocation(_ keyboard: String, finished: @escaping (_ success: Bool, _ result: [[String : Any]]?, _ error: NSError?) -> ()) {
        
        // 字符不能少于1个
        if keyboard.characters.count == 0 {
            finished(true, [[String : Any]](), nil)
            return
        }
        
        let sql = "select * from \(SEARCH_KEYBOARD) where keyboard like '%\(keyboard)%' or pinyin like '%\(keyboard)%' order by num desc limit 20"
        
        DispatchQueue.global().async {
            JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) in
                
                do {
                    var array = [[String : Any]]()
                    if let result = try db?.executeQuery(sql, values: nil) {
                        while result.next() == true {
                            let keyboard = result.string(forColumn: "keyboard")
                            let pinyin = result.string(forColumn: "pinyin")
                            let num = result.int(forColumn: "num")
                            
                            let dict: [String : Any] = [
                                "keyboard" : keyboard ?? "",
                                "pinyin" : pinyin ?? "",
                                "num" : Int(num)
                            ]
                            
                            array.append(dict)
                        }
                        DispatchQueue.main.async {
                            finished(true, array, nil)
                        }
                    }
                    
                } catch {
                    log("从本地查询搜索关键词列表数据失败")
                    DispatchQueue.main.async {
                        finished(false, nil, nil)
                    }
                }
                
            }
        }
        
    }
    
    /// 加载本地热门关键词
    ///
    /// - Parameter finished: 数据回调
    func loadSearchKeyListFromLocationOrderByNum(finished: @escaping (_ success: Bool, _ result: [[String : Any]]?, _ error: NSError?) -> ()) {
        
        let sql = "select * from \(SEARCH_KEYBOARD) order by num desc limit 20"
        
        DispatchQueue.global().async {
            JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) in
                
                do {
                    var array = [[String : Any]]()
                    if let result = try db?.executeQuery(sql, values: nil) {
                        while result.next() == true {
                            let keyboard = result.string(forColumn: "keyboard")
                            let pinyin = result.string(forColumn: "pinyin")
                            let num = result.int(forColumn: "num")
                            
                            let dict: [String : Any] = [
                                "keyboard" : keyboard ?? "",
                                "pinyin" : pinyin ?? "",
                                "num" : Int(num)
                            ]
                            
                            array.append(dict)
                        }
                        DispatchQueue.main.async {
                            finished(true, array, nil)
                        }
                    }
                    
                } catch {
                    log("从本地查询搜索关键词列表数据失败")
                    DispatchQueue.main.async {
                        finished(false, nil, nil)
                    }
                }
                
            }
        }
        
    }
    
    /**
     更新本地搜索关键词列表数据到本地 - 这个方法是定期更新的哈
     */
    func updateSearchKeyListData() {
        
        DispatchQueue.global().async {
            JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) in
                
                if db?.executeStatements("DELETE FROM \(SEARCH_KEYBOARD);") == true {
                    log("清空表成功")
                    
                    JFNetworkTool.shareNetworkTool.loadSearchKeyListFromNetwork { (success, result, error) in
                        
                        guard let successResult = result, success == true else {
                            return
                        }
                        
                        if let array = successResult.arrayObject as? [[String : AnyObject]] {
                            
                            DispatchQueue.global().sync {
                                JFSQLiteManager.shareManager.dbQueue.inTransaction { (db, rollback) in
                                    
                                    for dict in array {
                                        // 拼音有可能转换失败
                                        guard let pinyin = dict["pinyin"] as? String else {continue}
                                        let keyboard = dict["keyboard"] as! String
                                        let num = Int(dict["num"] as! String)!
                                        
                                        let sql = "INSERT INTO \(SEARCH_KEYBOARD) (keyboard, pinyin, num) VALUES (?, ?, ?)"
                                        if db?.executeUpdate(sql, withArgumentsIn: [keyboard, pinyin, num]) == true {
                                            log("缓存数据成功 - \(keyboard)")
                                        } else {
                                            log("缓存数据失败 - \(keyboard)")
                                            rollback?.pointee = true
                                            break
                                        }
                                    }
                                    
                                }
                            }
                            
                        }
                        
                    }
                } else {
                    log("清空表失败")
                }
            }
        }
    }
}

// MARK: - 资讯列表数据管理
extension JFNewsDALManager {
    
    /**
     清除资讯列表缓存
     
     - parameter classid: 要清除的分类id
     */
    func cleanCache(_ classid: String) {
        var sql = ""
        if classid == "0" {
            sql = "DELETE FROM \(NEWS_LIST_HOME_TOP); DELETE FROM \(NEWS_LIST_HOME_LIST);"
            // 清理推荐数据的同时重新加载广告数据
            JFAdManager.shared.loadAdList(isCache: false)
        } else {
            sql = "DELETE FROM \(NEWS_LIST_OTHER_TOP) WHERE classid=\(classid); DELETE FROM \(NEWS_LIST_OTHER_LIST) WHERE classid=\(classid);"
        }
        
        DispatchQueue.global().async {
            JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) in
                
                if db?.executeStatements(sql) == true {
                    log("清空表成功 classid = \(classid)")
                } else {
                    log("清空表失败 classid = \(classid)")
                }
            }
        }
    }
    
    /**
     加载资讯列表数据
     
     - parameter classid:   资讯分类id
     - parameter pageIndex: 加载分页
     - parameter type:      1为资讯列表 2为资讯幻灯片
     - parameter cache:     是否需要使用缓存
     - parameter finished:  数据回调
     */
    func loadNewsList(_ classid: String, pageIndex: Int, type: Int, cache: Bool, finished: @escaping (_ result: JSON?, _ error: NSError?) -> ()) {
        
        if cache {
            // 先从本地加载数据
            loadNewsListFromLocation(classid, pageIndex: pageIndex, type: type) { (success, result, error) in
                
                // 本地有数据直接返回
                if success == true {
                    finished(result, nil)
                    log("加载了本地数据 \(result)")
                    return
                }
                
                // 本地没有数据才从网络中加载
                JFNetworkTool.shareNetworkTool.loadNewsListFromNetwork(classid, pageIndex: pageIndex, type: type) { (success, result, error) in
                    
                    guard let result = result, success else {
                        finished(nil, error)
                        return
                    }
                    
                    finished(result, nil)
                    
                    // 缓存数据到本地
                    self.saveNewsListData(classid, data: result, type: type)
                    log("加载了远程数据 \(result)")
                }
            }
        } else {
            JFNetworkTool.shareNetworkTool.loadNewsListFromNetwork(classid, pageIndex: pageIndex, type: type) { (success, result, error) in
                
                guard let result = result, success else {
                    finished(nil, error)
                    return
                }
                
                finished(result, nil)
                
                // 缓存数据到本地
                self.saveNewsListData(classid, data: result, type: type)
                log("加载了远程数据 \(result)")
            }
        }
        
    }
    
    /**
     从本地加载资讯列表数据
     
     - parameter classid:   资讯分类id
     - parameter pageIndex: 加载分页
     - parameter finished:  数据回调
     */
    fileprivate func loadNewsListFromLocation(_ classid: String, pageIndex: Int, type: Int, finished: @escaping NetworkFinished) {
        
        var sql = ""
        if type == 1 {
            // 计算分页
            let pre_count = (pageIndex - 1) * 20
            let oneCount = 20
            
            if classid == "0" {
                sql = "SELECT * FROM \(NEWS_LIST_HOME_LIST) ORDER BY id ASC LIMIT \(pre_count), \(oneCount)"
            } else {
                sql = "SELECT * FROM \(NEWS_LIST_OTHER_LIST) WHERE classid=\(classid) ORDER BY id ASC LIMIT \(pre_count), \(oneCount)"
            }
        } else {
            if classid == "0" {
                sql = "SELECT * FROM \(NEWS_LIST_HOME_TOP) ORDER BY id ASC LIMIT 0, 3"
            } else {
                sql = "SELECT * FROM \(NEWS_LIST_OTHER_TOP) WHERE classid=\(classid) ORDER BY id ASC LIMIT 0, 3"
            }
        }
        
        DispatchQueue.global().async {
            JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) in
                
                do {
                    let result = try db?.executeQuery(sql, values: nil)
                    var array = [JSON]()
                    while result?.next() == true {
                        let newsJson = result?.string(forColumn: "news")
                        let json = JSON.parse(string: newsJson ?? "")
                        array.append(json)
                    }
                    
                    DispatchQueue.main.async {
                        if array.count > 0 {
                            finished(true, JSON(array), nil)
                        } else {
                            finished(false, nil, nil)
                        }
                    }
                } catch {
                    log("从本地加载资讯列表数据失败")
                }
                
            }
        }
        
    }
    
    /**
     从本地加载资讯列表数据
     
     - parameter classid:   资讯分类id
     - parameter pageIndex: 加载分页
     - parameter finished:  数据回调
     */
    public func loadNewsListFromLocation(_ classid: String, finished: @escaping NetworkFinished) {
        
        var sql = ""
        // 计算分页
        let pre_count = (1 - 1) * 20
        let oneCount = 20
        
        if classid == "0" {
            sql = "SELECT * FROM \(NEWS_LIST_HOME_LIST) ORDER BY id ASC LIMIT \(pre_count), \(oneCount)"
        } else {
            sql = "SELECT * FROM \(NEWS_LIST_OTHER_LIST) WHERE classid=\(classid) ORDER BY id ASC LIMIT \(pre_count), \(oneCount)"
        }
        
        JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) in
            
            do {
                let result = try db?.executeQuery(sql, values: nil)
                var array = [JSON]()
                while result?.next() == true {
                    let newsJson = result?.string(forColumn: "news")
                    let json = JSON.parse(string: newsJson ?? "")
                    array.append(json)
                }
                
                if array.count > 0 {
                    finished(true, JSON(array), nil)
                } else {
                    finished(false, nil, nil)
                }
                
            } catch {
                log("从本地加载资讯列表数据失败")
            }
            
        }
        
    }
    
    /**
     缓存资讯列表数据到本地
     
     - parameter data: json数据
     */
    fileprivate func saveNewsListData(_ saveClassid: String, data: JSON, type: Int) {
        
        var sql = ""
        if type == 1 {
            if saveClassid == "0" {
                sql = "INSERT INTO \(NEWS_LIST_HOME_LIST) (classid, news) VALUES (?, ?)"
            } else {
                sql = "INSERT INTO \(NEWS_LIST_OTHER_LIST) (classid, news) VALUES (?, ?)"
            }
        } else {
            if saveClassid == "0" {
                sql = "INSERT INTO \(NEWS_LIST_HOME_TOP) (classid, news) VALUES (?, ?)"
            } else {
                sql = "INSERT INTO \(NEWS_LIST_OTHER_TOP) (classid, news) VALUES (?, ?)"
            }
        }
        
        DispatchQueue.global().async {
            JFSQLiteManager.shareManager.dbQueue.inTransaction { (db, rollback) in
                
                guard let array = data.arrayObject as? [[String : AnyObject]] else {
                    return
                }
                
                do {
                    // 每一个字典是一条资讯
                    for dict in array {
                        
                        // 资讯分类id
                        let classid = dict["classid"] as! String
                        
                        // 单条资讯json数据
                        let newsData = try JSONSerialization.data(withJSONObject: dict, options: [])
                        let newsJson = String(data: newsData, encoding: String.Encoding.utf8) ?? ""
                        
                        if db?.executeUpdate(sql, withArgumentsIn: [classid, newsJson]) == true {
                            log("缓存数据成功 - \(classid)")
                        } else {
                            log("缓存数据失败 - \(classid)")
                            rollback?.pointee = true
                            break
                        }
                    }
                } catch {
                    log("缓存资讯列表数据到本地失败")
                }
                
            }
        }
        
    }
    
}

// MARK: - 资讯正文数据管理
extension JFNewsDALManager {
    
    /// 对文章进行修改后需要移除旧的缓存并重新缓存
    ///
    /// - Parameters:
    ///   - classid: 文章分类id
    ///   - id: 文章id
    func removeNewsDetail(classid: String, id: String) {
        
        DispatchQueue.global().sync {
            let sql = "DELETE FROM \(NEWS_CONTENT) WHERE id = \(id)"
            JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) in
                
                if db?.executeStatements(sql) == true {
                    log("移除旧文章成功 id = \(id)")
                    
                    // 更新本地缓存
                    JFNewsDALManager.shareManager.loadNewsDetail(classid, id: id, cache: false, finished: { (json, error) in
                        guard let _ = json else {
                            log("重新缓存文章失败")
                            return
                        }
                        log("重新缓存文章成功")
                    })
                    
                } else {
                    log("清空表失败 classid = \(classid)")
                }
            }
            
        }
    }
    
    /**
     加载资讯详情数据
     
     - parameter classid:   资讯分类id
     - parameter pageIndex: 加载分页
     - parameter type:      1为资讯列表 2为资讯幻灯片
     - parameter cache:     是否需要使用缓存
     - parameter finished:  数据回调
     */
    func loadNewsDetail(_ classid: String, id: String, cache: Bool, finished: @escaping (_ result: JSON?, _ error: NSError?) -> ()) {
        
        if cache {
            loadNewsDetailFromLocation(classid, id: id) { (success, result, error) in
                
                // 本地有数据直接返回
                if success == true {
                    finished(result, nil)
                    return
                }
                
                JFNetworkTool.shareNetworkTool.loadNewsDetailFromNetwork(classid, id: id, finished: { (success, result, error) in
                    
                    guard let result = result, success else {
                        finished(nil, error)
                        return
                    }
                    
                    finished(result, nil)
                    
                    // 缓存数据到本地
                    self.saveNewsDetailData(classid, id: id, data: result)
                })
                
            }
        } else {
            JFNetworkTool.shareNetworkTool.loadNewsDetailFromNetwork(classid, id: id, finished: { (success, result, error) in
                
                guard let result = result, success else {
                    finished(nil, error)
                    return
                }
                
                finished(result, nil)
                
                // 缓存数据到本地
                self.saveNewsDetailData(classid, id: id, data: result)
                
            })
        }
        
    }
    
    /**
     从本地加载（资讯正文）数据
     
     - parameter classid:  资讯分类id
     - parameter id:       资讯id
     - parameter finished: 数据回调
     */
    fileprivate func loadNewsDetailFromLocation(_ classid: String, id: String, finished: @escaping NetworkFinished) {
        
        let sql = "SELECT * FROM \(NEWS_CONTENT) WHERE id=\(id) AND classid=\(classid) LIMIT 1;"
        
        DispatchQueue.global().async {
            JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) in
                
                let result = try! db?.executeQuery(sql, values: nil)
                while result?.next() == true {
                    let newsJson = result?.string(forColumn: "news")
                    let json = JSON.parse(string: newsJson!)
                    DispatchQueue.main.sync {
                        finished(true, json, nil)
                    }
                    log("从缓存中取正文数据 \(json)")
                    result?.close()
                    return
                }
                DispatchQueue.main.sync {
                    finished(false, nil, nil)
                }
            }
        }
    }
    
    /**
     缓存资讯正文数据到本地
     
     - parameter classid: 资讯分类id
     - parameter id:      资讯id
     - parameter data:    JSON数据 data = [content : ..., otherLink: [...]]
     */
    fileprivate func saveNewsDetailData(_ classid: String, id: String, data: JSON) {
        
        let sql = "INSERT INTO \(NEWS_CONTENT) (id, classid, news) VALUES (?, ?, ?)"
        
        DispatchQueue.global().sync {
            JFSQLiteManager.shareManager.dbQueue.inTransaction { (db, rollback) in
                
                guard let dict = data.dictionaryObject else {
                    return
                }
                
                // 单条资讯json数据
                let newsData = try! JSONSerialization.data(withJSONObject: dict, options: [])
                let newsJson = String(data: newsData, encoding: String.Encoding.utf8) ?? ""
                
                if db?.executeUpdate(sql, withArgumentsIn: [id, classid, newsJson]) == true {
                    log("缓存数据成功 - \(classid)")
                } else {
                    log("缓存数据失败 - \(classid)")
                    rollback?.pointee = true
                }
                
            }
        }
    }
    
}

// MARK: - 评论数据管理
extension JFNewsDALManager {
    
    func loadCommentList(_ classid: String, id: String, pageIndex: Int, pageSize: Int, finished: @escaping (_ result: JSON?, _ error: NSError?) -> ()) {
        
        // 评论不做数据缓存，直接从网络请求
        JFNetworkTool.shareNetworkTool.loadCommentListFromNetwork(classid, id: id, pageIndex: pageIndex, pageSize: pageSize) { (success, result, error) in
            
            if success == false {
                finished(nil, error)
                return
            }
            
            finished(result, nil)
        }
    }
}
