//
//  JFProfileViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFProfileViewController: JFBaseTableViewController {
    
    /// 主控制器
    weak var mainVc: UIViewController?
    
    /// 主控制器侧滑后的宽度
    let mainVcViewWidth = SCREEN_WIDTH * 0.45
    
    /// 主控制器侧滑后添加的遮罩视图
    lazy var rightShadowView: UIView = {
        let rightShadowView = UIView(frame: SCREEN_BOUNDS)
        rightShadowView.backgroundColor = UIColor(white: 0, alpha: 0.01)
        rightShadowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedRightShadowView(_:))))
        rightShadowView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPanRightShadowView(_:))))
        return rightShadowView
    }()
    
    // MARK: - 初始化侧边栏控制器
    init(mainVc: UIViewController) {
        super.init(style: UITableViewStyle.Grouped)
        self.mainVc = mainVc
        view.backgroundColor = LEFT_BACKGROUND_COLOR
        view.frame = SCREEN_BOUNDS
        UIApplication.sharedApplication().keyWindow?.insertSubview(view, belowSubview: mainVc.view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     点击遮罩手势
     */
    @objc private func didTappedRightShadowView(tap: UIGestureRecognizer) {
        viewDismiss()
    }
    
    /**
     滑动遮罩手势
     */
    @objc private func didPanRightShadowView(gesture: UIPanGestureRecognizer) {
        
        let currentPoint = gesture.translationInView(view)
        if gesture.state == .Changed {
            if currentPoint.x > -SCREEN_WIDTH * 0.55 && currentPoint.x < 0 {
                self.mainVc?.view.transform = CGAffineTransformMakeTranslation(SCREEN_WIDTH - self.mainVcViewWidth + currentPoint.x, 0)
            }
        } else if gesture.state == .Ended {
            if self.mainVc?.view.transform.tx < SCREEN_WIDTH * 0.45 {
                viewDismiss()
            } else {
                viewShow()
            }
        }
    }
    
    /**
     视图显示
     */
    func viewShow() {
        
        UIView.animateWithDuration(0.25, animations: {
            self.mainVc?.view.transform = CGAffineTransformMakeTranslation(SCREEN_WIDTH - self.mainVcViewWidth, 0)
        }) { (_) in
            self.mainVc?.view.addSubview(self.rightShadowView)
        }
    }
    
    /**
     视图隐藏
     */
    func viewDismiss() {
        
        UIView.animateWithDuration(0.25, animations: {
            self.mainVc?.view.transform = CGAffineTransformIdentity
        }) { (_) in
            self.rightShadowView.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .None
        tableView.addSubview(headerView)
        // 这个是用来占位的
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH * 0.55, height: 160))
        tableView.tableHeaderView = tableHeaderView
        prepareData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateHeaderData()
        tableView.reloadData()
    }
    
    /**
     准备数据
     */
    private func prepareData() {
        let group1CellModel1 = JFProfileCellArrowModel(title: "我的收藏", icon: "profile_collection_icon")
        group1CellModel1.operation = { () -> Void in
            print("我的收藏")
        }
        let group1CellModel2 = JFProfileCellArrowModel(title: "我的足迹", icon: "profile_comment_icon")
        group1CellModel2.operation = { () -> Void in
            print("我的足迹")
        }
        let group1 = JFProfileCellGroupModel(cells: [group1CellModel1, group1CellModel2])
        
        
        let group2CellModel1 = JFProfileCellLabelModel(title: "清除缓存", icon: "profile_clean_icon", text: "0.0M")
        group2CellModel1.operation = { () -> Void in
            JFProgressHUD.showWithStatus("正在清理")
            YYImageCache.sharedCache().diskCache.removeAllObjectsWithBlock({
                JFProgressHUD.showSuccessWithStatus("清理成功")
                group2CellModel1.text = "0.00M"
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            })
        }
        let group2CellModel2 = JFProfileCellArrowModel(title: "夜间模式", icon: "profile_mode_daylight")
        group2CellModel2.operation = { () -> Void in
            
        }
        let group2 = JFProfileCellGroupModel(cells: [group2CellModel1, group2CellModel2])
        
        let group3CellModel1 = JFProfileCellArrowModel(title: "设置", icon: "profile_setting_icon", destinationVc: JFProfileFeedbackViewController.classForCoder())
        let group3CellModel2 = JFProfileCellArrowModel(title: "意见反馈", icon: "profile_feedback_icon", destinationVc: JFProfileFeedbackViewController.classForCoder())
        let group3CellModel3 = JFProfileCellArrowModel(title: "推荐给好友", icon: "profile_share_icon")
        group3CellModel3.operation = { () -> Void in
            var image = UIImage(named: "launchScreen")
            if image != nil && (image?.size.width > 300 || image?.size.height > 300) {
                image = image?.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image!.size.height / image!.size.width))
            }
            
            let shareParames = NSMutableDictionary()
            shareParames.SSDKSetupShareParamsByText("爆侃网文精心打造网络文学互动平台，专注最新文学市场动态，聚焦第一手网文圈资讯！",
                                                    images : image,
                                                    url : NSURL(string:"https://itunes.apple.com/cn/app/id\(APPLE_ID)"),
                                                    title : "爆侃网文",
                                                    type : SSDKContentType.Auto)
            
            let items = [
                SSDKPlatformType.TypeQQ.rawValue,
                SSDKPlatformType.TypeWechat.rawValue,
                SSDKPlatformType.TypeSinaWeibo.rawValue
            ]
            
            ShareSDK.showShareActionSheet(nil, items: items, shareParams: shareParames) { (state : SSDKResponseState, platform: SSDKPlatformType, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!, end: Bool) in
                switch state {
                    
                case SSDKResponseState.Success:
                    print("分享成功")
                case SSDKResponseState.Fail:
                    print("分享失败,错误描述:\(error)")
                case SSDKResponseState.Cancel:
                    print("取消分享")
                default:
                    break
                }
            }
        }
        let group3CellModel4 = JFProfileCellArrowModel(title: "关于六阿哥", icon: "profile_about_icon", destinationVc: JFDutyViewController.classForCoder())
        let group3 = JFProfileCellGroupModel(cells: [group3CellModel1, group3CellModel2, group3CellModel3, group3CellModel4])
        
        groupModels = [group1, group2, group3]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! JFProfileCell
        cell.backgroundColor = LEFT_BACKGROUND_COLOR
        cell.textLabel?.textColor = UIColor.whiteColor()
        // 更新缓存数据
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.settingRightLabel.text = "\(String(format: "%.2f", CGFloat(YYImageCache.sharedCache().diskCache.totalCost()) / 1024 / 1024))M"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let contentView = UIView()
        if section == 0 || section == 1 {
            // 分割线
            let lineView = UIView(frame: CGRect(x: 15, y: 0, width: SCREEN_WIDTH * 0.55 - 30, height: 0.5))
            lineView.backgroundColor = UIColor(white: 1, alpha: 0.3)
            contentView.addSubview(lineView)
        } else if section == 2 {
            // 底部视图
            let footerView = JFProfileFooterView(frame: CGRect(x: 15, y: 0, width: SCREEN_WIDTH * 0.55 - 30, height: 80))
            contentView.addSubview(footerView)
        }
        return contentView
    }
    
    /**
     更新头部数据
     */
    private func updateHeaderData() {
        if JFAccountModel.isLogin() {
            headerView.avatarButton.yy_setBackgroundImageWithURL(NSURL(string: JFAccountModel.shareAccount()!.avatarUrl!), forState: UIControlState.Normal, options: YYWebImageOptions.AllowBackgroundTask)
            headerView.nameLabel.text = JFAccountModel.shareAccount()!.username
        } else {
            headerView.avatarButton.setBackgroundImage(UIImage(named: "default－portrait"), forState: UIControlState.Normal)
            headerView.nameLabel.text = "登录账号"
        }
    }
    
    lazy var headerView: JFProfileHeaderView = {
        let headerView = NSBundle.mainBundle().loadNibNamed("JFProfileHeaderView", owner: nil, options: nil).last as! JFProfileHeaderView
        headerView.delegate = self
        headerView.frame = CGRect(x: 0, y: -SCREEN_HEIGHT * 2 + 150, width: SCREEN_WIDTH * 0.55, height: SCREEN_HEIGHT * 2)
        return headerView
    }()
    
}

// MARK: - JFProfileHeaderViewDelegate
extension JFProfileViewController: JFProfileHeaderViewDelegate {
    
    /**
     头像按钮点击
     */
    func didTappedAvatarButton() {
        if JFAccountModel.isLogin() {
            // 还没有修改头像的接口，这里进个人资料里
            navigationController?.pushViewController(JFEditProfileViewController(style: UITableViewStyle.Grouped), animated: true)
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     收藏列表
     */
    func didTappedCollectionButton() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFCollectionTableViewController(style: UITableViewStyle.Plain), animated: true)
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     评论列表
     */
    func didTappedCommentButton() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFCommentListTableViewController(style: UITableViewStyle.Plain), animated: true)
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
}

extension JFProfileViewController: JFSetFontViewDelegate {
    func didChangeFontSize() {
        print("改变了字体大小")
    }
}
