//
//  JFInfoHeaderView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
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
    fileprivate func prepareUI() {
        backgroundColor = UIColor.white
        addSubview(avatarImageView)
        addSubview(usernameLabel)
        addSubview(levelLabel)
        addSubview(pointsView)
        addSubview(topLineView)
        addSubview(bottomLineView)
        
        avatarImageView.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp.right).offset(20)
            make.top.equalTo(avatarImageView).offset(2)
        }
        
        levelLabel.snp.makeConstraints { (make) in
            make.left.equalTo(usernameLabel)
            make.bottom.equalTo(avatarImageView).offset(-2)
        }
        
        pointsView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(-MARGIN)
            make.size.equalTo(CGSize(width: 70, height: 20))
        }
        
        topLineView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        bottomLineView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        avatarImageView.yy_setImage(with: URL(string: JFAccountModel.shareAccount()!.avatarUrl!), options: YYWebImageOptions.allowBackgroundTask)
        usernameLabel.text = JFAccountModel.shareAccount()!.username!
        levelLabel.text = "等级：\(JFAccountModel.shareAccount()!.groupName!)"
        pointsView.setTitle("积分 : \(JFAccountModel.shareAccount()!.points!)", for: UIControlState())
    }
    
    // MARK: - 懒加载
    fileprivate lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.layer.masksToBounds = true
        return avatarImageView
    }()
    
    fileprivate lazy var usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        return usernameLabel
    }()
    
    fileprivate lazy var levelLabel: UILabel = {
        let levelLabel = UILabel()
        levelLabel.font = UIFont.systemFont(ofSize: 13)
        levelLabel.textColor = UIColor.gray
        return levelLabel
    }()
    
    fileprivate lazy var pointsView: UIButton = {
        let pointsView = UIButton(type: .custom)
        pointsView.setImage(UIImage(named: "profile_point_icon"), for: UIControlState())
        pointsView.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        pointsView.setTitleColor(ACCENT_COLOR, for: UIControlState())
        pointsView.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        pointsView.layer.cornerRadius = 4
        pointsView.layer.borderColor = ACCENT_COLOR.cgColor
        pointsView.layer.borderWidth = 0.8
        pointsView.isEnabled = false
        return pointsView
    }()
    
    fileprivate lazy var topLineView: UIView = {
        let topLineView = UIView()
        topLineView.backgroundColor = SETTING_SEPARATOR_COLOR
        return topLineView
    }()
    
    fileprivate lazy var bottomLineView: UIView = {
        let bottomLineView = UIView()
        bottomLineView.backgroundColor = SETTING_SEPARATOR_COLOR
        return bottomLineView
    }()
}
