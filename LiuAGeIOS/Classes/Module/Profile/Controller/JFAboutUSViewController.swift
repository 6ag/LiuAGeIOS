//
//  JFAboutUSViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import SDCycleScrollView
import MJRefresh
import SwiftyJSON

class JFAboutUSViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - 懒加载
    fileprivate lazy var webView: UIWebView = {
        let webView = UIWebView()
        webView.delegate = self
        return webView
    }()
    
    /// 活动指示器 - 页面正在加载时显示
    fileprivate lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityView.hidesWhenStopped = true
        return activityView
    }()
    
}

extension JFAboutUSViewController {
    
    /// 准备UI
    fileprivate func prepareUI() {
        
        title = "关于我们"
        view.backgroundColor = BACKGROUND_COLOR
        view.addSubview(webView)
        view.addSubview(activityView)
        
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        activityView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(100)
        }
        
        activityView.startAnimating()
        let html = try! String(contentsOfFile: Bundle.main.path(forResource: "www/html/aboutus.html", ofType: nil)!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html, baseURL: nil)
        
    }
    
}

extension JFAboutUSViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if !webView.isLoading {
            activityView.stopAnimating()
        }
    }
}
