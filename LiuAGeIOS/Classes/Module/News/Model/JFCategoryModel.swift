//
//  JFCategoryModel.swift
//  PCBWorldIOS
//
//  Created by zhoujianfeng on 2017/2/16.
//  Copyright © 2017年 六阿哥. All rights reserved.
//

import UIKit

fileprivate let SELECTED_CATEGORY_LIST_KEY = "selectedArrarKey"
fileprivate let OPTIONAL_CATEGORY_LIST_KEY = "optionalArrayKey"

class JFCategoryModel: NSObject {
    
    /// 分类名
    var classname: String?
    
    /// 分类id
    var classid: String?
    
    /// 分类表名
    var tbname: String?
    
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    typealias CategoryFinished = (_ selectedCategoryList: [JFCategoryModel]?, _ optionalCategoryList: [JFCategoryModel]?) -> ()
    
    /// 加载分类列表
    ///
    /// - Parameters:
    ///   - isCache: 是否加载缓存
    ///   - finished: 完成回调
    class func loadCategoryList(finished: @escaping CategoryFinished) {
        
        loadCategoryListFromCache(finished: { (selectedCategoryList, optionalCategoryList) in
            
            // 如果有本地数据则直接回调
            if let selectedCategoryList = selectedCategoryList,
                let optionalCategoryList = optionalCategoryList {
                finished(selectedCategoryList, optionalCategoryList)
                return
            }
            
            // 没有本地数据则从网络加载
            loadCategoryListFromNetwork(finished: finished)
            
        })
        
    }
    
    /// 从网络加载分类数据
    ///
    /// - Parameter finished: 完成回调
    class func loadCategoryListFromNetwork(finished: @escaping CategoryFinished) {
        
        JFNetworkTool.shareNetworkTool.get(GET_CLASS, parameters: nil) { (success, result, error) in
            
            guard let data = result?["data"].arrayObject as? [[String : AnyObject]] else {
                finished(nil, nil)
                return
            }
            
            var selectedCategoryList = [JFCategoryModel]()
            var optionalCategoryList = [JFCategoryModel]()
            
            // 默认加载一个聚合分类
            selectedCategoryList.append(JFCategoryModel(dict: [
                "classname" : "推荐",
                "classid" : "0",
                "tbname" : "news"
                ]))
            
            for (index, category) in data.enumerated() {
                let category = JFCategoryModel(dict: category)
                if category.tbname == "news" {
                    if index > 5 {
                        optionalCategoryList.append(category)
                    } else {
                        selectedCategoryList.append(category)
                    }
                }
            }
            
            // 回调前先缓存分类数据
            saveCategoryListToCache(selectedCategoryList: selectedCategoryList, optionalCategoryList: optionalCategoryList)
            
            finished(selectedCategoryList, optionalCategoryList)
            
        }
    }
    
    /// 从缓存中加载分类列表
    ///
    /// - Parameter finished: 完成回调
    class func loadCategoryListFromCache(finished: @escaping CategoryFinished) {
        
        guard let selectedArray = UserDefaults.standard.object(forKey: SELECTED_CATEGORY_LIST_KEY) as? [[String : String]],
            let optionalArray = UserDefaults.standard.object(forKey: OPTIONAL_CATEGORY_LIST_KEY) as? [[String : String]] else {
                finished(nil, nil)
                return
        }
        
        log("栏目数据加载缓存成功")
        log("selectedArray = \(selectedArray)")
        log("optionalArray = \(optionalArray)")
        
        var selectedCategoryList = [JFCategoryModel]()
        var optionalCategoryList = [JFCategoryModel]()
        
        for categoryDict in selectedArray {
            let category = JFCategoryModel(dict: categoryDict)
            selectedCategoryList.append(category)
        }
        
        for categoryDict in optionalArray {
            let category = JFCategoryModel(dict: categoryDict)
            optionalCategoryList.append(category)
        }
        
        finished(selectedCategoryList, optionalCategoryList)
        
    }
    
    /// 保存分类集合到缓存
    ///
    /// - Parameters:
    ///   - selectedCategoryList: 已经选择的分类集合
    ///   - optionalCategoryList: 可选的分类集合
    class func saveCategoryListToCache(selectedCategoryList: [JFCategoryModel], optionalCategoryList: [JFCategoryModel]) {
        
        var selectedArray = [[String : String]]()
        var optionalArray = [[String : String]]()
        
        for selectedCategory in selectedCategoryList {
            selectedArray.append([
                "classname" : selectedCategory.classname ?? "",
                "classid" : selectedCategory.classid ?? "",
                "tbname" : selectedCategory.tbname ?? ""
                ])
        }
        
        for optionalCategory in optionalCategoryList {
            optionalArray.append([
                "classname" : optionalCategory.classname ?? "",
                "classid" : optionalCategory.classid ?? "",
                "tbname" : optionalCategory.tbname ?? ""
                ])
        }
        
        UserDefaults.standard.set(selectedArray, forKey: SELECTED_CATEGORY_LIST_KEY)
        UserDefaults.standard.set(optionalArray, forKey: OPTIONAL_CATEGORY_LIST_KEY)
        
        log("栏目数据缓存成功")
        log("selectedArray = \(selectedArray)")
        log("optionalArray = \(optionalArray)")
        
    }
    
    /// 清除本地缓存的栏目数据
    class func cleanCategoryListFromCache() {
        UserDefaults.standard.set(nil, forKey: SELECTED_CATEGORY_LIST_KEY)
        UserDefaults.standard.set(nil, forKey: OPTIONAL_CATEGORY_LIST_KEY)
        UserDefaults.standard.synchronize()
    }
    
}
