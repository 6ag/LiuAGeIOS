//
//  JFSearchViewController.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/24.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

fileprivate let KEYBOARD_CELL_ID = "KEYBOARD_CELL_ID"
fileprivate let HOT_KEYBOARD_CELL_ID = "HOT_KEYBOARD_CELL_ID"

// 间隔
fileprivate let SPACE: CGFloat = 10

class JFSearchViewController: UIViewController {
    
    fileprivate var searchKeyboardmodels = [JFSearchKeyboardModel]()
    fileprivate var hotKeyboardmodels = [JFSearchKeyboardModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        loadHotKeyboardList()
        
        // 进入页面过一秒弹出文本框
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { 
            self.searchTextField.becomeFirstResponder()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchTextField.endEditing(true)
        super.viewWillDisappear(animated)
    }

    /**
     准备tableView
     */
    fileprivate func prepareTableView() {
        
        view.backgroundColor = BACKGROUND_COLOR
        navigationItem.titleView = searchTextField
        view.addSubview(tableView)
        view.addSubview(collectionView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(SCREEN_HEIGHT - layoutVertical(iPhone6: 44) - 20)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(SCREEN_HEIGHT - layoutVertical(iPhone6: 44) - 20)
        }
        
    }
    
    /**
     加载关键词列表
     
     - parameter keyboard: 关键词
     */
    fileprivate func loadSearchKeyboardList(_ keyboard: String) {
        
        JFSearchKeyboardModel.loadSearchKeyList(keyboard) { (searchKeyboardModels, error) in
            
            guard let list = searchKeyboardModels else {
                return
            }
            
            self.searchKeyboardmodels = list
            self.tableView.reloadData()
        }
    }
    
    /**
     加载热门关键词列表
     
     - parameter keyboard: 关键词
     */
    fileprivate func loadHotKeyboardList() {
        
        JFSearchKeyboardModel.loadSearchKeyListFromLocationOrderByNum() { (searchKeyboardModels, error) in
            
            guard let list = searchKeyboardModels else {
                return
            }
            
            self.hotKeyboardmodels = list
            self.collectionView.reloadData()
        }
    }
    
    /**
     加载搜索结果
     
     - parameter keyboard:  关键词
     */
    fileprivate func loadSearchResult(_ keyboard: String) {
        
        JFProgressHUD.showWithStatus("正在搜索...")
        JFArticleListModel.loadSearchResult(keyboard, pageIndex: 1) { (searchResultModels, error) in
            
            guard let list = searchResultModels, list.count > 0 else {
                JFProgressHUD.showInfoWithStatus("没有搜索到任何内容")
                return
            }
            
            JFProgressHUD.dismiss()
            
            // 进入搜索详情页面
            let searchResultVc = JFSearchResultViewController()
            searchResultVc.articleList = list
            searchResultVc.keyboard = keyboard
            self.navigationController?.pushViewController(searchResultVc, animated: true)
        }
        
    }
    
    // MARK: - 懒加载
    /// 搜索框
    fileprivate lazy var searchTextField: UISearchBar = {
        let searchTextField = UISearchBar(frame: CGRect(x: 20, y: 5, width: SCREEN_WIDTH - 40, height: 34))
        searchTextField.delegate = self
        searchTextField.backgroundColor = UIColor.clear
        searchTextField.placeholder = "请输入关键词..."
        return searchTextField
    }()
    
    /// 搜索关键词关联列表
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorColor = UIColor(red:0.9,  green:0.9,  blue:0.9, alpha:1)
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: KEYBOARD_CELL_ID)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    /// 热门关键词
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (SCREEN_WIDTH - (5 * SPACE)) / 4.0, height: 30)
        layout.minimumLineSpacing = SPACE
        layout.minimumInteritemSpacing = SPACE
        layout.sectionInset = UIEdgeInsets(top: SPACE, left: SPACE, bottom: SPACE, right: SPACE)
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceVertical = true
        collectionView.register(JFHotKeyboardCell.classForCoder(), forCellWithReuseIdentifier: HOT_KEYBOARD_CELL_ID)
        return collectionView
    }()
    
}

// MARK: - UISearchBarDelegate
extension JFSearchViewController: UISearchBarDelegate {
    
    // 已经改变搜索文字
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
        }
        loadSearchKeyboardList(searchText)
    }
    
    // 点击了搜索按钮
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTextField.endEditing(true)
        loadSearchResult(searchBar.text!)
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension JFSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotKeyboardmodels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HOT_KEYBOARD_CELL_ID, for: indexPath) as! JFHotKeyboardCell
        cell.keyboardModel = hotKeyboardmodels[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let keyboardModel = hotKeyboardmodels[indexPath.item]
        searchTextField.endEditing(true)
        loadSearchResult(keyboardModel.keyboard!)
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchKeyboardmodels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: KEYBOARD_CELL_ID)!
        cell.textLabel?.text = searchKeyboardmodels[indexPath.row].keyboard
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        searchTextField.text = searchKeyboardmodels[indexPath.row].keyboard
        searchBarSearchButtonClicked(searchTextField)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchTextField.endEditing(true)
    }
    
}
