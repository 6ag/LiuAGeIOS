//
//  JFNewsTableViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/1.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import SDCycleScrollView
import MJRefresh
import SwiftyJSON

class JFNewsTableViewController: UIViewController, SDCycleScrollViewDelegate {
    
    /// 分类数据
    var classid: String?
    // 当前加载页码
    var pageIndex = 1
    /// 列表模型数组
    var articleList = [JFArticleListModel]()
    /// 幻灯片模型数组
    var isGoodList = [JFArticleListModel]()
    /// 顶部轮播
    var topScrollView: SDCycleScrollView!
    
    /// 新闻cell重用标识符 无图、单图、单图大图、三图
    let newsNoPicCell = "newsNoPicCell"
    let newsOnePicCell = "newsOnePicCell"
    let newsBigOnePicCell = "newsBigOnePicCell"
    let newsThreePicCell = "newsThreePicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        
        if let classid = classid {
            loadIsGood(classid)
            loadNews(classid, pageIndex: 1, method: 0)
        }
        
    }
    
    /**
     准备tableView
     */
    fileprivate func prepareTableView() {
        
        view.addSubview(tableView)
        view.addSubview(placeholderView)
        placeholderView.startAnimation()
        
        // 注册cell
        tableView.register(UINib(nibName: "JFNewsNoPicCell", bundle: nil), forCellReuseIdentifier: newsNoPicCell)
        tableView.register(UINib(nibName: "JFNewsOnePicCell", bundle: nil), forCellReuseIdentifier: newsOnePicCell)
        tableView.register(UINib(nibName: "JFNewsThreePicCell", bundle: nil), forCellReuseIdentifier: newsThreePicCell)
        tableView.register(UINib(nibName: "JFNewsBigOnePicCell", bundle: nil), forCellReuseIdentifier: newsBigOnePicCell)
        
        // 配置上下拉刷新控件
        tableView.mj_header = setupHeaderRefresh(self, action: #selector(updateNewData))
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(loadMoreData))
    }
    
    /**
     准备tableHeaderView轮播
     */
    fileprivate func prepareScrollView() {
        
        topScrollView = SDCycleScrollView(frame: CGRect(x:0, y:0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 0.3), delegate:self, placeholderImage:UIImage(named: "list_placeholder"))
        topScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight
        topScrollView.pageDotColor = PRIMARY_COLOR
        topScrollView.currentPageDotColor = UIColor.black
        
        // 过滤无图崩溃
        var images = [String]()
        var titles = [String]()
        
        for index in 0..<isGoodList.count {
            if isGoodList[index].titlepic != nil {
                images.append(isGoodList[index].titlepic!)
                titles.append(isGoodList[index].title!)
            }
        }
        if images.count == 0 {
            return
        }
        
        topScrollView.imageURLStringsGroup = images
        topScrollView.titlesGroup = titles
        topScrollView.autoScrollTimeInterval = 5
        tableView.tableHeaderView = topScrollView
    }
    
    // MARK: - SDCycleScrollViewDelegate
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        
        let currentListModel = isGoodList[index]
        jumpToDetailViewControllerWith(currentListModel)
    }
    
    /**
     根据当前列表模型跳转到指定控制器
     
     - parameter currentListModel: 模型
     */
    fileprivate func jumpToDetailViewControllerWith(_ currentListModel: JFArticleListModel) {
        jumpToDetailVc(nav: navigationController!, articleModel: currentListModel)
    }
    
    // MARK: - 网络请求
    /**
     下拉加载最新数据
     */
    @objc fileprivate func updateNewData() {
        
        // 有网络的时候下拉会自动清除缓存
        if JFNetworkTool.shareNetworkTool.getCurrentNetworkState() != 0 {
            JFArticleListModel.cleanCache(classid!)
        }
        
        pageIndex = 1
        loadNews(classid!, pageIndex: pageIndex, method: 0)
        
        // 只有下拉的时候才去加载幻灯片数据
        loadIsGood(classid!)
    }
    
    /**
     上拉加载更多数据
     */
    @objc fileprivate func loadMoreData() {
        pageIndex += 1
        loadNews(classid!, pageIndex: pageIndex, method: 1)
    }
    
    /**
     根据分类id加载推荐数据、作为幻灯片数据
     
     - parameter classid: 当前栏目id
     */
    fileprivate func loadIsGood(_ classid: String) {
        
        JFArticleListModel.loadNewsList(classid, pageIndex: 1, type: 2, cache: true) { (articleListModels, error) in
            
            guard let list = articleListModels, error == nil else {
                return
            }
            
            self.isGoodList = list
            
            // 更新幻灯片
            self.prepareScrollView()
        }
        
    }
    
    /**
     根据分类id、页码加载数据
     
     - parameter classid:    当前栏目id
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    fileprivate func loadNews(_ classid: String, pageIndex: Int, method: Int) {
        
        JFArticleListModel.loadNewsList(classid, pageIndex: pageIndex, type: 1, cache: true) { (articleListModels, error) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            guard var list = articleListModels else {
                return
            }
            
            if list.count == 0 {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                
                if self.articleList.count == 0 {
                    self.placeholderView.noAnyData("还没有任何资讯")
                }
                return
            }
            self.placeholderView.removeAnimation()
            
            // 如果有广告软文，则插入
            if JFAdManager.shared.articleList.count > 0 && list.count >= 20 {
                let randNum = Int(arc4random_uniform(UInt32(JFAdManager.shared.articleList.count)))
                let adArticle = JFAdManager.shared.articleList[randNum]
                list.insert(adArticle, at: list.count - Int(arc4random_uniform(UInt32(10))))
            }
            
            if method == 0 {
                self.articleList = list
            } else {
                // 数据已经存在说明已经加载过了
                let lastId = self.articleList.last?.id
                for item in list {
                    if item.id == lastId {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        return
                    }
                }
                // 1上拉加载更多
                self.articleList = self.articleList + list
                
            }
            
            self.tableView.reloadData()
        }
        
    }
    
    /// 内容区域
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 104), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(red:0.9,  green:0.9,  blue:0.9, alpha:1)
        return tableView
    }()
    
    /// 没有内容的时候的占位图
    fileprivate lazy var placeholderView: JFPlaceholderView = {
        let placeholderView = JFPlaceholderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 104))
        placeholderView.backgroundColor = UIColor.white
        return placeholderView
    }()
    
}

// MARK: - Table view data source
extension JFNewsTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let postModel = articleList[indexPath.row]
        if postModel.titlepic == "" { // 无图
            if postModel.rowHeight == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: newsNoPicCell) as! JFNewsNoPicCell
                let height = cell.getRowHeight(postModel)
                postModel.rowHeight = height
            }
            return postModel.rowHeight
        } else if postModel.firsttitle != "0" { // 大单图
            if postModel.rowHeight == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: newsBigOnePicCell) as! JFNewsBigOnePicCell
                let height = cell.getRowHeight(postModel)
                postModel.rowHeight = height
            }
            return postModel.rowHeight
        } else if postModel.morepic?.count == 0 { // 单图
            if iPhoneModel.getCurrentModel() == .iPad {
                return 162
            } else {
                return 96
            }
        } else { // 多图
            if postModel.rowHeight == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: newsThreePicCell) as! JFNewsThreePicCell
                let height = cell.getRowHeight(postModel)
                postModel.rowHeight = height
            }
            return postModel.rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let postModel = articleList[indexPath.row]
        
        if postModel.titlepic == "" { // 无图
            let cell = tableView.dequeueReusableCell(withIdentifier: newsNoPicCell) as! JFNewsNoPicCell
            cell.postModel = postModel
            return cell
        } else if postModel.firsttitle != "0" { // 大单图
            let cell = tableView.dequeueReusableCell(withIdentifier: newsBigOnePicCell) as! JFNewsBigOnePicCell
            cell.postModel = postModel
            return cell
        } else if postModel.morepic?.count == 0 { // 单图
            let cell = tableView.dequeueReusableCell(withIdentifier: newsOnePicCell) as! JFNewsOnePicCell
            cell.postModel = postModel
            return cell
        } else { // 多图
            let cell = tableView.dequeueReusableCell(withIdentifier: newsThreePicCell) as! JFNewsThreePicCell
            cell.postModel = postModel
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 跳转控制器
        let currentListModel = articleList[indexPath.row]
        jumpToDetailViewControllerWith(currentListModel)
    }
}
