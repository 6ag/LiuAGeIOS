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

class JFNewsTableViewController: UITableViewController, SDCycleScrollViewDelegate {
    
    /// 分类数据
    var classid: Int? {
        didSet {
            tableView.mj_header.beginRefreshing()
        }
    }
    
    // 当前加载页码
    var pageIndex = 1
    /// 列表模型数组
    var articleList = [JFArticleListModel]()
    /// 幻灯片模型数组
    var isGoodList = [JFArticleListModel]()
    
    /// 新闻cell重用标识符 无图、单图、三图
    let newsNoPicCell = "newsNoPicCell"
    let newsOnePicCell = "newsOnePicCell"
    let newsThreePicCell = "newsThreePicCell"
    
    /// 顶部轮播
    var topScrollView: SDCycleScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
    }
    
    /**
     准备tableView
     */
    private func prepareTableView() {
        
        // 注册cell
        tableView.registerNib(UINib(nibName: "JFNewsNoPicCell", bundle: nil), forCellReuseIdentifier: newsNoPicCell)
        tableView.registerNib(UINib(nibName: "JFNewsOnePicCell", bundle: nil), forCellReuseIdentifier: newsOnePicCell)
        tableView.registerNib(UINib(nibName: "JFNewsThreePicCell", bundle: nil), forCellReuseIdentifier: newsThreePicCell)
        
        // 分割线颜色
        tableView.separatorColor = UIColor(red:0.9,  green:0.9,  blue:0.9, alpha:1)
        
        // 配置MJRefresh
        let headerRefresh = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(updateNewData))
        headerRefresh.lastUpdatedTimeLabel.hidden = true
        tableView.mj_header = headerRefresh
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
    }
    
    /**
     准备头部轮播
     */
    private func prepareScrollView() {
        
        topScrollView = SDCycleScrollView(frame: CGRect(x:0, y:0, width: SCREEN_WIDTH, height:150), delegate:self, placeholderImage:UIImage(named: "photoview_image_default_white"))
        topScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight
        topScrollView.pageDotColor = NAVIGATIONBAR_COLOR
        topScrollView.currentPageDotColor = UIColor.blackColor()
        
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
    func cycleScrollView(cycleScrollView: SDCycleScrollView!, didSelectItemAtIndex index: Int) {
        
        let currentListModel = isGoodList[index]
        jumpToDetailViewControllerWith(currentListModel)
    }
    
    /**
     根据当前列表模型跳转到指定控制器
     
     - parameter currentListModel: 模型
     */
    private func jumpToDetailViewControllerWith(currentListModel: JFArticleListModel) {
        // 如果是多图就跳转到图片浏览器
        if currentListModel.piccount == 3 {
            let photoDetailVc = JFPhotoDetailViewController()
            photoDetailVc.photoParam = (currentListModel.classid!, currentListModel.id!)
            navigationController?.pushViewController(photoDetailVc, animated: true)
        } else {
            let articleDetailVc = JFNewsDetailViewController()
            articleDetailVc.sharePicUrl = currentListModel.titlepic!
            articleDetailVc.articleParam = (currentListModel.classid!, currentListModel.id!)
            navigationController?.pushViewController(articleDetailVc, animated: true)
        }
    }
    
    // MARK: - 网络请求
    /**
     下拉加载最新数据
     */
    @objc private func updateNewData() {
        loadNews(classid!, pageIndex: 1, method: 0)
        
        // 只有下拉的时候才去加载幻灯片数据
        loadIsGood(classid!)
    }
    
    /**
     上拉加载更多数据
     */
    @objc private func loadMoreData() {
        pageIndex += 1
        loadNews(classid!, pageIndex: pageIndex, method: 1)
    }
    
    /**
     根据分类id加载推荐数据、作为幻灯片数据
     
     - parameter classid: 当前栏目id
     */
    private func loadIsGood(classid: Int) {
        
        let parameters: [String : AnyObject] = [
            "classid" : classid,
            "query" : "isgood",
            "pageSize" : 3
        ]
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_LIST, parameters: parameters) { (success, result, error) -> () in
            if success == true {
                guard let successResult = result else {
                    return
                }
                
                // 如果有数据则清空原来的数据
                self.isGoodList.removeAll()
                let data = successResult["data"].arrayValue.reverse()
                for article in data {
                    var dict: [String : AnyObject] = [
                        "title" : article["title"].stringValue,     // 文章标题
                        "classid" : article["classid"].stringValue, // 文章栏目id
                        "id" : article["id"].stringValue,           // 文章id
                    ]
                    
                    // 判断是否有标题图片 幻灯片必须要有图片
                    if article["titlepic"].string != "" {
                        dict["titlepic"] = article["titlepic"].stringValue // 标题图片
                        
                        // 判断是否是多图
                        if let _ = article["morepic"].array {
                            dict["piccount"] = 3
                        } else {
                            dict["piccount"] = 1
                        }
                        
                        // 字典转模型
                        let postModel = JFArticleListModel(dict: dict)
                        self.isGoodList.append(postModel)
                    }
                    
                }
                
                // 更新幻灯片
                self.prepareScrollView()
            }
        }
    }
    
    /**
     根据分类id、页码加载数据
     
     - parameter classid:    当前栏目id
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    private func loadNews(classid: Int, pageIndex: Int, method: Int) {
        
        let parameters: [String : AnyObject] = [
            "classid" : classid,
            "pageIndex" : pageIndex,
            "pageSize" : 10
        ]
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_LIST, parameters: parameters) { (success, result, error) -> () in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            guard let successResult = result else {
                JFProgressHUD.showInfoWithStatus("您的网络不给力")
                return
            }
//            print(successResult)
            var data = successResult["data"].arrayValue
            if method == 0 {
                // 根据文章id从小到大排序 文章id小的最终后显示在列表后面，越大在越前面
                data = data.sort({ (n1, n2) -> Bool in
                    return n2["id"].intValue > n1["id"].intValue
                })
            }
            
            // 用于做上下拉的
            let maxId = self.articleList.first?.id ?? "0"
            let minId = self.articleList.last?.id ?? "0"
            
            for article in data {
                var dict: [String : AnyObject] = [
                    "classid" : article["classid"].stringValue,      // 当前分类id
                    "id" : article["id"].stringValue,                // 文章id
                    "title" : article["title"].stringValue,          // 文章标题
                    "newstime" : article["created_at"].stringValue,  // 发布时间
                    "created_at" : article["created_at"].stringValue,// 创建文章时间戳
                    "smalltext" : article["smalltext"].stringValue,  // 简介
                    "onclick" : article["onclick"].stringValue,      // 点击量
                    "befrom" : article["befrom"].stringValue,        // 文章来源
                ]
                
                // 判断是否有标题图片
                if article["titlepic"].string != "" {
                    dict["titlepic"] = article["titlepic"].stringValue // 标题图片
                    
                    // 标题多图
                    let morepics = article["morepic"].array
                    if let morepic = morepics {
                        var morepicArray = [String]()
                        for picdict in morepic {
                            let smallpic = picdict["smallpic"].stringValue
                            morepicArray.append(smallpic)
                        }
                        dict["morepic"] = morepicArray
                        dict["piccount"] = 3
                    } else {
                        dict["piccount"] = 1
                    }
                } else {
                    dict["piccount"] = 0 // 列表图片显示数量 无图、单图、三图
                }
                
                // 字典转模型
                let postModel = JFArticleListModel(dict: dict)
                
                // 0下拉加载最新 1上拉加载更多
                if method == 0 {
                    if Int(maxId) < Int(postModel.id!) {
                        self.articleList.insert(postModel, atIndex: 0)
                    }
                } else {
                    if Int(minId) > Int(postModel.id!) {
                        self.articleList.append(postModel)
                    }
                }
                
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleList.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let postModel = articleList[indexPath.row]
        if postModel.piccount == 0 {
            if postModel.rowHeight == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(newsNoPicCell) as! JFNewsNoPicCell
                let height = cell.getRowHeight(postModel)
                postModel.rowHeight = height
            }
            return postModel.rowHeight
        } else if postModel.piccount == 1 {
            // 单图的高度固定
            return 96
        } else if postModel.piccount == 3 {
            if postModel.rowHeight == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(newsThreePicCell) as! JFNewsThreePicCell
                let height = cell.getRowHeight(postModel)
                postModel.rowHeight = height
            }
            return postModel.rowHeight
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let postModel = articleList[indexPath.row]
        if postModel.piccount == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(newsNoPicCell) as! JFNewsNoPicCell
            cell.postModel = postModel
            return cell
        } else if postModel.piccount == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(newsOnePicCell) as! JFNewsOnePicCell
            cell.postModel = postModel
            return cell
        } else if postModel.piccount == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier(newsThreePicCell) as! JFNewsThreePicCell
            cell.postModel = postModel
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // 取消cell选中状态
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // 当前被点击cell的模型
        let currentListModel = articleList[indexPath.row]
        jumpToDetailViewControllerWith(currentListModel)
    }
    
}
