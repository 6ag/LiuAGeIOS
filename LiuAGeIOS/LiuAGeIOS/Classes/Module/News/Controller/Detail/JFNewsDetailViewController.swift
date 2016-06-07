//
//  JFNewsDetailViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage
import MJRefresh
import Mustache
import CryptoSwift

class JFNewsDetailViewController: UIViewController {
    
    var bridge: WebViewJavascriptBridge?
    
    // MARK: - 属性
    var contentOffsetY: CGFloat = 0.0
    
    /// 文章详情请求参数
    var articleParam: (classid: String, id: String)?
    
    /// 详情页面模型
    var model: JFArticleDetailModel? {
        didSet {
            if isLoaded {
                // 获取当前显示的整个html代码
                let html = webView.stringByEvaluatingJavaScriptFromString("getHtml();")!
                let templatePath = NSBundle.mainBundle().pathForResource("article", ofType: "html")!
                let baseURL = NSURL(fileURLWithPath: templatePath as String)
                webView.loadHTMLString(html, baseURL: baseURL)
            } else {
                // 没有加载过，才去初始化webView - 保证只加载一次
                loadWebViewContent(model!)
            }
            
            // 更新收藏状态
            bottomBarView.collectionButton.selected = model!.havefava == "1"
        }
    }
    
    /// 分享的图片url
    var sharePicUrl: String = ""
    
    /// 是否已经加载过webView
    var isLoaded = false
    
    /// 相关连接模型
    var otherLinks = [JFOtherLinkModel]()
    
    /// 评论模型
    var commentList = [JFCommentModel]()
    
    let detailContentIdentifier = "detailContentIdentifier"
    let detailStarAndShareIdentifier = "detailStarAndShareIdentifier"
    let detailOtherLinkIdentifier = "detailOtherLinkIdentifier"
    let detailCommentIdentifier = "detailCommentIdentifier"
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebViewJavascriptBridge()
        prepareUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        navigationController?.setNavigationBarHidden(true, animated: true)
        updateData()
    }
    
    deinit {
        print("文章详情释放了")
    }
    
    /**
     配置WebViewJavascriptBridge
     */
    private func setupWebViewJavascriptBridge() {
        
        bridge = WebViewJavascriptBridge(forWebView: webView, webViewDelegate: self, handler: { (data, responseCallback) in
            responseCallback("Response for message from ObjC")
            
            // 接收js发送过来的点击事件
            let newsPhotoBrowserVc = JFNewsPhotoBrowserViewController()
            newsPhotoBrowserVc.photoParam = (self.model!.allphoto!, Int(data as! NSNumber))
            self.presentViewController(newsPhotoBrowserVc, animated: true, completion: {})
        })
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        // 注册cell
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: detailContentIdentifier)
        tableView.registerNib(UINib(nibName: "JFStarAndShareCell", bundle: nil), forCellReuseIdentifier: detailStarAndShareIdentifier)
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: detailOtherLinkIdentifier)
        tableView.registerNib(UINib(nibName: "JFCommentCell", bundle: nil), forCellReuseIdentifier: detailCommentIdentifier)
        tableView.tableHeaderView = webView
        
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
        view.addSubview(topBarView)
        view.addSubview(bottomBarView)
        view.addSubview(activityView)
        
        topBarView.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(0)
            make.height.equalTo(20)
        }
        bottomBarView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(45)
        }
    }
    
    @objc private func updateData() {
        // 请求页面数据
        loadNewsDetail(articleParam!.classid, id: articleParam!.id)
        loadCommentList(articleParam!.classid, id: articleParam!.id)
    }
    
    // MARK: - 底部条操作
    // 开始拖拽视图
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        contentOffsetY = scrollView.contentOffset.y
    }
    
    /**
     手指滑动屏幕开始滚动
     */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (scrollView.dragging) {
            if scrollView.contentOffset.y - contentOffsetY > 5.0 {
                // 向上拖拽 隐藏
                bottomBarView.snp_updateConstraints(closure: { (make) in
                    make.bottom.equalTo(44)
                })
                UIView.animateWithDuration(0.25, animations: {
                    self.view.layoutIfNeeded()
                })
            } else if contentOffsetY - scrollView.contentOffset.y > 5.0 {
                // 向下拖拽 显示
                bottomBarView.snp_updateConstraints(closure: { (make) in
                    make.bottom.equalTo(0)
                })
                UIView.animateWithDuration(0.25, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            
        }
    }
    
    /**
     滚动减速结束
     */
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        // 滚动到底部后 显示
        if case let space = scrollView.contentOffset.y + SCREEN_HEIGHT - scrollView.contentSize.height where space > -5 && space < 5 {
            bottomBarView.snp_updateConstraints(closure: { (make) in
                make.bottom.equalTo(0)
            })
            UIView.animateWithDuration(0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    /**
     点击更多评论
     */
    func didTappedmoreCommentButton(button: UIButton) -> Void {
        let commentVc = JFCommentTableViewController(style: UITableViewStyle.Plain)
        commentVc.param = articleParam
        navigationController?.pushViewController(commentVc, animated: true)
    }
    
    // MARK: - 各种数据请求
    /**
     加载详情
     
     - parameter classid: 当前子分类id
     - parameter id:      文章id
     */
    func loadNewsDetail(classid: String, id: String) {
        
        var parameters = [String : AnyObject]()
        
        if JFAccountModel.isLogin() {
            parameters = [
                "table" : "news",
                "classid" : classid,
                "id" : id,
                "username" : JFAccountModel.shareAccount()!.username!,
                "userid" : JFAccountModel.shareAccount()!.id,
                "token" : JFAccountModel.shareAccount()!.token!,
            ]
        } else {
            parameters = [
                "table" : "news",
                "classid" : classid,
                "id" : id,
            ]
        }
        
        activityView.startAnimating()
        JFNetworkTool.shareNetworkTool.get(ARTICLE_DETAIL, parameters: parameters) { (success, result, error) -> () in
            
            guard let successResult = result where success == true else {return}
            
            print(successResult)
            // 相关连接
            self.otherLinks.removeAll()
            let otherLinks = successResult["data"]["otherLink"].array
            if let others = otherLinks {
                for other in others {
                    let dict = [
                        "id" : other["id"].stringValue,
                        "classid" : other["classid"].stringValue,
                        "title" : other["title"].stringValue
                    ]
                    
                    let otherModel = JFOtherLinkModel(dict: dict)
                    self.otherLinks.append(otherModel)
                }
            }
            
            // 正文数据
            let content = successResult["data"]["content"].dictionaryValue
            let dict: [String : AnyObject] = [
                "title" : content["title"]!.stringValue,          // 文章标题
                "newstime" : content["newstime"]!.stringValue,    // 时间戳
                "newstext" : content["newstext"]!.stringValue,    // 文章内容
                "titleurl" : content["titleurl"]!.stringValue,    // 文章url
                "id" : content["id"]!.stringValue,                // 文章id
                "classid" : content["classid"]!.stringValue,      // 当前子分类id
                "plnum" : content["plnum"]!.stringValue,          // 评论数
                "havefava" : content["havefava"]!.stringValue,    // 是否收藏  1 0
                "smalltext" : content["smalltext"]!.stringValue,  // 文章简介
                "titlepic" : content["titlepic"]!.stringValue,    // 标题图片
                "befrom" : content["befrom"]!.stringValue,        // 文章来源
                "allphoto" : content["allphoto"]!.arrayObject!    // 所有文章图片
            ]
            
            self.model = JFArticleDetailModel(dict: dict)
            self.tableView.reloadData()
        }
    }
    
    
    /**
     加载评论
     */
    func loadCommentList(classid: String, id: String) {
        let parameters = [
            "classid" : classid,
            "id" : id,
            "pageIndex" : 1
        ]
        
        JFNetworkTool.shareNetworkTool.get(GET_COMMENT, parameters: parameters as? [String : AnyObject]) { (success, result, error) -> () in
            
            guard let successResult = result where success == true else {return}
            
            let data = successResult["data"].arrayValue
            if data.count == 0 && self.commentList.count == 0 {
                return
            }
            
            self.commentList.removeAll()
            for comment in data.reverse() {
                let dict = [
                    "plstep" : comment["plstep"].intValue,
                    "plid" : comment["plid"].intValue,
                    "plusername" : comment["plusername"].stringValue,
                    "id" : comment["id"].intValue,
                    "classid" : comment["classid"].intValue,
                    "saytext" : comment["saytext"].stringValue,
                    "saytime" : comment["saytime"].stringValue,
                    "userpic" : "\(BASE_URL)\(comment["userpic"].stringValue)",
                    "zcnum" : comment["zcnum"].stringValue
                ]
                
                let commentModel = JFCommentModel(dict: dict as! [String : AnyObject])
                self.commentList.append(commentModel)
            }
            
            self.tableView.reloadData()
        }
    }
    
    /**
     加载webView内容
     
     - parameter model: 新闻模型
     */
    func loadWebViewContent(model: JFArticleDetailModel) {
        
        // 如果不熟悉网页，可以换成GRMutache模板更配哦
        var html = ""
        let css = "<style type=\"text/css\">" +
            "@font-face {" + // 字体
            "font-family: '汉仪旗黑';" +
            "src: url('\(NSBundle.mainBundle().pathForResource("HYQiHei-50J", ofType: "ttf")!)');" +
            "}" +
            "*{ padding:0px; margin:0px;}" +
            ".container {" + // 正文主体（包括标题、时间、来源）
            "width: 96%;" +
            "margin-left: 2%;" +
            "margin-top: 5px" +
            "}" +
            ".title {" + // 标题
            "text-align: left;" +
            "font-size: 20px;" +
            "color: #3c3c3c;" +
            "font-weight: bold;" +
            "font-family: '汉仪旗黑'" +
            "margin-top: 5px;" +
            "}" +
            ".time {" + // 来源、时间
            "text-align: left;" +
            "font-size: 13px;" +
            "color: #BDBDBD;" +
            "margin-top: 5px;" +
            "margin-bottom: 10px" +
            "}" +
            ".content {" + // 文章内容
            "font-size: \(NSUserDefaults.standardUserDefaults().integerForKey(CONTENT_FONT_SIZE))px;" +
            "font-family: '汉仪旗黑'" +
            "}" +
            ".content p {" +
            "margin: 0px 0px 15px 0px;" + // 上右下左
            "}" +
            ".content img {" +
            "display: block;" +
            "margin: 20px auto;" +
            "}" +
        "</style>"
        
        html.appendContentsOf(css)
        html.appendContentsOf("<div class=\"container\">")
        html.appendContentsOf("<div class=\"title\">\(model.title!)</div>")
        html.appendContentsOf("<div class=\"time\">\(model.befrom!)&nbsp;&nbsp;&nbsp;&nbsp;\(model.newstime!.timeStampToString())</div>")
        
        // 临时正文 - 这样做的目的是不修改模型
        var tempNewstext = model.newscontent
        
        // 有图片才去拼接图片
        if model.allphoto!.count > 0 {
            
            // 拼接图片标签
            for (index, dict) in model.allphoto!.enumerate() {
                // 图片占位符范围
                let range = (tempNewstext as NSString).rangeOfString(dict["ref"] as! String)
                
                // 默认宽、高为0
                var width: CGFloat = 0
                var height: CGFloat = 0
                if let w = dict["pixel"]!!["width"] as? NSNumber {
                    width = CGFloat(w.floatValue)
                }
                if let h = dict["pixel"]!!["height"] as? NSNumber  {
                    height = CGFloat(h.floatValue)
                }
                
                // 如果图片超过了最大宽度，才等比压缩
                if width >= SCREEN_WIDTH - 15  {
                    let rate = (SCREEN_WIDTH - 15) / width
                    width = width * rate
                    height = height * rate
                }
                
                // 加载中的占位图
                let loading = NSBundle.mainBundle().pathForResource("loading", ofType: "png")
                
                // img标签
                let imgTag = "<p><img onclick='didTappedImage(\(index));' src='\(loading!)' id='\(dict["url"] as! String)' width='\(width)' height='\(height)' /></p>"
                tempNewstext = (tempNewstext as NSString).stringByReplacingOccurrencesOfString(dict["ref"] as! String, withString: imgTag, options: NSStringCompareOptions.CaseInsensitiveSearch, range: range)
            }
            
            // 加载图片 - 从缓存中获取图片的本地绝对路径，发送给webView显示
            getImageFromDownloaderOrDiskByImageUrlArray(model.allphoto!)
        }
        
        html.appendContentsOf("<div class=\"content\">\(tempNewstext)</div>")
        html.appendContentsOf("</div>")
        
        // 从本地加载网页模板，替换新闻主页
        let templatePath = NSBundle.mainBundle().pathForResource("article", ofType: "html")!
        let template = (try! String(contentsOfFile: templatePath, encoding: NSUTF8StringEncoding)) as NSString
        html = template.stringByReplacingOccurrencesOfString("<p>mainnews</p>", withString: html, options: NSStringCompareOptions.CaseInsensitiveSearch, range: template.rangeOfString("<p>mainnews</p>"))
        let baseURL = NSURL(fileURLWithPath: templatePath as String)
        webView.loadHTMLString(html, baseURL: baseURL)
        
        // 已经加载过就修改标记
        isLoaded = true
    }
    
    /**
     下载或从缓存中获取图片，发送给webView
     */
    func getImageFromDownloaderOrDiskByImageUrlArray(imageArray: [AnyObject]) {
        
        // 循环加载图片
        for dict in imageArray {
            
            let imageString = dict["url"] as! String
            
            // 存储文章图片的目录 - 这些代码可以封装起来。提供方法快速创建自定义的imageCache和根据url获取文件路径
            var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
            path?.appendContentsOf("/article.image.cache")
            
            // 自定义缓存
            let imageCache = YYImageCache(path: path!)!
            
            if imageCache.containsImageForKey(imageString, withType: YYImageCacheType.Disk) {
                // 拼接图片的绝对路径
                let imagePath = "\(imageCache.diskCache.path)/data/\(imageString.md5())"
                // 发送图片占位标识和本地绝对路径给webView
                bridge?.send("replaceimage\(imageString),\(imagePath)")
            } else {
                let queue = NSOperationQueue()
                YYWebImageManager(cache: imageCache, queue: queue).requestImageWithURL(NSURL(string: imageString)!, options: YYWebImageOptions.UseNSURLCache, progress: { (_, _) in
                    }, transform: { (image, url) -> UIImage? in
                        return image
                    }, completion: { (image, url, type, stage, error) in
                        dispatch_sync(dispatch_get_main_queue(), {
                            guard let _ = image where error == nil else {return}
                            // 拼接图片的绝对路径
                            let imagePath = "\(imageCache.diskCache.path)/data/\(imageString.md5())"
                            // 发送图片占位标识和本地绝对路径给webView
                            self.bridge?.send("replaceimage\(imageString),\(imagePath)")
                        })
                })
            }
            
        }
        
    }
    
    // MARK: - 懒加载
    /// 活动指示器
    private lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityView.center = self.view.center
        return activityView
    }()
    
    /// webView
    private lazy var webView: UIWebView = {
        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        webView.delegate = self
        webView.scrollView.scrollEnabled = false
        return webView
    }()
    
    /// 底部条
    private lazy var bottomBarView: JFNewsBottomBar = {
        let bottomBarView = NSBundle.mainBundle().loadNibNamed("JFNewsBottomBar", owner: nil, options: nil).last as! JFNewsBottomBar
        bottomBarView.delegate = self
        return bottomBarView
    }()
    
    /// 顶部条
    private lazy var topBarView: UIView = {
        let topBarView = UIView()
        topBarView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
        return topBarView
    }()
    
    /// tableView
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        return tableView
    }()
    
    /// 尾部视图
    private lazy var footerView: UIView = {
        let moreCommentButton = UIButton(frame: CGRect(x: 20, y: 0, width: SCREEN_WIDTH - 40, height: 44))
        moreCommentButton.addTarget(self, action: #selector(didTappedmoreCommentButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        moreCommentButton.setTitle("更多评论", forState: UIControlState.Normal)
        moreCommentButton.backgroundColor = NAVIGATIONBAR_COLOR
        moreCommentButton.layer.cornerRadius = CORNER_RADIUS
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        footerView.addSubview(moreCommentButton)
        return footerView
    }()
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension JFNewsDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // 分享
            return 1
        case 1: // 广告
            return 1
        case 2: // 相关新闻
            return otherLinks.count
        case 3: // 评论
            return commentList.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: // 分享
            return 160
        case 1: // 广告
            return 160
        case 2: // 相关新闻
            return 44
        case 3: // 评论
            var rowHeight = commentList[indexPath.row].rowHeight
            if rowHeight < 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier(detailCommentIdentifier) as! JFCommentCell
                // 缓存高度
                commentList[indexPath.row].rowHeight = cell.getCellHeight(commentList[indexPath.row])
                rowHeight = commentList[indexPath.row].rowHeight
            }
            return rowHeight
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // 预估高度
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // 分享
            let cell = self.tableView.dequeueReusableCellWithIdentifier(self.detailStarAndShareIdentifier) as! JFStarAndShareCell
            cell.delegate = self
            cell.befromLabel.text = "文章来源: \(model!.befrom!)"
            cell.selectionStyle = .None
            return cell
        case 1: // 广告
            let cell = UITableViewCell()
            cell.selectionStyle = .None
            let adImageView = UIImageView(frame: CGRect(x: 12, y: 0, width: SCREEN_WIDTH - 24, height: 160))
            adImageView.image = UIImage(named: "temp_ad")
            cell.contentView.addSubview(adImageView)
            return cell
        case 2: // 相关新闻
            let cell = tableView.dequeueReusableCellWithIdentifier(detailOtherLinkIdentifier)!
            cell.textLabel?.text = otherLinks[indexPath.row].title
            let separatorView = UIView(frame: CGRect(x: 0, y: 43.5, width: SCREEN_WIDTH, height: 0.5))
            separatorView.backgroundColor = UIColor(white: 0.6, alpha: 0.5)
            cell.contentView.addSubview(separatorView)
            return cell
        case 3: // 评论
            let cell = tableView.dequeueReusableCellWithIdentifier(detailCommentIdentifier) as! JFCommentCell
            cell.delegate = self
            cell.commentModel = commentList[indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 2 || section == 3 {
            let leftRedView = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: 30))
            leftRedView.backgroundColor = NAVIGATIONBAR_COLOR
            
            let bgView = UIView(frame: CGRect(x: 3, y: 0, width: SCREEN_WIDTH - 3, height: 30))
            bgView.backgroundColor = UIColor(red:0.914,  green:0.890,  blue:0.847, alpha:0.3)
            
            let titleLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 100, height: 30))
            
            let headerView = UIView()
            headerView.addSubview(leftRedView)
            headerView.addSubview(bgView)
            headerView.addSubview(titleLabel)
            
            if section == 2 {
                titleLabel.text = "相关新闻"
                return otherLinks.count == 0 ? nil : headerView
            } else {
                titleLabel.text = "最新评论"
                return commentList.count == 0 ? nil : headerView
            }
            
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 3 {
            return commentList.count == 0 ? nil : footerView // 如果有评论才显示更多评论按钮
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 1
        case 1:
            return 10
        case 2:
            return otherLinks.count == 0 ? 1 : 30
        case 3:
            return commentList.count == 0 ? 1 : 30
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 1
        case 1:
            return 20
        case 2:
            return commentList.count == 0 ? 1 : 20
        case 3:
            return commentList.count == 0 ? 50 : 100
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 2 {
            let otherModel = otherLinks[indexPath.row]
            let detailVc = JFNewsDetailViewController()
            detailVc.articleParam = (otherModel.classid!, otherModel.id!)
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
    }
}

// MARK: - JFNewsBottomBarDelegate、JFCommentCommitViewDelegate、JFSetFontViewDelegate
extension JFNewsDetailViewController: JFNewsBottomBarDelegate, JFCommentCommitViewDelegate, JFSetFontViewDelegate {
    
    /**
     底部返回按钮点击
     */
    func didTappedBackButton(button: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /**
     底部编辑按钮点击
     */
    func didTappedEditButton(button: UIButton) {
        let commentCommitView = NSBundle.mainBundle().loadNibNamed("JFCommentCommitView", owner: nil, options: nil).last as! JFCommentCommitView
        commentCommitView.delegate = self
        commentCommitView.show()
    }
    
    /**
     底部字体按钮点击 - 原来是评论
     */
    func didTappedCommentButton(button: UIButton) {
        let setFontSizeView = NSBundle.mainBundle().loadNibNamed("JFSetFontView", owner: nil, options: nil).last as! JFSetFontView
        setFontSizeView.delegate = self
        setFontSizeView.show()
    }
    
    /**
     底部收藏按钮点击
     */
    func didTappedCollectButton(button: UIButton) {
        
        if JFAccountModel.isLogin() {
            let parameters: [String : AnyObject] = [
                "username" : JFAccountModel.shareAccount()!.username!,
                "userid" : JFAccountModel.shareAccount()!.id,
                "token" : JFAccountModel.shareAccount()!.token!,
                "classid" : articleParam!.classid,
                "id" : articleParam!.id
            ]
            
            JFNetworkTool.shareNetworkTool.post(ADD_DEL_FAVA, parameters: parameters) { (success, result, error) in
                if success {
                    if let successResult = result {
                        if successResult["result"]["status"].intValue == 1 {
                            // 增加成功
                            JFProgressHUD.showSuccessWithStatus("收藏成功")
                            button.selected = true
                        } else if successResult["result"]["status"].intValue == 3 {
                            // 删除成功
                            JFProgressHUD.showSuccessWithStatus("取消收藏")
                            button.selected = false
                        }
                    }
                }
            }
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: { })
        }
        
    }
    
    /**
     底部分享按钮点击
     */
    func didTappedShareButton(button: UIButton) {
        
        // 从缓存中获取标题图片
        guard let currentModel = model else {return}
        
        var image = YYImageCache.sharedCache().getImageForKey(sharePicUrl)
        if image != nil && (image?.size.width > 300 || image?.size.height > 300) {
            image = image?.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image!.size.height / image!.size.width))
        }
        
        // 标题url
        let titleurl = currentModel.titleurl!.hasPrefix("http") ? currentModel.titleurl! : "\(BASE_URL)\(currentModel.titleurl!)"
        
        let shareParames = NSMutableDictionary()
        shareParames.SSDKSetupShareParamsByText(currentModel.smalltext,
                                                images : image,
                                                url : NSURL(string: titleurl),
                                                title : currentModel.title,
                                                type : SSDKContentType.Auto)
        
        let items = [
            SSDKPlatformType.TypeQQ.rawValue,
            SSDKPlatformType.TypeWechat.rawValue,
            SSDKPlatformType.TypeSinaWeibo.rawValue
        ]
        
        ShareSDK.showShareActionSheet(nil, items: items, shareParams: shareParames) { (state : SSDKResponseState, platform: SSDKPlatformType, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!, end: Bool) in
            switch state {
            case SSDKResponseState.Success:
                print("分享成功")
            case SSDKResponseState.Fail:
                print("分享失败,错误描述:\(error)")
            case SSDKResponseState.Cancel:
                print("取消分享")
            default:
                break
            }
        }
        
    }
    
    /**
     点击了提交评论视图的发送按钮
     
     - parameter message: 评论信息
     */
    func didTappedSendButtonWithMessage(message: String) {
        
        var parameters = [String : AnyObject]()
        
        if JFAccountModel.isLogin() {
            parameters = [
                "classid" : articleParam!.classid,
                "id" : articleParam!.id,
                "userid" : JFAccountModel.shareAccount()!.id,
                "nomember" : "0",
                "username" : JFAccountModel.shareAccount()!.username!,
                "token" : JFAccountModel.shareAccount()!.token!,
                "saytext" : message
            ]
        } else {
            parameters = [
                "classid" : articleParam!.classid,
                "id" : articleParam!.id,
                "nomember" : "1",
                "saytext" : message
            ]
        }
        
        JFNetworkTool.shareNetworkTool.get(SUBMIT_COMMENT, parameters: parameters) { (success, result, error) in
            if success {
                // 加载数据
                self.updateData()
            }
        }
    }
    
    /**
     修改了正文字体大小，需要重新显示 添加图片缓存后，目前还有问题
     */
    func didChangeFontSize(fontSize: Int) {
        
        // 获取整个html代码
        var html = webView.stringByEvaluatingJavaScriptFromString("getHtml();")!
        html = (html as NSString).stringByReplacingOccurrencesOfString(".content {font-size: \(NSUserDefaults.standardUserDefaults().integerForKey(CONTENT_FONT_SIZE))px;", withString: ".content {font-size: \(fontSize)px;")
        let templatePath = NSBundle.mainBundle().pathForResource("article", ofType: "html")!
        let baseURL = NSURL(fileURLWithPath: templatePath as String)
        webView.loadHTMLString(html, baseURL: baseURL)
        
        NSUserDefaults.standardUserDefaults().setInteger(fontSize, forKey: CONTENT_FONT_SIZE)
    }
}

// MARK: - UIWebViewDelegate
extension JFNewsDetailViewController: UIWebViewDelegate {
    
    /**
     webView加载完成后更新webView高度并刷新tableView
     */
    func webViewDidFinishLoad(webView: UIWebView) {
        let result = webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight")
        if let height = result {
            let frame = webView.frame
            webView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, CGFloat((height as NSString).floatValue) + 20)
            tableView.tableHeaderView = webView
            self.activityView.stopAnimating()
        }
    }
    
}

// MARK: - JFStarAndShareCellDelegate
extension JFNewsDetailViewController: JFStarAndShareCellDelegate {
    
    /**
     根据类型分享
     */
    private func shareWithType(type: SSDKPlatformType) {
        
        guard let currentModel = model else {return}
        
        var image = YYImageCache.sharedCache().getImageForKey(sharePicUrl)
        if image != nil && (image?.size.width > 300 || image?.size.height > 300) {
            image = image?.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image!.size.height / image!.size.width))
        }
        
        // 标题url
        let titleurl = currentModel.titleurl!.hasPrefix("http") ? currentModel.titleurl! : "\(BASE_URL)\(currentModel.titleurl!)"
        
        let shareParames = NSMutableDictionary()
        shareParames.SSDKSetupShareParamsByText(currentModel.smalltext,
                                                images : image,
                                                url : NSURL(string: titleurl),
                                                title : currentModel.title,
                                                type : SSDKContentType.Auto)
        
        ShareSDK.share(type, parameters: shareParames) { (state : SSDKResponseState, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!) -> Void in
            switch state {
            case SSDKResponseState.Success:
                print("分享成功")
            case SSDKResponseState.Fail:
                print("分享失败,错误描述:\(error)")
            case SSDKResponseState.Cancel:
                print("取消分享")
            default:
                break
            }
        }
    }
    
    /**
     点击QQ
     */
    func didTappedQQButton(button: UIButton) {
        shareWithType(SSDKPlatformType.SubTypeQQFriend)
    }
    
    /**
     点击了微信
     */
    func didTappedWeixinButton(button: UIButton) {
        shareWithType(SSDKPlatformType.SubTypeWechatSession)
    }
    
    /**
     点击了朋友圈
     */
    func didTappedFriendCircleButton(button: UIButton) {
        shareWithType(SSDKPlatformType.SubTypeWechatTimeline)
    }
}

// MARK: - JFCommentCellDelegate
extension JFNewsDetailViewController: JFCommentCellDelegate {
    func didTappedStarButton(button: UIButton, commentModel: JFCommentModel) {
        button.selected = true
        
        let parameters = [
            "classid" : commentModel.classid,
            "id" : commentModel.id,
            "plid" : commentModel.plid,
            "dopl" : "1",
            "action" : "DoForPl"
        ]
        
        JFNetworkTool.shareNetworkTool.get(TOP_DOWN, parameters: parameters as? [String : AnyObject]) { (success, result, error) in
            //            print(result)
            JFProgressHUD.showInfoWithStatus(result!["result"]["info"].stringValue)
            if success {
                commentModel.zcnum += 1
                self.tableView.reloadData()
            }
        }
    }
}