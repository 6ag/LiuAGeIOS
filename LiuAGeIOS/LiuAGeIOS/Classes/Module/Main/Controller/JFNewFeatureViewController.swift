//
//  JFNewFeatureViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/23.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import SnapKit

class JFNewFeatureViewController: UICollectionViewController {
    
    // MARK: 属性
    private let itemCount = 4
    private var layout = UICollectionViewFlowLayout()
    let reuseIdentifier = "Cell"
    
    init() {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareCollectionView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    /**
     准备collectionView
     */
    private func prepareCollectionView() {
        collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView!.registerClass(JFNewFeatureCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // 设置layout的参数
        layout.itemSize = UIScreen.mainScreen().bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView?.pagingEnabled = true
        collectionView?.bounces = false
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! JFNewFeatureCell
        cell.imageIndex = indexPath.item
        return cell
    }
    
    // collectionView显示完毕cell
    // collectionView分页滚动完毕cell看不到的时候调用
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        // 正在显示的cell的indexPath
        let showIndexPath = collectionView.indexPathsForVisibleItems().first!
        
        // 获取collectionView正在显示的cell
        let cell = collectionView.cellForItemAtIndexPath(showIndexPath) as! JFNewFeatureCell
        
        // 最后一页动画
        if showIndexPath.item == itemCount - 1 {
            // 开始按钮动画
            cell.startButtonAnimation()
        }
    }
    
}
