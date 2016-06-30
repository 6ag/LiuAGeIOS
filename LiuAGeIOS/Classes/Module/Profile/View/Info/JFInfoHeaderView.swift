//
//  JFInfoHeaderView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage
import SnapKit

class JFInfoHeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        backgroundColor = UIColor.whiteColor()
        addSubview(avatarImageView)
        addSubview(usernameLabel)
        addSubview(levelLabel)
        addSubview(pointsView)
        addSubview(topLineView)
        addSubview(bottomLineView)
        
        avatarImageView.snp_makeConstraints { (make) in
            make.left.equalTo(MARGIN)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        usernameLabel.snp_makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp_right).offset(20)
            make.top.equalTo(avatarImageView).offset(2)
        }
        
        levelLabel.snp_makeConstraints { (make) in
            make.left.equalTo(usernameLabel)
            make.bottom.equalTo(avatarImageView).offset(-2)
        }
        
        pointsView.snp_makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(-MARGIN)
            make.size.equalTo(CGSize(width: 70, height: 20))
        }
        
        topLineView.snp_makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        bottomLineView.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        avatarImageView.yy_setImageWithURL(NSURL(string: JFAccountModel.shareAccount()!.avatarUrl!), options: YYWebImageOptions.AllowBackgroundTask)
        usernameLabel.text = JFAccountModel.shareAccount()!.username!
        levelLabel.text = "等级：\(JFAccountModel.shareAccount()!.groupName!)"
        pointsView.setTitle("积分 : \(JFAccountModel.shareAccount()!.points!)", forState: UIControlState.Normal)
    }
    
    // MARK: - 懒加载
    private lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.layer.masksToBounds = true
        return avatarImageView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        return usernameLabel
    }()
    
    private lazy var levelLabel: UILabel = {
        let levelLabel = UILabel()
        levelLabel.font = UIFont.systemFontOfSize(13)
        levelLabel.textColor = UIColor.grayColor()
        return levelLabel
    }()
    
    private lazy var pointsView: UIButton = {
        let pointsView = UIButton(type: .Custom)
        pointsView.setImage(UIImage(named: "profile_point_icon"), forState: UIControlState.Normal)
        pointsView.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        pointsView.setTitleColor(NAVIGATIONBAR_COLOR_DARK, forState: UIControlState.Normal)
        pointsView.titleLabel?.font = UIFont.systemFontOfSize(12)
        pointsView.layer.cornerRadius = 4
        pointsView.layer.borderColor = NAVIGATIONBAR_COLOR_DARK.CGColor
        pointsView.layer.borderWidth = 0.8
        pointsView.enabled = false
        return pointsView
    }()
    
    private lazy var topLineView: UIView = {
        let topLineView = UIView()
        topLineView.backgroundColor = SETTING_SEPARATOR_COLOR
        return topLineView
    }()
    
    private lazy var bottomLineView: UIView = {
        let bottomLineView = UIView()
        bottomLineView.backgroundColor = SETTING_SEPARATOR_COLOR
        return bottomLineView
    }()
}
