//
//  JFNewFeatureCell.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/5.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFNewFeatureCell: UICollectionViewCell {
    
    // MARK: 属性
    var imageIndex: Int = 0 {
        didSet {
            backgroundImageView.image = UIImage(named: "new_feature_\(imageIndex + 1)")
            startButton.alpha = 0
        }
    }
    
    // MARK: - 构造方法
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    // MARK: - 开始按钮动画
    func startButtonAnimation() {
        startButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 1, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            self.startButton.alpha = 1
            self.startButton.transform = CGAffineTransform.identity
        }) { (_) -> Void in
            
        }
    }
    
    // MARK: - 准备UI
    fileprivate func prepareUI() {
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(startButton)
        
        backgroundImageView.frame = SCREEN_BOUNDS
        startButton.frame = CGRect(x: (SCREEN_WIDTH - 140) * 0.5, y: SCREEN_HEIGHT * 0.8, width: 140, height: 40)
    }
    
    /**
     开始按钮点击
     */
    func startButtonClick() {
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard.init(name: "JFNewsViewController", bundle: nil).instantiateInitialViewController()
    }
    
    // MARK: - 懒加载
    /// 背景
    fileprivate lazy var backgroundImageView = UIImageView()
    
    /// 开始体验按钮
    fileprivate lazy var startButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.backgroundColor = UIColor.orange
        button.setTitle("开始体验", for: UIControlState())
        button.addTarget(self, action: #selector(startButtonClick), for: UIControlEvents.touchUpInside)
        return button
    }()
}
