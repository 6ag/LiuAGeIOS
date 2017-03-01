//
//  JFDetailOtherCell.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/24.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFDetailOtherNoneCell: UITableViewCell {
    
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var befromLabel: UILabel!
    @IBOutlet weak var showNumLabel: UILabel!
    @IBOutlet weak var adIconView: UIImageView!
    @IBOutlet weak var adIconWidthConst: NSLayoutConstraint!
    @IBOutlet weak var adIconRightMarginConst: NSLayoutConstraint!
    
    var model: JFOtherLinkModel? {
        didSet {
            guard let model = model else { return }
            articleTitleLabel.text = model.title
            befromLabel.text = model.classname
            showNumLabel.text = model.onclick
            
            if model.classid == JFAdManager.shared.classid {
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
     计算行高
     */
    func getRowHeight(_ model: JFOtherLinkModel) -> CGFloat {
        self.model = model
        layoutIfNeeded()
        return showNumLabel.frame.maxY + 15
    }
    
    
}
