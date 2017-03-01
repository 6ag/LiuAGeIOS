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
    fileprivate let itemCount = 4
    fileprivate var layout = UICollectionViewFlowLayout()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.slide)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.slide)
    }
    
    /**
     准备collectionView
     */
    fileprivate func prepareCollectionView() {
        
        self.collectionView!.register(JFNewFeatureCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        layout.itemSize = SCREEN_BOUNDS.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        collectionView?.isPagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! JFNewFeatureCell
        cell.imageIndex = indexPath.item
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let showIndexPath = collectionView.indexPathsForVisibleItems.last!
        let cell = collectionView.cellForItem(at: showIndexPath) as! JFNewFeatureCell
        
        if showIndexPath.item == itemCount - 1 {
            cell.startButtonAnimation()
        }
    }
    
}
