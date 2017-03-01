//
//  JFNewsViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import SnapKit
import pop

class JFNewsViewController: UIViewController {
    
    // MARK: - 各种属性
    /// 顶部标签scrollView
    @IBOutlet weak var topScrollView: UIScrollView!
    /// 内容区域scrollView
    @IBOutlet weak var contentScrollView: UIScrollView!
    /// 顶部标签scrollView旁的箭头按钮
    @IBOutlet weak var arrowButton: UIButton!
    /// 内容区域scrollView x轴偏移量
    fileprivate var contentOffsetX: CGFloat = 0.0
    // 已经选择分类模型集合
    fileprivate var selectedCategoryList = [JFCategoryModel]()
    // 可选分类模型集合
    fileprivate var optionalCategoryList = [JFCategoryModel]()
    
    /// 侧滑手势 - 打开侧边栏
    fileprivate lazy var onePagePanGesture: JFPanGestureRecognizer = {
        let onePagePanGesture = JFPanGestureRecognizer(target: self, action: #selector(didPanOnePageView(_:)))
        onePagePanGesture.delegate = self
        return onePagePanGesture
    }()
    
    /// 侧边栏控制器
    fileprivate lazy var profileVc: JFProfileViewController = {
        let profileVc = JFProfileViewController(mainVc: self.navigationController!)
        return profileVc
    }()
    
    /// 栏目管理控制器
    fileprivate lazy var editColumnVc: JFEditColumnViewController = {
        let editColumnVc = JFEditColumnViewController()
        editColumnVc.transitioningDelegate = self
        editColumnVc.modalPresentationStyle = .custom
        return editColumnVc
    }()
    
    // MARK: - 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 准备视图
        prepareUI()
        // 准备数据
        prepareData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 准备数据
    fileprivate func prepareData() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveRemoteNotificationOfJPush(_:)),
                                               name: NSNotification.Name(rawValue: "didReceiveRemoteNotificationOfJPush"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(columnViewWillDismiss(_:)),
                                               name: NSNotification.Name(rawValue: "columnViewWillDismiss"),
                                               object: nil)
        
        // 加载栏目数据
        loadCategoryList()
    }
    
    /// 加载分类列表
    fileprivate func loadCategoryList() {
        
        JFCategoryModel.loadCategoryList() { (selectedCategoryList, optionalCategoryList) in
            
            // 如果有本地数据则直接回调
            guard let selectedCategoryList = selectedCategoryList,
                let optionalCategoryList = optionalCategoryList else {
                    return
            }
            
            self.selectedCategoryList = selectedCategoryList
            self.optionalCategoryList = optionalCategoryList
            
            // 添加内容视图
            self.addContentView()
        }
        
    }
    
    // MARK: - 各种自定义方法
    /**
     处理接收到的远程通知，跳转到指定的文章
     */
    @objc fileprivate func didReceiveRemoteNotificationOfJPush(_ notification: Notification) {
        
        // 重置badge
        JPUSHService.resetBadge()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if let userInfo = notification.userInfo {
            guard let classid = userInfo["classid"] as? String,
                let id = userInfo["id"] as? String,
                let type = userInfo["type"] as? String else {return}
            
            if type == "photo" {
                let detailVc = JFPhotoDetailViewController()
                detailVc.photoParam = (classid, id)
                navigationController?.pushViewController(detailVc, animated: true)
            } else {
                let detailVc = JFNewsDetailViewController()
                detailVc.articleParam = (classid, id)
                navigationController?.pushViewController(detailVc, animated: true)
            }
            
        }
    }
    
    /**
     点击右边导航按钮  搜索
     */
    @IBAction func didTappedRightButton(_ sender: UIButton) {
        navigationController?.pushViewController(JFSearchViewController(), animated: true)
    }
    
    /**
     顶部标签的点击事件
     */
    @objc fileprivate func didTappedTopLabel(_ gesture: UITapGestureRecognizer) {
        let titleLabel = gesture.view as! JFTopLabel
        // 让内容视图滚动到指定的位置
        let toPoint = CGPoint(x: CGFloat(titleLabel.tag) * contentScrollView.frame.size.width, y: contentScrollView.contentOffset.y)
        contentScrollView.setContentOffset(toPoint, animated: true)
    }
    
    /**
     准备视图
     */
    fileprivate func prepareUI() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "navigation_logo_white"))
        profileVc.profileDelegate = self
    }
    
    /**
     添加顶部标题栏和控制器
     */
    fileprivate func addContentView() {
        
        // 移除所有栏目数据 - 为的是排序栏目后的数据清理
        for subView in topScrollView.subviews {
            if subView.isKind(of: JFTopLabel.classForCoder()) {
                subView.removeFromSuperview()
            }
        }
        for subView in contentScrollView.subviews {
            subView.removeFromSuperview()
        }
        for vc in childViewControllers {
            vc.removeFromParentViewController()
        }
        
        // 布局用的左边距
        var leftMargin: CGFloat = 0
        
        for (index, category) in selectedCategoryList.enumerated() {
            let label = JFTopLabel()
            label.text = category.classname ?? ""
            label.tag = index
            label.scale = index == 0 ? 1.0 : 0.0
            label.isUserInteractionEnabled = true
            topScrollView.addSubview(label)
            
            // 利用layout来自适应各种长度的label
            label.snp.makeConstraints({ (make) -> Void in
                make.left.equalTo(leftMargin + 15)
                make.centerY.equalTo(topScrollView)
            })
            
            // 更新布局和左边距
            topScrollView.layoutIfNeeded()
            leftMargin = label.frame.maxX
            
            // 添加标签点击手势
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedTopLabel(_:))))
            
            // 添加控制器
            let newsVc = JFNewsTableViewController()
            addChildViewController(newsVc)
            
            // 默认控制器 和 预加载的一个控制器
            if index <= 1 {
                
                addContentViewController(index)
                
                if index == 0 {
                    // 给第一个列表控制器的视图添加手势 - 然后在手势代理里面处理手势冲突（tableView默认自带pan手势，如果不处理，我们添加的手势会覆盖默认手势）
                    newsVc.tableView.addGestureRecognizer(onePagePanGesture)
                }
            }
        }
        
        // 内容区域滚动范围
        contentScrollView.contentSize = CGSize(width: CGFloat(childViewControllers.count) * SCREEN_WIDTH, height: 0)
        
        let lastLabel = topScrollView.subviews.last as! JFTopLabel
        // 设置顶部标签区域滚动范围
        topScrollView.contentSize = CGSize(width: leftMargin + lastLabel.frame.width - 55, height: 0)
        
        // 视图滚动到第一个位置
        contentScrollView.setContentOffset(CGPoint(x: 0, y: contentScrollView.contentOffset.y), animated: true)
    }
    
    /**
     添加内容控制器
     
     - parameter index: 控制器角标
     */
    fileprivate func addContentViewController(_ index: Int) {
        
        // 获取需要展示的控制器
        let newsVc = childViewControllers[index] as! JFNewsTableViewController
        
        newsVc.classid = selectedCategoryList[index].classid ?? ""
        
        // 如果已经展示则直接返回
        if newsVc.view.superview != nil {
            return
        }
        
        newsVc.view.frame = CGRect(x: CGFloat(index) * SCREEN_WIDTH, y: 0, width: contentScrollView.bounds.width, height: contentScrollView.bounds.height)
        contentScrollView.addSubview(newsVc.view)
        
    }
    
}

// MARK: - 栏目编辑管理
extension JFNewsViewController {
    
    /**
     配置栏目按钮点击
     */
    @IBAction func didTappedEditColumnButton(_ sender: UIButton) {
        
        editColumnVc.selectedCategoryList = selectedCategoryList
        editColumnVc.optionalCategoryList = optionalCategoryList
        present(editColumnVc, animated: true, completion: nil)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.topScrollView.alpha = 0
            self.editColumnVc.view.frame = CGRect(x: 0, y: 40, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60)
            self.arrowButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI) - 0.01)
        })
    }
    
    /**
     栏目管理控制器即将消失
     */
    func columnViewWillDismiss(_ notification: Notification) {
        
        if self.editColumnVc.selectedCategoryList.count == 0 && self.editColumnVc.optionalCategoryList.count == 0 {
            return
        }
        
        topScrollView.alpha = 1
        UIView.animate(withDuration: 0.5, animations: {
            self.arrowButton.imageView?.transform = CGAffineTransform.identity
        }, completion: { (_) in
            
            // 赋值重新排序后的栏目数据并缓存
            self.selectedCategoryList = self.editColumnVc.selectedCategoryList
            self.optionalCategoryList = self.editColumnVc.optionalCategoryList
            JFCategoryModel.saveCategoryListToCache(selectedCategoryList: self.selectedCategoryList, optionalCategoryList: self.optionalCategoryList)
            
            // 加载内容视图
            self.addContentView()
            
            // 如果是直接点击的分类，则跳转到指定分类
            if let userInfo = notification.userInfo as? [String : Int] {
                let toPoint = CGPoint(x: CGFloat(userInfo["index"]!) * self.contentScrollView.frame.size.width, y: self.contentScrollView.contentOffset.y)
                self.contentScrollView.setContentOffset(toPoint, animated: true)
            }
        })
    }
    
}

// MARK: - scrollView代理方法
extension JFNewsViewController: UIScrollViewDelegate {
    
    // 滚动结束后触发 代码导致
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        // 滚动标题栏
        let titleLabel = topScrollView.subviews[index]
        var offsetX = titleLabel.center.x - topScrollView.frame.size.width * 0.5
        let offsetMax = topScrollView.contentSize.width - topScrollView.frame.size.width - 55
        
        if offsetX < 0 {
            offsetX = 0
        } else if (offsetX > offsetMax) {
            offsetX = offsetMax
        }
        
        // 滚动顶部标题
        topScrollView.setContentOffset(CGPoint(x: offsetX, y: topScrollView.contentOffset.y), animated: true)
        
        // 恢复其他label缩放
        for (i, _) in selectedCategoryList.enumerated() {
            if i != index {
                let topLabel = topScrollView.subviews[i] as! JFTopLabel
                topLabel.scale = 0.0
            }
        }
        
        // 添加控制器 - 并预加载控制器  左滑预加载下下个 右滑预加载上上个 保证滑动流畅
        let value = (scrollView.contentOffset.x / scrollView.frame.width)
        
        var index1 = Int(value)
        var index2 = Int(value)
        
        // 根据滑动方向计算下标
        if scrollView.contentOffset.x - contentOffsetX > 2.0 {
            index1 = (value - CGFloat(Int(value))) > 0 ? Int(value) + 1 : Int(value)
            index2 = index1 + 1
        } else if contentOffsetX - scrollView.contentOffset.x > 2.0 {
            index1 = (value - CGFloat(Int(value))) < 0 ? Int(value) - 1 : Int(value)
            index2 = index1 - 1
        }
        
        // 控制器角标范围
        if index1 > childViewControllers.count - 1 {
            index1 = childViewControllers.count - 1
        } else if index1 < 0 {
            index1 = 0
        }
        if index2 > childViewControllers.count - 1 {
            index2 = childViewControllers.count - 1
        } else if index2 < 0 {
            index2 = 0
        }
        
        addContentViewController(index1)
        addContentViewController(index2)
    }
    
    // 滚动结束 手势导致
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    // 开始拖拽视图
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        contentOffsetX = scrollView.contentOffset.x
    }
    
    // 正在滚动
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
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
    }
    
}

// MARK: - 侧滑手势处理
extension JFNewsViewController: UIGestureRecognizerDelegate {
    
    /**
     第一页视图的侧滑手势处理
     */
    @objc fileprivate func didPanOnePageView(_ gesture: UIPanGestureRecognizer) {
        
        let currentPoint = gesture.translation(in: view)
        if gesture.state == .changed {
            if currentPoint.x > 0 && currentPoint.x < SCREEN_WIDTH * 0.55 {
                navigationController!.view.transform = CGAffineTransform(translationX: currentPoint.x, y: 0)
            }
        } else if gesture.state == .ended {
            if navigationController!.view.transform.tx < SCREEN_WIDTH * 0.45 {
                profileVc.viewDismiss()
            } else {
                profileVc.viewShow()
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // 手指在距离屏幕50内才能触发侧滑手势，参考QQ
        if gestureRecognizer.isKind(of: JFPanGestureRecognizer.classForCoder()) {
            if gestureRecognizer.location(in: view).x < 50 {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
}

// MARK: - 侧边栏
extension JFNewsViewController: JFProfileViewControllerDelegate {
    
    /**
     点击左边导航按钮  侧栏
     */
    @IBAction func didTappedLeftButton(_ sender: UIButton) {
        profileVc.viewShow()
    }
    
    /**
     资料
     */
    func didTappedMyInfo() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFEditProfileViewController(style: UITableViewStyle.grouped), animated: true)
        } else {
            let loginNav = JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil))
            present(loginNav, animated: true, completion: nil)
        }
    }
    
    /**
     收藏
     */
    func didTappedMyCollectionCell() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFMyLikeViewController(), animated: true)
        } else {
            let loginNav = JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil))
            present(loginNav, animated: true, completion: nil)
        }
    }
    
    /**
     评论
     */
    func didTappedMyCommentCell() {
        if JFAccountModel.isLogin() {
            navigationController?.pushViewController(JFMyCommentViewController(), animated: true)
        } else {
            let loginNav = JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil))
            present(loginNav, animated: true, completion: nil)
        }
    }
    
    /// 清理缓存
    func didTappedCleanCache() {
        let cache = CGFloat(YYImageCache.shared().diskCache.totalCost()) / 1024.0 / 1024.0
        let alertC = UIAlertController(title: "您确定要清除缓存吗？一共有\(String(format: "%.2f", cache))M缓存", message: "保留缓存可以节省您的流量哦！", preferredStyle: .alert)
        alertC.addAction(UIAlertAction(title: "确定清除", style: .destructive, handler: { (action) in
            
            JFProgressHUD.showWithStatus("正在清理")
            YYImageCache.shared().diskCache.removeAllObjects({
                DispatchQueue.main.async(execute: {
                    JFProgressHUD.showSuccessWithStatus("清除了\(String(format: "%.2f", cache))M缓存")
                })
            })
        }))
        alertC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alertC, animated: true, completion: nil)
    }
    
    /**
     反馈
     */
    func didTappedFeedbackCell() {
        navigationController?.pushViewController(JFFeedbackViewController(style: UITableViewStyle.plain), animated: true)
    }
    
    /**
     关于六阿哥
     */
    func didTappedMyDutyCell() {
        navigationController?.pushViewController(JFAboutUSViewController(), animated: true)
    }
    
}

// MARK: - 栏目管理自定义转场动画事件
extension JFNewsViewController: UIViewControllerTransitioningDelegate {
    
    /**
     返回一个控制modal视图大小的对象
     */
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return JFPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    /**
     返回一个控制器modal动画效果的对象
     */
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFPopoverModalAnimation()
    }
    
    /**
     返回一个控制dismiss动画效果的对象
     */
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFPopoverDismissAnimation()
    }
    
}
