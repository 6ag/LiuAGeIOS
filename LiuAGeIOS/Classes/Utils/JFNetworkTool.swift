//
//  JFNetworkTool.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

/// 网络请求回调闭包 success:是否成功是指逻辑成功，比如登录成功，并不是网络请求成功 result:JSON数据 error:网络请求失败后的错误信息
typealias NetworkFinished = (_ success: Bool, _ result: JSON?, _ error: NSError?) -> ()

class JFNetworkTool: NSObject {
    
    /// 网络工具类单例
    static let shareNetworkTool = JFNetworkTool()
}

// MARK: - 基础请求方法
extension JFNetworkTool {
    
    /// get请求 - 基本请求，需要自己判断逻辑是否成功
    ///
    /// - Parameters:
    ///   - urlString: urlString
    ///   - params: 参数
    ///   - success: 成功回调
    ///   - failure: 失败回调
    func get(_ urlString: String, params: [String : Any], success: @escaping (_ response: JSON) -> (), failure: @escaping (_ error : Error) -> ()) {
        log("urlString = \(urlString)")
        Alamofire.request(urlString, method: .get, parameters: params, headers: nil)
            .responseJSON { [weak self] (response) in
                self?.handle(response: response, success: success, failure: failure)
        }
    }
    
    /// post请求 - 基本请求，需要自己判断逻辑是否成功
    ///
    /// - Parameters:
    ///   - urlString: urlString
    ///   - params: 参数
    ///   - success: 成功回调
    ///   - failure: 失败回调
    func post(_ urlString: String, params: [String : Any], success: @escaping (_ response: JSON) -> (), failure: @escaping (_ error : Error) -> ()) {
        log("urlString = \(urlString)")
        Alamofire.request(urlString, method: .post, parameters: params, headers: nil)
            .responseJSON { [weak self] (response) in
                self?.handle(response: response, success: success, failure: failure)
        }
    }
    
    /// 处理请求
    ///
    /// - Parameters:
    ///   - response: 响应对象
    ///   - success: 成功回调
    ///   - failure: 失败回调
    fileprivate func handle(response: DataResponse<Any>, success: @escaping (_ response: JSON) -> (), failure: @escaping (_ error : Error) -> ()) {
        switch response.result {
        case .success(let value):
            success(JSON(value))
        case .failure(let error):
            failure(error)
        }
    }
    
    /**
     GET请求 - 封装了请求逻辑成功
     
     - parameter urlString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func get(_ urlString: String, parameters: [String : Any]?, finished: @escaping NetworkFinished) {
        log("urlString = \(urlString)")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(urlString, method: .get, parameters: parameters, headers: nil).responseJSON { (response) in
            self.handle(response: response, finished: finished)
        }
        
    }
    
    /**
     POST请求 - 封装了请求逻辑成功
     
     - parameter urlString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func post(_ urlString: String, parameters: [String : Any]?, finished: @escaping NetworkFinished) {
        log("urlString = \(urlString)")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(urlString, method: .post, parameters: parameters, headers: nil).responseJSON { (response) in
            self.handle(response: response, finished: finished)
        }
    }
    
    /// 处理响应结果
    ///
    /// - Parameters:
    ///   - response: 响应对象
    ///   - finished: 完成回调
    fileprivate func handle(response: DataResponse<Any>, finished: @escaping NetworkFinished) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        switch response.result {
        case .success(let value):
            log(value)
            let json = JSON(value)
            if json["err_msg"].string == "success" {
                finished(true, json, nil)
            } else {
                finished(false, json, nil)
            }
        case .failure(let error):
            finished(false, nil, error as NSError?)
        }
        
    }
    
}

// MARK: - 各种网络请求
extension JFNetworkTool {
    
    /**
     上传用户头像
     
     - parameter urlString:  api接口
     - parameter image:      图片对象
     - parameter parameters: 绑定参数
     - parameter finished:   完成回调
     */
    func uploadUserAvatar(_ urlString: String, imagePath: URL, parameters: [String : Any]?, finished: @escaping NetworkFinished) {
        
        log("urlString=\(urlString)")
        
        let headers = ["content-type" : "multipart/form-data"]
        // 字符串转data型
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in parameters! {
                if let data = (value as AnyObject).data?(using: String.Encoding.utf8.rawValue) {
                    multipartFormData.append(data, withName: key)
                }
            }
            
            // 文件流方式上传图片 - 后端根据tempName进行操作上传文件
            multipartFormData.append(imagePath, withName: "file")
        },
                         to: urlString,
                         headers: headers,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    if let data = response.data {
                                        let json = JSON(data: data)
                                        finished(true, json, nil)
                                    } else {
                                        finished(false, nil, response.result.error as NSError?)
                                    }
                                }
                            case .failure(let encodingError):
                                finished(false, nil, encodingError as NSError?)
                            }
        })
        
    }
    
    /**
     获取更新搜索关键词列表的开关
     
     - parameter finished: 数据回调
     */
    func shouldUpdateKeyboardList(_ finished: @escaping (_ update: Bool) -> ()) {
        
        JFNetworkTool.shareNetworkTool.get(UPDATE_SEARCH_KEY_LIST, parameters: nil) { (success, result, error) in
            guard let result = result, success == true else {
                finished(false)
                return
            }
            
            let updateNum = result["data"].intValue
            if UserDefaults.standard.integer(forKey: UPDATE_SEARCH_KEYBOARD) == updateNum {
                finished(false)
            } else {
                UserDefaults.standard.set(updateNum, forKey: UPDATE_SEARCH_KEYBOARD)
                finished(true)
            }
            
        }
    }
    
    /**
     从网络加载（搜索关键词列表）数据
     
     - parameter finished: 数据回调
     */
    func loadSearchKeyListFromNetwork(_ finished: @escaping NetworkFinished) {
        
        JFNetworkTool.shareNetworkTool.get(SEARCH_KEY_LIST, parameters: nil) { (success, result, error) in
            guard let result = result, success == true else {
                finished(false, nil, error)
                return
            }
            
            finished(true, result["data"], nil)
        }
    }
    
    /**
     从网络加载（搜索结果）列表
     
     - parameter keyboard:  搜索关键词
     - parameter pageIndex: 加载分页
     - parameter finished:  数据回调
     */
    func loadSearchResultFromNetwork(_ keyboard: String, pageIndex: Int, finished: @escaping NetworkFinished) {
        
        let parameters: [String : Any] = [
            "keyboard" : keyboard,   // 搜索关键字
            "pageIndex" : pageIndex, // 页码
            "pageSize" : 20          // 单页数量
        ]
        
        JFNetworkTool.shareNetworkTool.get(SEARCH, parameters: parameters) { (success, result, error) -> () in
            
            guard let result = result, success == true else {
                finished(false, nil, error)
                return
            }
            
            finished(true, result["data"], nil)
        }
    }
    
    /**
     从网络加载（资讯列表）数据
     
     - parameter classid:   资讯分类id
     - parameter pageIndex: 加载分页
     - parameter type:      1为资讯列表 2为资讯幻灯片
     - parameter finished:  数据回调
     */
    func loadNewsListFromNetwork(_ classid: Int, pageIndex: Int, type: Int, finished: @escaping NetworkFinished) {
        
        var parameters = [String : Any]()
        
        if type == 1 {
            parameters = [
                "classid" : classid,
                "pageIndex" : pageIndex, // 页码
                "pageSize" : 20          // 单页数量
            ]
        } else {
            parameters = [
                "classid" : classid,
                "query" : "isgood",
                "pageSize" : 3
            ]
        }
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_LIST, parameters: parameters) { (success, result, error) -> () in
            
            guard let result = result, success == true else {
                finished(false, nil, error)
                return
            }
            
            finished(true, result["data"], nil)
        }
    }
    
    /**
     从网络加载（资讯正文）数据
     
     - parameter classid:  资讯分类id
     - parameter id:       资讯id
     - parameter finished: 数据回调
     */
    func loadNewsDetailFromNetwork(_ classid: Int, id: Int, finished: @escaping NetworkFinished) {
        
        var parameters = [String : Any]()
        if JFAccountModel.isLogin() {
            parameters = [
                "classid" : classid,
                "id" : id,
                "username" : JFAccountModel.shareAccount()!.username!,
                "userid" : JFAccountModel.shareAccount()!.id,
                "token" : JFAccountModel.shareAccount()!.token!,
            ]
        } else {
            parameters = [
                "classid" : classid,
                "id" : id,
            ]
        }
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_DETAIL, parameters: parameters) { (success, result, error) -> () in
            
            guard let result = result, success == true else {
                finished(false, nil, error)
                return
            }
            
            finished(true, result["data"], nil)
        }
    }
    
    /**
     从网络加载（评论列表）数据
     
     - parameter classid:   资讯分类id
     - parameter id:        资讯id
     - parameter pageIndex: 当前页
     - parameter pageSize:  每页条数
     - parameter finished:  数据回调
     */
    func loadCommentListFromNetwork(_ classid: Int, id: Int, pageIndex: Int, pageSize: Int, finished: @escaping NetworkFinished) {
        
        let parameters: [String : Any] = [
            "classid" : classid,
            "id" : id,
            "pageIndex" : pageIndex,
            "pageSize" : pageSize
        ]
        
        JFNetworkTool.shareNetworkTool.get(GET_COMMENT, parameters: parameters) { (success, result, error) -> () in
            
            guard let result = result, success == true else {
                finished(false, nil, error)
                return
            }
            
            finished(true, result["data"], nil)
        }
    }
    
}
