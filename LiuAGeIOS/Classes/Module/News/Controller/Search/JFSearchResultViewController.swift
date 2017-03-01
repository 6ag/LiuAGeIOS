//
//  JFSearchResultViewController.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/24.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFSearchResultViewController: UIViewController {

    // 当前加载页码
    var pageIndex = 1
    
    /// 列表模型数组
    var articleList = [JFArticleListModel]()
    
    /// 关键词
    var keyboard: String?
    
    /// 新闻cell重用标识符 无图、单图、三图
    let newsNoPicCell = "newsNoPicCell"
    let newsOnePicCell = "newsOnePicCell"
    let newsThreePicCell = "newsThreePicCell"
    let newsBigOnePicCell = "newsBigOnePicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }

    /**
     准备tableView
     */
    fileprivate func prepareUI() {
        
        title = "搜索结果"
        view.backgroundColor = BACKGROUND_COLOR
        view.addSubview(tableView)
    }
    
    /**
     上拉加载更多数据
     */
    @objc fileprivate func loadMoreData() {
        pageIndex += 1
        loadSearchResult(keyboard ?? "", pageIndex: pageIndex)
    }
    
    /**
     加载搜索结果
     
     - parameter keyboard:  关键词
     - parameter pageIndex: 页码
     */
    fileprivate func loadSearchResult(_ keyboard: String, pageIndex: Int) {
        
        JFArticleListModel.loadSearchResult(keyboard, pageIndex: pageIndex) { (searchResultModels, error) in
            
            self.tableView.mj_footer.endRefreshing()
            
            guard let list = searchResultModels, list.count > 0 else {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            let lastId = self.articleList.last?.id
            // 数据已经存在说明已经加载过了
            for item in list {
                if item.id == lastId {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    return
                }
            }
            
            // 上拉加载更多
            self.articleList = self.articleList + list
            self.tableView.reloadData()
            
        }
        
    }
    
    /**
     根据当前列表模型跳转到指定控制器
     
     - parameter currentListModel: 模型
     */
    fileprivate func jumpToDetailViewControllerWith(_ currentListModel: JFArticleListModel) {
        jumpToDetailVc(nav: navigationController!, articleModel: currentListModel)
    }
    
    // MARK: - 懒加载
    /// 内容区域
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(red:0.9,  green:0.9,  blue:0.9, alpha:1)
        tableView.register(UINib(nibName: "JFNewsNoPicCell", bundle: nil), forCellReuseIdentifier: self.newsNoPicCell)
        tableView.register(UINib(nibName: "JFNewsOnePicCell", bundle: nil), forCellReuseIdentifier: self.newsOnePicCell)
        tableView.register(UINib(nibName: "JFNewsBigOnePicCell", bundle: nil), forCellReuseIdentifier: self.newsBigOnePicCell)
        tableView.register(UINib(nibName: "JFNewsThreePicCell", bundle: nil), forCellReuseIdentifier: self.newsThreePicCell)
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(loadMoreData))
        return tableView
    }()

}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFSearchResultViewController: UITableViewDataSource, UITableViewDelegate {
    
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
