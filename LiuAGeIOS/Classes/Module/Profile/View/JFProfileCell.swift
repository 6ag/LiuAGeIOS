//
//  JFProfileCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/5.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import pop

class JFProfileCell: UITableViewCell {
    
    /// cell模型
    var cellModel: JFProfileCellModel? {
        didSet {
            
            // 左边数据
            textLabel?.text = cellModel!.title
            detailTextLabel?.text = cellModel!.subTitle
            
            if cellModel?.icon != nil {
                imageView?.image = UIImage(named: cellModel!.icon!)
            } else {
                imageView?.image = nil
            }
            
            // 右边数据
            selectionStyle = cellModel!.isKind(of: JFProfileCellArrowModel.self) ? .default : .none
            if cellModel!.isKind(of: JFProfileCellArrowModel.self) {
                accessoryView = settingArrowView
            } else if cellModel!.isKind(of: JFProfileCellSwitchModel.self) {
                if cellModel!.title == "推送开关" {
                    settingSwitchView.isOn = UserDefaults.standard.bool(forKey: PUSH_KEY)
                }
                accessoryView = settingSwitchView
            } else if cellModel!.isKind(of: JFProfileCellLabelModel.self) {
                let settingCellLabel = cellModel as! JFProfileCellLabelModel
                settingRightLabel.text = settingCellLabel.text
                accessoryView = settingRightLabel
            }
            
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 准备视图
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if self.isHighlighted {
            let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
            scaleAnimation?.duration = 0.1
            scaleAnimation?.toValue = NSValue(cgPoint: CGPoint(x: 1.5, y: 1.5))
            imageView?.pop_add(scaleAnimation, forKey: "scalingUp")
        } else {
            let sprintAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            sprintAnimation?.toValue = NSValue(cgPoint: CGPoint(x: 0.9, y: 0.9))
            sprintAnimation?.velocity = NSValue(cgPoint: CGPoint(x: 2, y: 2))
            sprintAnimation?.springBounciness = 20
            imageView?.pop_add(sprintAnimation, forKey: "springAnimation")
        }
    }
    
    fileprivate func prepareUI() {
        
        textLabel?.font = UIFont.systemFont(ofSize: 14)
        textLabel?.textColor = UIColor.black
        
        detailTextLabel?.font = UIFont.systemFont(ofSize: 11)
        detailTextLabel?.textColor = UIColor.black
    }
    
    @objc fileprivate func didChangedSwitch(_ settingSwitch: UISwitch) {
        
        if cellModel!.title == "推送开关" {
            // 修改本地存储的状态
            UserDefaults.standard.set(settingSwitch.isOn, forKey: PUSH_KEY)
        }
    }
    
    // MARK: - 懒加载
    lazy var settingRightLabel: UILabel = {
        let settingRightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        settingRightLabel.textColor = UIColor.gray
        settingRightLabel.textAlignment = .right
        settingRightLabel.font = UIFont.systemFont(ofSize: 14)
        return settingRightLabel
    }()
    
    lazy var settingArrowView: UIImageView = {
        let settingArrowView = UIImageView(image: UIImage(named: "setting_arrow_icon"))
        return settingArrowView
    }()
    
    lazy var settingSwitchView: UISwitch = {
        let settingSwitchView = UISwitch()
        settingSwitchView.addTarget(self, action: #selector(didChangedSwitch(_:)), for: .valueChanged)
        return settingSwitchView
    }()

}
