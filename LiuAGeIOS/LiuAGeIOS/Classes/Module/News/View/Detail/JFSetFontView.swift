//
//  JFSetFontView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFSetFontViewDelegate: NSObjectProtocol {
    func didChangeFontSize(fontSize: Int)
    func didChangedFont(fontNumber: Int, fontPath: String, fontName: String)
    func didChangedNightMode(on: Bool)
}

class JFSetFontView: UIView {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var nightModeSwitch: UISwitch!
    @IBOutlet weak var fontSegment: UISegmentedControl!
    
    var currentButton: UIButton!              // 当前选中状态的按钮
    let bgView = UIView(frame: SCREEN_BOUNDS) // 透明遮罩
    let minSize = 12                          // 14   16   18   20  22   24
    var delegate: JFSetFontViewDelegate?
    
    // 初始化
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 夜间模式
        nightModeSwitch.on = isNight()
        
        // 字体
        fontSegment.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().integerForKey(CONTENT_FONT_TYPE_KEY)
        
        // 字体大小
        let fontSize = NSUserDefaults.standardUserDefaults().integerForKey(CONTENT_FONT_SIZE_KEY)
        let scale = (fontSize - minSize) / 2
        currentButton = viewWithTag(scale) as! UIButton
        currentButton.selected = true
        slider.setValue(Float(scale), animated: true)
    }
    
    /**
     修改了夜间、白天模式
     */
    @IBAction func didChangedNightMode(sender: UISwitch) {
        delegate?.didChangedNightMode(sender.on)
    }
    
    /**
     修改了字体
     */
    @IBAction func didChangedFontSegment(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 1 {
            delegate?.didChangedFont(sender.selectedSegmentIndex, fontPath: NSBundle.mainBundle().pathForResource("HYQiHei-50J.ttf", ofType: nil)!, fontName: "汉仪旗黑")
        } else {
            delegate?.didChangedFont(sender.selectedSegmentIndex, fontPath: "", fontName: "")
        }
    }
    
    /**
     修改字体按钮点击
     */
    @IBAction func didTappedFontButton(button: UIButton) {
        currentButton = button
        slider.setValue(Float(button.tag), animated: true)
        selectHandle()
    }
    
    /**
     修改字体滑条滑动
     */
    @IBAction func didTappedSlider(sender: UISlider) {
        var scale = Int(sender.value)
        if sender.value - Float(Int(sender.value)) >= 0.5 {
            scale = Int(sender.value) + 1
        }
        
        sender.setValue(Float(scale), animated: true)
        currentButton = viewWithTag(scale) as! UIButton
        selectHandle()
    }
    
    /**
     修改字体按钮选中处理
     */
    private func selectHandle() {
        for subView in subviews {
            if subView.isKindOfClass(UIButton.classForCoder()) {
                let button = subView as! UIButton
                button.selected = false
            }
        }
        currentButton.selected = true
        
        // 字体大小系数 1 - 6
        let scale = currentButton.tag
        let fontSize = minSize + scale * 2
        delegate?.didChangeFontSize(fontSize)
    }
    
    /**
     透明背景遮罩触摸事件
     */
    @objc private func didTappedBgView(tap: UITapGestureRecognizer) {
        dismiss()
    }
    
    /**
     弹出视图
     */
    func show() -> Void {
        bgView.backgroundColor = UIColor(white: 0, alpha: 0)
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedBgView(_:))))
        UIApplication.sharedApplication().keyWindow?.addSubview(bgView)
        
        frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 200)
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
        
        UIView.animateWithDuration(0.25, animations: {
            self.transform = CGAffineTransformMakeTranslation(0, -200)
            self.bgView.backgroundColor = UIColor(white: 0, alpha: GLOBAL_SHADOW_ALPHA)
        }) { (_) in
            
        }
        
    }
    
    /**
     隐藏视图
     */
    func dismiss() -> Void {
        UIView.animateWithDuration(0.25, animations: {
            self.transform = CGAffineTransformIdentity
            self.bgView.backgroundColor = UIColor(white: 0, alpha: 0)
        }) { (_) in
            self.bgView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
}
