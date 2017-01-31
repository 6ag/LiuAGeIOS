//
//  JFNewsOnePicCell.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/14.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFNewsOnePicCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var befromLabel: UILabel!
    @IBOutlet weak var showNumLabel: UILabel!
    @IBOutlet weak var smalltextLabel: UILabel!
    
    var postModel: JFArticleListModel? {
        didSet {
            
            guard let postModel = postModel else { return }
            iconView.image = nil
            iconView.setImage(urlString: postModel.titlepic ?? "", placeholderImage: UIImage(named: "list_placeholder"))
            
            articleTitleLabel.text = postModel.title
            timeLabel.text = postModel.newstimeString
            befromLabel.text = postModel.befrom
            showNumLabel.text = postModel.onclick
            
            if iPhoneModel.getCurrentModel() == .iPad {
                smalltextLabel.isHidden = false
                smalltextLabel.text = postModel.smalltext
            } else {
                smalltextLabel.isHidden = true
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if iPhoneModel.getCurrentModel() == .iPad {
            articleTitleLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 221
            smalltextLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 221
        } else {
            // 133 = 15(间隔) * 3(间隔数) + 88(图片宽度)
            articleTitleLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 133
        }
        
    }
    
    /**
     计算行高 - 暂时这个cell高度是固定的，所以这个方法不用
     */
    func getRowHeight(_ postModel: JFArticleListModel) -> CGFloat {
        self.postModel = postModel
        setNeedsLayout()
        layoutIfNeeded()
        
        return timeLabel.frame.maxY + 15
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 离屏渲染 - 异步绘制
        layer.drawsAsynchronously = true
        
        // 栅格化 - 异步绘制之后，会生成一张独立的图像，cell在屏幕上滚动的时候，本质滚动的是这张图片
        layer.shouldRasterize = true
        
        // 使用栅格化，需要指定分辨率
        layer.rasterizationScale = UIScreen.main.scale
    }
    
}
