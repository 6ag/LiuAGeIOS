//
//  JFDutyViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFDutyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "关于六阿哥"
        
        view.backgroundColor = UIColor.white
        
        let html = "<!doctype html>" +
        "<head>" +
        "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>" +
        "<style type=\"text/css\">" +
        ".container {background: #FFFFFF;}" +
        ".content {width: 100%;font-size: 16px;}" +
        "p {margin: 0px 0px 5px 0px}" +
        "</style>" +
        "</head>" +
        "<body class=\"container\">" +
        "<div class=\"content\">" +
        "<p>　　《六阿哥》本身是完全免费的，且所有资讯均为原创或网络转载，浏览和使用本软件过程中产生的网络数据流量费用，均由运营商收取。任何问题可以通过如下方式联系到APP作者。</p>" +
        "<p>　　QQ：44334512</p>" +
        "<p>　　联系邮箱：admin@6ag.cn</p>" +
        "<p>　　新浪微博：http://weibo.com/004web</p>" +
        "<p>　　微信订阅号：www6agcn</p>" +
        "</div>" +
        "</body>" +
        "</html>"
        
        let webView = UIWebView(frame: SCREEN_BOUNDS)
        webView.dataDetectorTypes = UIDataDetectorTypes()
        view.addSubview(webView)
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
