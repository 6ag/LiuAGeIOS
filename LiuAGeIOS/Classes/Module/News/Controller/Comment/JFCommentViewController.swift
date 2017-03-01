//
//  JFCommentViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/18.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import MJRefresh

class JFCommentViewController: UIViewController {
    
    var param: (classid: String, id: String)?
    
    // 页码
    var pageIndex = 1
    
    var commentList = [JFCommentModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    fileprivate func prepareUI() {
        
        title = "评论列表"
        view.addSubview(tableView)
        view.addSubview(placeholderView)
        placeholderView.startAnimation()
        
        updateNewData()
    }
    
    /**
     下拉加载最新数据
     */
    @objc fileprivate func updateNewData() {
        loadCommentList(param?.classid ?? "", id: param?.id ?? "", pageIndex: 1, method: 0)
    }
    
    /**
     上拉加载更多数据
     */
    @objc fileprivate func loadMoreData() {
        pageIndex += 1
        loadCommentList(param?.classid ?? "", id: param?.id ?? "", pageIndex: pageIndex, method: 1)
    }
    
    /**
     根据id、页码加载评论数据
     
     - parameter classid:    当前栏目id
     - parameter id:         当前新闻id
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    func loadCommentList(_ classid: String, id: String, pageIndex: Int, method: Int) {
        
        JFCommentModel.loadCommentList(classid, id: id, pageIndex: pageIndex, pageSize: 20) { (commentModels, error) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            guard let models = commentModels, error == nil else {return}
            
            if models.count == 0 {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                
                if self.commentList.count == 0 {
                    self.placeholderView.noAnyData("还没有任何评论信息")
                }
                return
            }
            self.placeholderView.removeAnimation()
            
            if method == 0 {
                self.commentList = models
            } else {
                
                // 数据已经存在说明已经加载过了
                let lastId = self.commentList.last?.plid ?? 0
                for item in models {
                    if item.plid == lastId {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        return
                    }
                }
                
                // 1上拉加载更多
                self.commentList = self.commentList + models
                
            }
            
            self.tableView.reloadData()
        }
        
    }
    
    /// 内容区域
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 20 - layoutHorizontal(iPhone6: 44)), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "JFCommentCell", bundle: nil), forCellReuseIdentifier: "commentCell")
        // 配置上下拉刷新控件
        tableView.mj_header = setupHeaderRefresh(self, action: #selector(updateNewData))
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(loadMoreData))
        return tableView
    }()
    
    /// 没有内容的时候的占位图
    fileprivate lazy var placeholderView: JFPlaceholderView = {
        let placeholderView = JFPlaceholderView(frame: self.view.bounds)
        placeholderView.backgroundColor = UIColor.white
        return placeholderView
    }()
    
}

// MARK: - tableView
extension JFCommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! JFCommentCell
        cell.delegate = self
        cell.commentModel = commentList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 回复指定评论，下一版实现
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight = commentList[indexPath.row].rowHeight
        if rowHeight < 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! JFCommentCell
            commentList[indexPath.row].rowHeight = cell.getCellHeight(commentList[indexPath.row])
            rowHeight = commentList[indexPath.row].rowHeight
        }
        return rowHeight
    }
    
}

// MARK: - JFCommentCellDelegate
extension JFCommentViewController: JFCommentCellDelegate {
    
    func didTappedStarButton(_ button: UIButton, commentModel: JFCommentModel) {
        
        let parameters = [
            "classid" : commentModel.classid ?? "",
            "id" : commentModel.id ?? "",
            "plid" : commentModel.plid,
            "dopl" : "1",
            "action" : "DoForPl"
        ] as [String : Any]
        
        JFNetworkTool.shareNetworkTool.get(TOP_DOWN, parameters: parameters) { (success, result, error) in
            
            if success {
                JFProgressHUD.showInfoWithStatus("谢谢支持")
                
                // 只要顶成功才选中
                button.isSelected = true
                
                commentModel.zcnum += 1
                commentModel.isStar = true
                
                // 刷新单行
                let indexPath = IndexPath(row: self.commentList.index(of: commentModel)!, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            } else {
                JFProgressHUD.showInfoWithStatus("不能重复顶哦")
            }
            
            jf_setupButtonSpringAnimation(button)
        }
    }
}


