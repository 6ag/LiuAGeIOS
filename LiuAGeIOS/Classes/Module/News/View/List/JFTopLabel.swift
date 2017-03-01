//
//  JFTopLabel.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/1.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFTopLabel: UILabel {

    var scale : CGFloat? {
        didSet {
            guard let scale = scale else { return }
            // 通过scale的改变来改变各种参数 - 选中是橙色 - 未选中是黑色
            textColor = UIColor(red: 231/255.0 * scale, green: 129/255.0 * scale, blue: 112/255.0 * scale, alpha: 1)
            let minScale : CGFloat = 0.9
            let trueScale = minScale + (1 - minScale) * scale
            transform = CGAffineTransform(scaleX: trueScale, y: trueScale)
        }
    }
    
    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = NSTextAlignment.center
        font = UIFont.systemFont(ofSize: 18.0)
    }
    
}
