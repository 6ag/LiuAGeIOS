//
//  JFHotKeyboardCell.swift
//  PCBWorldIOS
//
//  Created by 周剑峰 on 2017/2/25.
//  Copyright © 2017年 六阿哥. All rights reserved.
//

import UIKit

class JFHotKeyboardCell: UICollectionViewCell {
    
    var keyboardModel: JFSearchKeyboardModel? {
        didSet {
            contentLabel.text = keyboardModel?.keyboard
        }
    }
    
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
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(contentLabel)
    }
    
    // MARK: - 懒加载
    fileprivate lazy var contentLabel: UILabel = {
        let contentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.contentView.bounds.size.width, height: self.contentView.bounds.size.height))
        contentLabel.center = self.contentView.center
        contentLabel.textAlignment = NSTextAlignment.center
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.numberOfLines = 1
        contentLabel.adjustsFontSizeToFitWidth = true
        contentLabel.minimumScaleFactor = 0.1
        contentLabel.textColor = UIColor.colorWithRGB(101, g: 101, b: 101)
        contentLabel.layer.masksToBounds = true
        contentLabel.layer.cornerRadius = self.contentView.bounds.height * 0.5
        contentLabel.layer.borderColor = UIColor.colorWithRGB(211, g: 211, b: 211).cgColor;
        contentLabel.layer.borderWidth = 0.45
        return contentLabel
    }()
    
}
