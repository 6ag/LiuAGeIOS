//
//  JFProfileViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

protocol JFProfileViewControllerDelegate {
    func didTappedMyInfo()            // 资料
    func didTappedMyCollectionCell()  // 收藏
    func didTappedMyCommentCell()     // 评论、足记
    func didTappedCleanCache()        // 清理缓存
    func didTappedFeedbackCell()      // 意见反馈
    func didTappedMyDutyCell()        // 关于六阿哥
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
        super.init(style: UITableViewStyle.grouped)
        self.mainVc = mainVc
        
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = LEFT_BACKGROUND_COLOR
        tableView.frame = SCREEN_BOUNDS
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH * 0.55, height: 160))
        tableView.addSubview(headerView)
        UIApplication.shared.keyWindow?.insertSubview(tableView, belowSubview: mainVc.view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     点击遮罩手势
     */
    @objc fileprivate func didTappedRightShadowView(_ tap: UIGestureRecognizer) {
        viewDismiss()
    }
    
    /**
     滑动遮罩手势
     */
    @objc fileprivate func didPanRightShadowView(_ gesture: UIPanGestureRecognizer) {
        
        let currentPoint = gesture.translation(in: view)
        if gesture.state == .changed {
            if currentPoint.x > -SCREEN_WIDTH * 0.55 && currentPoint.x < 0 {
                self.mainVc?.view.transform = CGAffineTransform(translationX: SCREEN_WIDTH - self.mainVcViewWidth + currentPoint.x, y: 0)
            }
        } else if gesture.state == .ended {
            if self.mainVc?.view.transform.tx ?? 0 < SCREEN_WIDTH * 0.45 {
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
        
        view.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.25, animations: {
            self.mainVc?.view.transform = CGAffineTransform(translationX: SCREEN_WIDTH - self.mainVcViewWidth, y: 0)
        }, completion: { (_) in
            self.mainVc?.view.addSubview(self.rightShadowView)
        }) 
    }
    
    /**
     视图隐藏
     */
    func viewDismiss() {
        
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            self.mainVc?.view.transform = CGAffineTransform.identity
        }, completion: { (_) in
            self.rightShadowView.removeFromSuperview()
        }) 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareData()
    }
    
    /**
     准备数据
     */
    fileprivate func prepareData() {
        
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
            self.profileDelegate?.didTappedCleanCache()
            self.viewDismiss()
        }
        let group2CellModel2 = JFProfileCellModel(title: "夜间模式", icon: "profile_mode_daylight")
        group2CellModel2.operation = { () -> Void in
            log("夜间模式")
            self.viewDismiss()
        }
        let group2 = JFProfileCellGroupModel(cells: [group2CellModel1, group2CellModel2])
        
        // 第三组
        let group3CellModel1 = JFProfileCellModel(title: "意见反馈", icon: "profile_feedback_icon")
        group3CellModel1.operation = { () -> Void in
            self.profileDelegate?.didTappedFeedbackCell()
            self.viewDismiss()
        }
        let group3CellModel2 = JFProfileCellModel(title: "推荐给好友", icon: "profile_share_icon")
        group3CellModel2.operation = { () -> Void in
            self.shareToGoodFriend()
        }
        let group3CellModel3 = JFProfileCellModel(title: "关于我们", icon: "profile_about_icon")
        group3CellModel3.operation = { () -> Void in
            self.profileDelegate?.didTappedMyDutyCell()
            self.viewDismiss()
        }
        let group3 = JFProfileCellGroupModel(cells: [group3CellModel1, group3CellModel2, group3CellModel3])
        
        groupModels = [group1, group2, group3]
        
        // 更新头部数据
        updateHeaderData()
    }
    
    /**
     分享给好友
     */
    fileprivate func shareToGoodFriend() {
        
        viewDismiss()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.shareToFriend()
        }
        
    }
    
    /**
     分享给朋友
     */
    fileprivate func shareToFriend() {
        
        if JFShareItemModel.loadShareItems().count == 0 {
            JFProgressHUD.showInfoWithStatus("没有可分享内容")
            return
        }
        
        shareView.showShareView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! JFProfileCell
        cell.backgroundColor = LEFT_BACKGROUND_COLOR
        cell.selectionStyle = .none
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 80
        }
        return 5
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let contentView = UIView()
        if section == 0 || section == 1 {
            // 分割线
            let lineView = UIView(frame: CGRect(x: 15, y: 0, width: SCREEN_WIDTH * 0.55 - 30, height: 0.5))
            lineView.backgroundColor = UIColor(white: 1, alpha: 0.3)
            contentView.addSubview(lineView)
        }
        return contentView
    }
    
    /**
     更新头部数据
     */
    fileprivate func updateHeaderData() {
        
        if JFAccountModel.isLogin() {
            headerView.avatarButton.yy_setBackgroundImage(with: URL(string: JFAccountModel.shareAccount()?.avatarUrl ?? ""), for: .normal, options: .allowBackgroundTask)
            if JFAccountModel.shareAccount()?.nickname == nil || JFAccountModel.shareAccount()?.nickname == "" {
                headerView.nameLabel.text = "点击设置昵称"
            } else {
                headerView.nameLabel.text = JFAccountModel.shareAccount()?.nickname
            }
        } else {
            headerView.avatarButton.setBackgroundImage(UIImage(named: "default－portrait"), for: .normal)
            headerView.nameLabel.text = "登录账号"
        }
    }
    
    lazy var headerView: JFProfileHeaderView = {
        let headerView = Bundle.main.loadNibNamed("JFProfileHeaderView", owner: nil, options: nil)?.last as! JFProfileHeaderView
        headerView.delegate = self
        headerView.frame = CGRect(x: 0, y: -SCREEN_HEIGHT * 2 + 150, width: SCREEN_WIDTH * 0.55, height: SCREEN_HEIGHT * 2)
        return headerView
    }()
    
    /// 分享视图
    fileprivate lazy var shareView: JFShareView = {
        let shareView = JFShareView()
        shareView.delegate = self
        return shareView
    }()
    
}

// MARK: - JFShareViewDelegate
extension JFProfileViewController: JFShareViewDelegate {
    
    func share(type: JFShareType) {
        
        let platformType: SSDKPlatformType!
        switch type {
        case .qqFriend:
            platformType = SSDKPlatformType.subTypeQZone // 尼玛，这竟然是反的。。ShareSDK bug
        case .qqQzone:
            platformType = SSDKPlatformType.subTypeQQFriend // 尼玛，这竟然是反的。。
        case .weixinFriend:
            platformType = SSDKPlatformType.subTypeWechatSession
        case .friendCircle:
            platformType = SSDKPlatformType.subTypeWechatTimeline
        case .sina:
            platformType = SSDKPlatformType.typeSinaWeibo
        }
        
        // 宣传图
        var image = UIImage(named: "app_icon")
        if image != nil && (image?.size.width ?? 0 > CGFloat(300) || image?.size.height ?? 0 > CGFloat(300)) {
            image = image?.resizeImageWithNewSize(CGSize(width: 300, height: 300 * image!.size.height / image!.size.width))
        }
        
        let shareParames = NSMutableDictionary()
        shareParames.ssdkSetupShareParams(byText: "六阿哥网是国内最大的以奇闻异事探索为主题的网站之一，为广大探索爱好者提供丰富的探索资讯内容。进入app下载界面...",
                                          images : image,
                                          url : URL(string:"https://www.6ag.cn"),
                                          title : "六阿哥",
                                          type : SSDKContentType.auto)
        
        ShareSDK.share(platformType, parameters: shareParames) { (state, _, entity, error) in
            switch state {
            case SSDKResponseState.success:
                log("分享成功")
            case SSDKResponseState.fail:
                log("授权失败,错误描述:\(error)")
            case SSDKResponseState.cancel:
                log("操作取消")
            default:
                break
            }
        }
        
    }
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
