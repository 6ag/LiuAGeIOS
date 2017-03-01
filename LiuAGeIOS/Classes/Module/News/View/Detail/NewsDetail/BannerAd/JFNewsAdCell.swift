//
//  JFNewsAdCell.swift
//  PCBWorldIOS
//
//  Created by 周剑峰 on 2017/2/22.
//  Copyright © 2017年 六阿哥. All rights reserved.
//

import UIKit

class JFNewsAdCell: UITableViewCell {

    @IBOutlet weak var adImageView: UIImageView!
    @IBOutlet weak var adTitleLabel: UILabel!
    
    /// 新闻正文banner广告模型
    var bannerModel: JFArticleListModel? {
        didSet {
            guard let bannerModel = bannerModel else { return }
            adImageView.yy_setImage(with: URL(string: bannerModel.titlepic ?? ""), placeholder: UIImage(named: "temp_ad"))
            adTitleLabel.text = bannerModel.title
        }
    }
    
}
