//
//  JFAdWebViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFAdWebViewController: UIViewController {
    
    /// web广告参数
    var webParam: (title: String, titleurl: String, titlepic: String?)?
    
    // MARK: - 属性
    fileprivate var contentOffsetY: CGFloat = 0.0
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.statusBarStyle = .default
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        tableView.tableHeaderView = webView
        tableView.tableFooterView = closeDetailView
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        view.addSubview(topBarView)
        view.addSubview(bottomBarView)
        view.addSubview(activityView)
        activityView.startAnimating()
        
        activityView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
        topBarView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(0)
            make.height.equalTo(20)
        }
        bottomBarView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(45)
        }
        
        guard let titleurl = webParam?.titleurl else { return }
        if let url = URL(string: titleurl) {
            webView.loadRequest(URLRequest(url: url))
        }
    }
    
    // MARK: - 懒加载
    /// tableView - 整个容器
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: SCREEN_BOUNDS, style: UITableViewStyle.plain)
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        return tableView
    }()
    
    /// webView - 显示正文的
    fileprivate lazy var webView: UIWebView = {
        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        webView.dataDetectorTypes = UIDataDetectorTypes()
        webView.delegate = self
        webView.scrollView.isScrollEnabled = false
        return webView
    }()
    
    /// 活动指示器 - 页面正在加载时显示
    fileprivate lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        return activityView
    }()
    
    /// 底部工具条
    fileprivate lazy var bottomBarView: JFNewsBottomBar = {
        let bottomBarView = Bundle.main.loadNibNamed("JFNewsBottomBar", owner: nil, options: nil)?.last as! JFNewsBottomBar
        bottomBarView.delegate = self
        return bottomBarView
    }()
    
    /// 顶部透明白条
    fileprivate lazy var topBarView: UIView = {
        let topBarView = UIView()
        topBarView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
        return topBarView
    }()
    
    /// 尾部关闭视图
    fileprivate lazy var closeDetailView: JFCloseDetailView = {
        let closeDetailView = JFCloseDetailView(frame: CGRect(x: 0, y: 20, width: SCREEN_WIDTH, height: 26))
        closeDetailView.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        closeDetailView.setTitleColor(UIColor(white: 0.2, alpha: 1), for: UIControlState())
        closeDetailView.setTitleColor(UIColor(white: 0.2, alpha: 1), for: UIControlState.selected)
        closeDetailView.isSelected = false
        closeDetailView.setTitle("上拉关闭当前页", for: UIControlState())
        closeDetailView.setImage(UIImage(named: "newscontent_drag_arrow"), for: UIControlState())
        closeDetailView.setTitle("释放关闭当前页", for: UIControlState.selected)
        closeDetailView.setImage(UIImage(named: "newscontent_drag_return"), for: UIControlState.selected)
        return closeDetailView
    }()
    
    /// 分享视图
    fileprivate lazy var shareView: JFShareView = {
        let shareView = JFShareView()
        shareView.delegate = self
        return shareView
    }()
    
}

// MARK: - 控制底部条
extension JFAdWebViewController: UITableViewDelegate {
    
    // 开始拖拽视图
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        contentOffsetY = scrollView.contentOffset.y
    }
    
    // 松手后触发
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if (scrollView.contentOffset.y + SCREEN_HEIGHT) > scrollView.contentSize.height {
            if (scrollView.contentOffset.y + SCREEN_HEIGHT) - scrollView.contentSize.height >= 50 {
                
                UIGraphicsBeginImageContext(SCREEN_BOUNDS.size)
                UIApplication.shared.keyWindow?.layer.render(in: UIGraphicsGetCurrentContext()!)
                let tempImageView = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext())
                UIApplication.shared.keyWindow?.addSubview(tempImageView)
                
                _ = navigationController?.popViewController(animated: false)
                UIView.animate(withDuration: 0.3, animations: {
                    tempImageView.alpha = 0
                    tempImageView.frame = CGRect(x: 0, y: SCREEN_HEIGHT * 0.5, width: SCREEN_WIDTH, height: 0)
                }, completion: { (_) in
                    tempImageView.removeFromSuperview()
                })
                
            }
        }
    }
    
    /**
     手指滑动屏幕开始滚动
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (scrollView.isDragging) {
            if scrollView.contentOffset.y - contentOffsetY > 5.0 {
                // 向上拖拽 隐藏
                UIView.animate(withDuration: 0.25, animations: {
                    self.bottomBarView.transform = CGAffineTransform(translationX: 0, y: 44)
                })
            } else if contentOffsetY - scrollView.contentOffset.y > 5.0 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.bottomBarView.transform = CGAffineTransform.identity
                })
            }
            
        }
        
        if (scrollView.contentOffset.y + SCREEN_HEIGHT) > scrollView.contentSize.height {
            if (scrollView.contentOffset.y + SCREEN_HEIGHT) - scrollView.contentSize.height >= 50 {
                closeDetailView.isSelected = true
            } else {
                closeDetailView.isSelected = false
            }
        }
        
    }
    
    /**
     滚动减速结束
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // 滚动到底部后 显示
        if case let space = scrollView.contentOffset.y + SCREEN_HEIGHT - scrollView.contentSize.height, space > -5 && space < 5 {
            UIView.animate(withDuration: 0.25, animations: {
                self.bottomBarView.transform = CGAffineTransform.identity
            })
        }
    }

}

// MARK: - 底部浮动工具条相关
extension JFAdWebViewController: JFNewsBottomBarDelegate {
    
    /**
     底部返回按钮点击
     */
    func didTappedBackButton(_ button: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    /**
     底部编辑按钮点击
     */
    func didTappedEditButton(_ button: UIButton) {
        JFProgressHUD.showInfoWithStatus("当前不支持评论")
    }
    
    /**
     底部字体按钮点击 - 原来是评论
     */
    func didTappedCommentButton(_ button: UIButton) {
        JFProgressHUD.showInfoWithStatus("当前不支持修改字体")
    }
    
    /**
     底部收藏按钮点击
     */
    func didTappedCollectButton(_ button: UIButton) {
        JFProgressHUD.showInfoWithStatus("当前不支持收藏")
    }
    
    /**
     底部分享按钮点击
     */
    func didTappedShareButton(_ button: UIButton) {
        if JFShareItemModel.loadShareItems().count == 0 {
            JFProgressHUD.showInfoWithStatus("没有可分享内容")
            return
        }
        
        // 弹出分享视图
        shareView.showShareView()
    }
    
}

// MARK: - 分享相关 - 这是正文中心的三个按钮和底部分享视图的分享事件
extension JFAdWebViewController: JFShareViewDelegate {
    
    /**
     获取文章分享参数
     
     - returns: 获取文章分享参数
     */
    func getShareParameters() -> NSMutableDictionary? {
        
        // 分享图片
        var image = YYImageCache.shared().getImageForKey(webParam?.titlepic ?? "")
        if image != nil && (image!.size.width > 300.0 || image!.size.height > 300.0) {
            image = image?.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image!.size.height / image!.size.width))
        } else {
            image = UIImage(named: "app_icon")
        }
        
        // 分享标题
        var titleurl = webParam?.titleurl ?? ""
        titleurl = titleurl.hasPrefix("http") ? titleurl : "\(BASE_URL)\(titleurl)"
        
        let shareParames = NSMutableDictionary()
        shareParames.ssdkSetupShareParams(byText: webParam?.title ?? "",
                                          images : image,
                                          url : URL(string: titleurl),
                                          title : webParam?.title ?? "",
                                          type : SSDKContentType.auto)
        return shareParames
    }
    
    /**
     根据类型分享
     */
    fileprivate func shareWithType(_ platformType: SSDKPlatformType) {
        
        guard let shareParames = getShareParameters() else {
            return
        }
        
        ShareSDK.share(platformType, parameters: shareParames) { (state, _, entity, error) in
            switch state {
            case SSDKResponseState.success:
                log("分享成功")
            case SSDKResponseState.fail:
                log("授权失败,错误描述:\(error)")
            case SSDKResponseState.cancel:
                log("操作取消")
            default:
                break
            }
        }
        
    }
    
    /// 底部弹出的分享视图的分享按钮点击事件
    ///
    /// - Parameter type: 需要分享的类型
    func share(type: JFShareType) {
        
        let platformType: SSDKPlatformType!
        switch type {
        case .qqFriend:
            platformType = SSDKPlatformType.subTypeQZone // 尼玛，这竟然是反的。。ShareSDK bug
        case .qqQzone:
            platformType = SSDKPlatformType.subTypeQQFriend // 尼玛，这竟然是反的。。
        case .weixinFriend:
            platformType = SSDKPlatformType.subTypeWechatSession
        case .friendCircle:
            platformType = SSDKPlatformType.subTypeWechatTimeline
        case .sina:
            platformType = SSDKPlatformType.typeSinaWeibo
        }
        
        // 立即分享
        shareWithType(platformType)
        
    }
    
}

// MARK: - webView相关
extension JFAdWebViewController: UIWebViewDelegate {
    
    /**
     webView加载完成后更新webView高度并刷新tableView
     */
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        if !webView.isLoading {
            let result = webView.stringByEvaluatingJavaScript(from: "document.body.offsetHeight;")
            if let height = result {
                webView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: CGFloat((height as NSString).floatValue) + 50)
                tableView.tableHeaderView = webView
                self.activityView.stopAnimating()
            }
        }
    }
    
}
