//
//  JFNewsBigOnePicCell.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/14.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFNewsBigOnePicCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var befromLabel: UILabel!
    @IBOutlet weak var showNumLabel: UILabel!
    @IBOutlet weak var adIconView: UIImageView!
    @IBOutlet weak var mopicButton: UIButton!
    @IBOutlet weak var adIconWidthConst: NSLayoutConstraint!
    @IBOutlet weak var adIconRightMarginConst: NSLayoutConstraint!
    
    var postModel: JFArticleListModel? {
        didSet {
            
            guard let postModel = postModel else { return }
            // 大单图的图片不能拉伸，影响美观。所以先不重绘
            iconView.yy_setImage(with: URL(string: postModel.titlepic ?? "")!, placeholder: UIImage(named: "list_placeholder"))
            articleTitleLabel.text = postModel.title
            timeLabel.text = postModel.newstimeString
            befromLabel.text = postModel.befrom
            showNumLabel.text = postModel.onclick
            
            if postModel.morepic?.count ?? 0 > 3 {
                mopicButton.isHidden = false
                mopicButton.setTitle("\(postModel.morepic?.count ?? 0)图", for: .normal)
            } else {
                mopicButton.isHidden = true
            }
            
            if postModel.classid == JFAdManager.shared.classid {
                adIconView.isHidden = false
                adIconWidthConst.constant = 28
                adIconRightMarginConst.constant = 5
            } else {
                adIconView.isHidden = true
                adIconWidthConst.constant = 0
                adIconRightMarginConst.constant = 0
            }
            
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
