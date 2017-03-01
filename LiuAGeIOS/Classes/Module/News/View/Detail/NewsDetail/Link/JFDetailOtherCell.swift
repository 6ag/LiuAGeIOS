//
//  JFDetailOtherCell.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/24.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFDetailOtherCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var befromLabel: UILabel!
    @IBOutlet weak var showNumLabel: UILabel!
    @IBOutlet weak var adIconView: UIImageView!
    @IBOutlet weak var adIconWidthConst: NSLayoutConstraint!
    @IBOutlet weak var adIconRightMarginConst: NSLayoutConstraint!
    
    var model: JFOtherLinkModel? {
        didSet {
            guard let model = model else { return }
            iconImageView.yy_setImage(with: URL(string: model.titlepic ?? ""), placeholder: UIImage(named: "list_placeholder"))
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
}
