//
//  JFProfileViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

protocol JFProfileViewControllerDelegate {
    func didTappedMyInfo()            // 资料
    func didTappedMyCollectionCell()  // 收藏
    func didTappedMyCommentCell()     // 评论、足记
    func didTappedSettingCell()       // 设置
    func didTappedFeedbackCell()      // 意见反馈
    func didTappedMyDutyCell()        // 关于六阿哥
    func didTappedScanWeixin()        // 扫描微信二维码
    func didTappedStar()              // 点赞 - 跳转到AppStore
    
}

class JFProfileViewController: JFBaseTableViewController {
    
    var profileDelegate: JFProfileViewControllerDelegate?
    
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
        
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .None
        tableView.backgroundColor = LEFT_BACKGROUND_COLOR
        tableView.frame = SCREEN_BOUNDS
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH * 0.55, height: 160))
        tableView.addSubview(headerView)
        UIApplication.sharedApplication().keyWindow?.insertSubview(tableView, belowSubview: mainVc.view)
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
        // 每次显示都更新数据
        updateHeaderData()
        tableView.reloadData()
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
        
        prepareData()
    }
    
    /**
     准备数据
     */
    private func prepareData() {
        
        // 第一组
        let group1CellModel1 = JFProfileCellModel(title: "我的收藏", icon: "profile_collection_icon")
        group1CellModel1.operation = { () -> Void in
            self.profileDelegate?.didTappedMyCollectionCell()
            self.viewDismiss()
        }
        let group1CellModel2 = JFProfileCellModel(title: "我的足迹", icon: "profile_comment_icon")
        group1CellModel2.operation = { () -> Void in
            self.profileDelegate?.didTappedMyCommentCell()
            self.viewDismiss()
        }
        let group1 = JFProfileCellGroupModel(cells: [group1CellModel1, group1CellModel2])
        
        // 第二组
        let group2CellModel1 = JFProfileCellModel(title: "清除缓存", icon: "profile_clean_icon")
        group2CellModel1.operation = { () -> Void in
            self.viewDismiss()
            JFProgressHUD.showWithStatus("正在清理")
            let cache = CGFloat((YYImageCache.sharedCache().diskCache.totalCost() + JFArticleStorage.getArticleImageCache().diskCache.totalCost())) / 1024.0 / 1024.0
            YYImageCache.sharedCache().diskCache.removeAllObjectsWithBlock({
                JFArticleStorage.getArticleImageCache().diskCache.removeAllObjectsWithBlock({
                    JFProgressHUD.showSuccessWithStatus("清除了\(String(format: "%.2f", cache))M缓存")
                })
            })
        }
        let group2CellModel2 = JFProfileCellModel(title: "夜间模式", icon: "profile_mode_daylight")
        group2CellModel2.operation = { () -> Void in
            print("夜间模式")
        }
        let group2 = JFProfileCellGroupModel(cells: [group2CellModel1, group2CellModel2])
        
        // 第三组
        let group3CellModel1 = JFProfileCellModel(title: "设置", icon: "profile_setting_icon")
        group3CellModel1.operation = { () -> Void in
            self.profileDelegate?.didTappedSettingCell()
            self.viewDismiss()
        }
        let group3CellModel2 = JFProfileCellModel(title: "意见反馈", icon: "profile_feedback_icon")
        group3CellModel2.operation = { () -> Void in
            self.profileDelegate?.didTappedFeedbackCell()
            self.viewDismiss()
        }
        let group3CellModel3 = JFProfileCellModel(title: "推荐给好友", icon: "profile_share_icon")
        group3CellModel3.operation = { () -> Void in
            self.shareToGoodFriend()
        }
        let group3CellModel4 = JFProfileCellModel(title: "关于六阿哥", icon: "profile_about_icon")
        group3CellModel4.operation = { () -> Void in
            self.profileDelegate?.didTappedMyDutyCell()
            self.viewDismiss()
        }
        let group3 = JFProfileCellGroupModel(cells: [group3CellModel1, group3CellModel2, group3CellModel3, group3CellModel4])
        
        groupModels = [group1, group2, group3]
        
        // 更新头部数据
        updateHeaderData()
    }
    
    /**
     分享给好友
     */
    private func shareToGoodFriend() {
        
        viewDismiss()
        // 宣传图
        var image = UIImage(named: "launchScreen")
        if image != nil && (image?.size.width > 300 || image?.size.height > 300) {
            image = image?.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image!.size.height / image!.size.width))
        }
        
        let shareParames = NSMutableDictionary()
        shareParames.SSDKSetupShareParamsByText("六阿哥网是国内最大的以奇闻异事探索为主题的网站之一，为广大探索爱好者提供丰富的探索资讯内容。进入app下载界面...",
                                                images : image,
                                                url : NSURL(string:"http://www.6ag.cn"), // app下载页面
                                                title : "六阿哥",
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! JFProfileCell
        cell.backgroundColor = LEFT_BACKGROUND_COLOR
        cell.selectionStyle = .None
        cell.textLabel?.textColor = UIColor.whiteColor()
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
            footerView.delegate = self
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
            if JFAccountModel.shareAccount()!.nickname == nil || JFAccountModel.shareAccount()!.nickname == "" {
                headerView.nameLabel.text = "点击设置昵称"
            } else {
                headerView.nameLabel.text = JFAccountModel.shareAccount()!.nickname!
            }
        } else {
            headerView.avatarButton.setBackgroundImage(UIImage(named: "default－portrait"), forState: UIControlState.Normal)
            headerView.nameLabel.text = "登录账号"
        }
    }
    
    lazy var headerView: JFProfileHeaderView = {
        let headerView = NSBundle.mainBundle().loadNibNamed("JFProfileHeaderView", owner: nil, options: nil).last as! JFProfileHeaderView
        headerView.delegate = self
        headerView.frame = CGRect(x: 0, y: -SCREEN_HEIGHT * 2 + 180, width: SCREEN_WIDTH * 0.55, height: SCREEN_HEIGHT * 2)
        return headerView
    }()
    
}

// MARK: - JFProfileHeaderViewDelegate
extension JFProfileViewController: JFProfileHeaderViewDelegate {
    
    /**
     头像按钮点击
     */
    func didTappedAvatarButton() {
        profileDelegate?.didTappedMyInfo()
        viewDismiss()
    }
    
}

// MARK: - JFProfileFooterViewDelegate
extension JFProfileViewController: JFProfileFooterViewDelegate {
    
    /**
     点击扫描微信二维码
     */
    func didTappedWxBgView() {
        profileDelegate?.didTappedScanWeixin()
    }
    
    /**
     点击点赞
     */
    func didTappedStarBgView() {
        profileDelegate?.didTappedStar()
    }
}
