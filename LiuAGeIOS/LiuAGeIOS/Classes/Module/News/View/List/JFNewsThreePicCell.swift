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
            iconView1.yy_setImageWithURL(NSURL(string: postModel!.morepic![0]), placeholder: UIImage(named: "placeholder_logo"))
            iconView2.yy_setImageWithURL(NSURL(string: postModel!.morepic![1]), placeholder: UIImage(named: "placeholder_logo"))
            iconView3.yy_setImageWithURL(NSURL(string: postModel!.morepic![2]), placeholder: UIImage(named: "placeholder_logo"))
            
            articleTitleLabel.text = postModel?.title!
            timeLabel.text = postModel?.newstime!.timeStampToString()
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
        return CGRectGetMaxY(timeLabel.frame) + 15
    }
}
