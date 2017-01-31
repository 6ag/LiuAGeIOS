//
//  JFProfileFooterView.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/5.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import SnapKit

protocol JFProfileFooterViewDelegate {
    func didTappedWxBgView()
    func didTappedStarBgView()
}

class JFProfileFooterView: UIView {
    
    var delegate: JFProfileFooterViewDelegate?

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
        addSubview(wxBgView)
        wxBgView.addSubview(wxImageView)
        wxBgView.addSubview(wxLabel)
        addSubview(starBgView)
        starBgView.addSubview(starImageView)
        starBgView.addSubview(starLabel)
        
        wxBgView.snp_makeConstraints { (make) in
            make.left.top.bottom.equalTo(0)
            make.right.equalTo(starBgView.snp_left)
        }
        
        starBgView.snp_makeConstraints { (make) in
            make.top.right.bottom.equalTo(0)
            make.width.equalTo(wxBgView)
        }
        
        wxImageView.snp_makeConstraints { (make) in
            make.center.equalTo(wxBgView)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        wxLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(wxBgView)
            make.top.equalTo(wxImageView.snp_bottom).offset(10)
        }
        
        starImageView.snp_makeConstraints { (make) in
            make.center.equalTo(starBgView)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        starLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(starBgView)
            make.top.equalTo(starImageView.snp_bottom).offset(10)
        }
        
    }
    
    /**
     点击微信
     */
    func didTappedWxBgView(_ gesture: UITapGestureRecognizer) {
        delegate?.didTappedWxBgView()
    }
    
    /**
     点击点赞
     */
    func didTappedStarBgView(_ gesture: UITapGestureRecognizer) {
        delegate?.didTappedStarBgView()
    }
    
    // MARK: - 懒加载
    
    fileprivate lazy var wxBgView: UIView = {
        let wxBgView = UIView()
        wxBgView.backgroundColor = UIColor.clear
        wxBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedWxBgView(_:))))
        return wxBgView
    }()
    
    fileprivate lazy var starBgView: UIView = {
        let starBgView = UIView()
        starBgView.backgroundColor = UIColor.clear
        starBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedStarBgView(_:))))
        return starBgView
    }()
    
    fileprivate lazy var wxImageView: UIImageView = {
        let wxImageView = UIImageView(image: UIImage(named: "profile_footer_wx"))
        return wxImageView
    }()
    
    fileprivate lazy var wxLabel: UILabel = {
        let wxLabel = UILabel()
        wxLabel.text = "关注微信"
        wxLabel.font = UIFont.systemFont(ofSize: 14)
        wxLabel.textColor = UIColor.white
        return wxLabel
    }()
    
    fileprivate lazy var starImageView: UIImageView = {
        let starImageView = UIImageView(image: UIImage(named: "profile_footer_star"))
        return starImageView
    }()
    
    fileprivate lazy var starLabel: UILabel = {
        let starLabel = UILabel()
        starLabel.text = "点赞"
        starLabel.font = UIFont.systemFont(ofSize: 14)
        starLabel.textColor = UIColor.white
        return starLabel
    }()

}
