//
//  JFNewsThreePicCell.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/14.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFNewsThreePicCell: UITableViewCell {
    
    var postModel: JFArticleListModel? {
        didSet {
            
            if postModel!.titlepic!.hasSuffix("gif") {
                iconView1.image = UIImage(named: "list_placeholder")
                iconView1.yy_imageURL = NSURL(string: postModel!.morepic![0])
            } else {
                iconView1.yy_setImageWithURL(NSURL(string: postModel!.morepic![0]), placeholder: UIImage(named: "list_placeholder"), options: YYWebImageOptions.Progressive, completion: nil)
            }
            
            if postModel!.titlepic!.hasSuffix("gif") {
                iconView2.image = UIImage(named: "list_placeholder")
                iconView2.yy_imageURL = NSURL(string: postModel!.morepic![1])
            } else {
                iconView2.yy_setImageWithURL(NSURL(string: postModel!.morepic![1]), placeholder: UIImage(named: "list_placeholder"), options: YYWebImageOptions.Progressive, completion: nil)
            }
            
            if postModel!.titlepic!.hasSuffix("gif") {
                iconView3.image = UIImage(named: "list_placeholder")
                iconView3.yy_imageURL = NSURL(string: postModel!.morepic![2])
            } else {
                iconView3.yy_setImageWithURL(NSURL(string: postModel!.morepic![2]), placeholder: UIImage(named: "list_placeholder"), options: YYWebImageOptions.Progressive, completion: nil)
            }
            
            articleTitleLabel.text = postModel?.title!
            timeLabel.text = postModel?.newstimeString
            befromLabel.text = postModel?.befrom!
            showNumLabel.text = postModel?.onclick!
        }
    }
    
    @IBOutlet weak var iconView1: UIImageView!
    @IBOutlet weak var iconView2: UIImageView!
    @IBOutlet weak var iconView3: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var befromLabel: UILabel!
    @IBOutlet weak var showNumLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        articleTitleLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 30
    }
    
    /**
     计算行高
     */
    func getRowHeight(postModel: JFArticleListModel) -> CGFloat {
        self.postModel = postModel
        
        setNeedsLayout()
        layoutIfNeeded()
        
        // sizeclass布局后这里计算不准确，正在找更好的解决办法
        if iPhoneModel.getCurrentModel() == .iPad && CGRectGetMaxY(iconView1.frame) < 164 {
            return CGRectGetMaxY(timeLabel.frame) + 15 + 82
        } else {
            return CGRectGetMaxY(timeLabel.frame) + 15
        }
        
    }
}
