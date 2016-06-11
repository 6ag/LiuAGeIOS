//
//  JFCommentCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/18.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage
import pop

protocol JFCommentCellDelegate {
    func didTappedStarButton(button: UIButton, commentModel: JFCommentModel)
}

class JFCommentCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    var delegate: JFCommentCellDelegate?
    
    var commentModel: JFCommentModel? {
        didSet {
            avatarImageView.yy_setImageWithURL(NSURL(string: commentModel!.userpic!), placeholder: UIImage(named: "default－portrait"))
            usernameLabel.text = commentModel!.plnickname == "" ? commentModel!.plusername! : commentModel!.plnickname!
            timeLabel.text = commentModel!.saytime!
            contentLabel.text = commentModel!.saytext!
            starButton.setTitle("\(commentModel!.zcnum)", forState: UIControlState.Normal)
        }
    }
    
    func getCellHeight(commentModel: JFCommentModel) -> CGFloat {
        self.commentModel = commentModel
        layoutIfNeeded()
        return CGRectGetMaxY(contentLabel.frame) + 10
    }
    
    /**
     点击了赞
     */
    @IBAction func didTappedStarButton(sender: UIButton) {
        setupAnimation(sender)
        delegate?.didTappedStarButton(sender, commentModel: commentModel!)
    }
    
    private func setupAnimation(button: UIButton) {
        let sprintAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        sprintAnimation.fromValue = NSValue(CGPoint: CGPoint(x: 0.8, y: 0.8))
        sprintAnimation.toValue = NSValue(CGPoint: CGPoint(x: 1, y: 1))
        sprintAnimation.velocity = NSValue(CGPoint: CGPoint(x: 40, y: 40))
        sprintAnimation.springBounciness = 20
        button.pop_addAnimation(sprintAnimation, forKey: "springAnimation")
    }
    
}
