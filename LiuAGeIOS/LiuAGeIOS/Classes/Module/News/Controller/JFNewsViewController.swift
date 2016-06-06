//
//  JFNewsViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import SnapKit

class JFNewsViewController: UIViewController {
    
    // MARK: - 各种属性
    /// 顶部标签scrollView
    @IBOutlet weak var topScrollView: UIScrollView!
    /// 内容区域scrollView
    @IBOutlet weak var contentScrollView: UIScrollView!
    /// 顶部标签scrollView旁的箭头按钮
    @IBOutlet weak var arrowButton: UIButton!
    /// 内容区域scrollView x轴偏移量
    var contentOffsetX: CGFloat = 0.0
    
    /// 栏目管理控制器
    private lazy var editColumnVc: JFEditColumnViewController = {
        let editColumnVc = JFEditColumnViewController()
        editColumnVc.transitioningDelegate = self
        editColumnVc.modalPresentationStyle = .Custom
        return editColumnVc
    }()
    
    // 栏目数组
    private var selectedArray: [[String : String]]?
    private var optionalArray: [[String : String]]?
    
    /// 侧边栏控制器
    var profileVc: JFProfileViewController!
    
    /// 侧滑手势 - 打开侧边栏
    lazy var onePagePanGesture: JFPanGestureRecognizer = {
        let onePagePanGesture = JFPanGestureRecognizer(target: self, action: #selector(didPanOnePageView(_:)))
        onePagePanGesture.delegate = self
        return onePagePanGesture
    }()
    
    // MARK: - 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 准备视图
        prepareUI()
        
        // 配置侧边栏
        setupprofileVc()
        
        // 配置JPUSH
        (UIApplication.sharedApplication().delegate as! AppDelegate).setupJPush()
        // 注册接收推送通知的通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveRemoteNotificationOfJPush(_:)), name: "didReceiveRemoteNotificationOfJPush", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(columnViewWillDismiss(_:)), name: "columnViewWillDismiss", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - 各种自定义方法
    /**
     处理接收到的远程通知，跳转到指定的文章
     */
    func didReceiveRemoteNotificationOfJPush(notification: NSNotification) {
        
        if let userInfo = notification.object as? NSDictionary {
            guard let classid = userInfo["classid"], let id = userInfo["id"] else {return}
            let detailVc = JFNewsDetailViewController()
            detailVc.articleParam = (classid as! String,id as! String)
            navigationController?.pushViewController(detailVc, animated: true)
        }
    }
    
    /**
     栏目管理控制器即将消失
     */
    func columnViewWillDismiss(notification: NSNotification) {
        
        topScrollView.alpha = 1
        UIView.animateWithDuration(0.5, animations: {
            self.arrowButton.imageView!.transform = CGAffineTransformIdentity
            }, completion: { (_) in
                self.selectedArray = self.editColumnVc.selectedArray
                self.optionalArray = self.editColumnVc.optionalArray
                NSUserDefaults.standardUserDefaults().setObject(self.selectedArray, forKey: "selectedArray")
                NSUserDefaults.standardUserDefaults().setObject(self.optionalArray, forKey: "optionalArray")
                self.prepareUI()
        })
        
    }
    
    /**
     配置侧边栏控制器
     */
    private func setupprofileVc() {
        profileVc = JFProfileViewController(mainVc: self.navigationController!)
        profileVc.profileDelegate = self
    }
    
    /**
     点击左边导航按钮
     */
    @IBAction func didTappedLeftButton(sender: UIButton) {
        profileVc.viewShow()
    }
    
    /**
     第一页视图的侧滑手势处理
     */
    @objc private func didPanOnePageView(gesture: UIPanGestureRecognizer) {
        
        let currentPoint = gesture.translationInView(view)
        if gesture.state == .Changed {
            if currentPoint.x > 0 && currentPoint.x < SCREEN_WIDTH * 0.55 {
                navigationController!.view.transform = CGAffineTransformMakeTranslation(currentPoint.x, 0)
            }
        } else if gesture.state == .Ended {
            if navigationController!.view.transform.tx < SCREEN_WIDTH * 0.45 {
                profileVc.viewDismiss()
            } else {
                profileVc.viewShow()
            }
        }
    }
    
    /**
     顶部标签的点击事件
     */
    @objc private func didTappedTopLabel(gesture: UITapGestureRecognizer) {
        let titleLabel = gesture.view as! JFTopLabel
        // 让内容视图滚动到指定的位置
        contentScrollView.setContentOffset(CGPoint(x: CGFloat(titleLabel.tag) * contentScrollView.frame.size.width, y: contentScrollView.contentOffset.y), animated: true)
    }
    
    /**
     准备视图
     */
    private func prepareUI() {
        
        // 标题logo
        navigationItem.titleView = UIImageView(image: UIImage(named: "navigation_logo"))
        
        // 移除原有数据 - 为的是排序栏目后的数据清理
        for subView in topScrollView.subviews {
            if subView.isKindOfClass(JFTopLabel.classForCoder()) {
                subView.removeFromSuperview()
            }
        }
        for subView in contentScrollView.subviews {
            subView.removeFromSuperview()
        }
        for vc in childViewControllers {
            vc.removeFromParentViewController()
        }
        
        // 添加内容
        addContent()
    }
    
    /**
     配置栏目按钮点击
     */
    @IBAction func didTappedEditColumnButton(sender: UIButton) {
            
        editColumnVc.selectedArray = selectedArray
        editColumnVc.optionalArray = optionalArray
        presentViewController(editColumnVc, animated: true, completion: { 
            
        })
        
        UIView.animateWithDuration(0.5, animations: {
            self.topScrollView.alpha = 0
            self.editColumnVc.view.frame = CGRect(x: 0, y: 40, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60)
            self.arrowButton.imageView!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) - 0.01)
        })
    }
    
    /**
     初始化栏目
     */
    private func setupColumn() {
        let tempSelectedArray = NSUserDefaults.standardUserDefaults().objectForKey("selectedArray") as? [[String : String]]
        let tempOptionalArray = NSUserDefaults.standardUserDefaults().objectForKey("optionalArray") as? [[String : String]]
        
        if tempSelectedArray != nil || tempOptionalArray != nil {
            selectedArray = tempSelectedArray != nil ? tempSelectedArray : [[String : String]]()
            optionalArray = tempOptionalArray != nil ? tempOptionalArray : [[String : String]]()
        } else {
            // 默认栏目顺序
            selectedArray = [
                [
                    "classid" : "0",
                    "classname" : "今日推荐"
                ],
                [
                    "classid" : "1",
                    "classname": "奇闻异事"
                ],
                [
                    "classid" : "2",
                    "classname": "未解之谜"
                ],
                [
                    "classid" : "3",
                    "classname": "天文航天"
                ],
                [
                    "classid" : "4",
                    "classname": "UTO探索"
                ],
                [
                    "classid" : "5",
                    "classname": "神奇地球"
                ],
                [
                    "classid" : "7",
                    "classname": "震惊事件"
                ],
                [
                    "classid" : "8",
                    "classname": "迷案追踪"
                ],
                [
                    "classid" : "9",
                    "classname": "灵异恐怖"
                ],
                [
                    "classid" : "10",
                    "classname": "历史趣闻"
                ],
                [
                    "classid" : "11",
                    "classname": "军事秘闻"
                ]
            ]
            
            optionalArray = [
                [
                    "classid" : "12",
                    "classname": "科学探秘"
                ],
                [
                    "classid" : "13",
                    "classname": "动物植物"
                ],
                [
                    "classid" : "14",
                    "classname": "自然地理"
                ],
                [
                    "classid" : "15",
                    "classname": "内涵趣图"
                ],
                [
                    "classid" : "16",
                    "classname": "爆笑段子"
                ]
            ]
            
            // 默认栏目保存
            NSUserDefaults.standardUserDefaults().setObject(selectedArray, forKey: "selectedArray")
            NSUserDefaults.standardUserDefaults().setObject(optionalArray, forKey: "optionalArray")
        }
        
    }
    
    /**
     添加顶部标题栏和控制器
     */
    private func addContent() {
        
        // 初始化栏目
        setupColumn()
        
        // 布局用的左边距
        var leftMargin: CGFloat = 0
        
        for i in 0..<selectedArray!.count {
            let label = JFTopLabel()
            label.text = selectedArray![i]["classname"]
            label.tag = i
            label.scale = i == 0 ? 1.0 : 0.0
            label.userInteractionEnabled = true
            topScrollView.addSubview(label)
            
            // 利用layout来自适应各种长度的label
            label.snp_makeConstraints(closure: { (make) -> Void in
                make.left.equalTo(leftMargin + 15)
                make.centerY.equalTo(topScrollView)
            })
            
            // 更新布局和左边距
            topScrollView.layoutIfNeeded()
            leftMargin = CGRectGetMaxX(label.frame)
            
            // 添加标签点击手势
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedTopLabel(_:))))
            
            // 添加控制器
            let newsVc = JFNewsTableViewController()
            addChildViewController(newsVc)
            
            // 默认控制器
            if i == 0 {
                newsVc.classid = Int(selectedArray![0]["classid"]!)
                newsVc.view.frame = CGRect(x: 0, y: 0, width: contentScrollView.bounds.width, height: contentScrollView.bounds.height)
                contentScrollView.addSubview(newsVc.view)
                // 给第一个列表控制器的视图添加手势 - 然后在手势代理里面处理手势冲突（tableView默认自带pan手势，如果不处理，我们添加的手势会覆盖默认手势）
                newsVc.tableView.addGestureRecognizer(onePagePanGesture)
            }
        }
        
        // 内容区域滚动范围
        contentScrollView.contentSize = CGSize(width: CGFloat(childViewControllers.count) * SCREEN_WIDTH, height: 0)
        contentScrollView.pagingEnabled = true
        
        let lastLabel = topScrollView.subviews.last as! JFTopLabel
        // 设置顶部标签区域滚动范围
        topScrollView.contentSize = CGSize(width: leftMargin + lastLabel.frame.width, height: 0)
        
        // 视图滚动到第一个位置
        contentScrollView.setContentOffset(CGPoint(x: 0, y: contentScrollView.contentOffset.y), animated: true)
    }
    
}

// MARK: - scrollView代理方法
extension JFNewsViewController: UIScrollViewDelegate {
    
    // 滚动结束后触发 代码导致
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        // 滚动标题栏
        let titleLabel = topScrollView.subviews[index]
        var offsetX = titleLabel.center.x - topScrollView.frame.size.width * 0.5
        let offsetMax = topScrollView.contentSize.width - topScrollView.frame.size.width
        
        if offsetX < 0 {
            offsetX = 0
        } else if (offsetX > offsetMax) {
            offsetX = offsetMax
        }
        
        // 滚动顶部标题
        topScrollView.setContentOffset(CGPoint(x: offsetX, y: topScrollView.contentOffset.y), animated: true)
        
        // 恢复其他label缩放
        for i in 0..<selectedArray!.count {
            if i != index {
                let topLabel = topScrollView.subviews[i] as! JFTopLabel
                topLabel.scale = 0.0
            }
        }
        
    }
    
    // 滚动结束 手势导致
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    // 开始拖拽视图
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        contentOffsetX = scrollView.contentOffset.x
    }
    
    // 正在滚动
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let value = (scrollView.contentOffset.x / scrollView.frame.width)
        
        let leftIndex = Int(value)
        let rightIndex = leftIndex + 1
        let scaleRight = value - CGFloat(leftIndex)
        let scaleLeft = 1 - scaleRight
        
        let labelLeft = topScrollView.subviews[leftIndex] as! JFTopLabel
        labelLeft.scale = scaleLeft
        
        if rightIndex < topScrollView.subviews.count {
            let labelRight = topScrollView.subviews[rightIndex] as! JFTopLabel
            labelRight.scale = scaleRight
        }
        
        var index = Int(value)
        
        // 根据滑动方向计算下标
        if scrollView.contentOffset.x - contentOffsetX > 2.0 {
            index = (value - CGFloat(Int(value))) > 0 ? Int(value) + 1 : Int(value)
        } else if contentOffsetX - scrollView.contentOffset.x > 2.0 {
            index = (value - CGFloat(Int(value))) < 0 ? Int(value) - 1 : Int(value)
        }
        
        // 控制器角标范围
        if index > childViewControllers.count - 1 {
            index = childViewControllers.count - 1
        } else if index < 0 {
            index = 0
        }
        
        // 获取需要展示的控制器
        let newsVc = childViewControllers[index] as! JFNewsTableViewController
        
        // 如果已经展示则直接返回
        if newsVc.view.superview != nil {
            return
        }
        
        contentScrollView.addSubview(newsVc.view)
        newsVc.view.frame = CGRect(x: CGFloat(index) * SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: contentScrollView.frame.height)
        
        // 传递分类数据
        newsVc.classid = Int(selectedArray![index]["classid"]!)
    }
    
}

// MARK: - 侧滑手势处理
extension JFNewsViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // 手指在距离屏幕50内才能触发侧滑手势，参考QQ
        if gestureRecognizer.isKindOfClass(JFPanGestureRecognizer.classForCoder()) {
            if gestureRecognizer.locationInView(view).x < 50 {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
}

// MARK: - 侧边栏各种事件回调
extension JFNewsViewController: JFProfileViewControllerDelegate {
    
    /**
     资料
     */
    func didTappedMyInfo() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFEditProfileViewController(style: UITableViewStyle.Grouped), animated: true)
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     收藏
     */
    func didTappedMyCollectionCell() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFCollectionTableViewController(style: UITableViewStyle.Plain), animated: true)
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     评论
     */
    func didTappedMyCommentCell() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFCommentListTableViewController(style: UITableViewStyle.Plain), animated: true)
        } else {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: {
            })
        }
    }
    
    /**
     设置
     */
    func didTappedSettingCell() {
        navigationController?.pushViewController(JFSettingTableViewController(style: UITableViewStyle.Grouped), animated: true)
    }
    
    /**
     反馈
     */
    func didTappedFeedbackCell() {
        navigationController?.pushViewController(JFProfileFeedbackViewController(style: UITableViewStyle.Plain), animated: true)
    }
    
    /**
     关于六阿哥
     */
    func didTappedMyDutyCell() {
        navigationController?.pushViewController(JFDutyViewController(), animated: true)
    }
}

// MARK: - 栏目管理转场动画事件
extension JFNewsViewController: UIViewControllerTransitioningDelegate {
    
    // 返回一个控制modal视图大小的对象
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return JFPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    // 返回一个控制器modal动画效果的对象
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFPopoverModalAnimation()
    }
    
    // 返回一个控制dismiss动画效果的对象
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFPopoverDismissAnimation()
    }
}
