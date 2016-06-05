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
            startButton.hidden = true
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
        startButton.hidden = false
        // 把按钮的 transform 缩放设置为0
        startButton.transform = CGAffineTransformMakeScale(0, 0)
        UIView.animateWithDuration(1, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            self.startButton.transform = CGAffineTransformIdentity
        }) { (_) -> Void in
            
        }
    }
    
    // MARK: - 准备UI
    private func prepareUI() {
        // 添加子控件
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(startButton)
        
        // 添加约束
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        
        startButton.snp_makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(-100)
            make.size.equalTo(CGSize(width: 140, height: 40))
        }
    }
    
    /**
     开始按钮点击
     */
    func startButtonClick() {
        UIApplication.sharedApplication().keyWindow?.rootViewController = UIStoryboard.init(name: "JFNewsViewController", bundle: nil).instantiateInitialViewController()
    }
    
    // MARK: - 懒加载
    /// 背景
    private lazy var backgroundImageView = UIImageView()
    
    /// 开始体验按钮
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.setBackgroundImage(UIImage(named: "new_feature_finish_button"), forState: UIControlState.Normal)
        button.setBackgroundImage(UIImage(named: "new_feature_finish_button_highlighted"), forState: UIControlState.Highlighted)
        button.setTitle("开始体验", forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(JFNewFeatureCell.startButtonClick), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
}