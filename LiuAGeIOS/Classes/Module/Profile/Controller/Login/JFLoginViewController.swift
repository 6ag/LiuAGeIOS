//
//  JFLoginViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import pop

class JFLoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField! // 用户名
    @IBOutlet weak var passwordField: UITextField! // 密码
    @IBOutlet weak var loginButton: UIButton!      // 登录
    @IBOutlet weak var showPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    /// 准备数据
    fileprivate func prepareData() {
        title = "登录"
        // 设置保存的账号
        usernameField.text = UserDefaults.standard.object(forKey: "username") as? String
        passwordField.text = UserDefaults.standard.object(forKey: "password") as? String
        // 更新文本框状态
        didChangeTextField(usernameField)
        // 左上角关闭按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top_navigation_close"), style: .done, target: self, action: #selector(close))
    }
    
    /// 关闭页面
    @objc fileprivate func close() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    /// 隐藏显示密码
    @IBAction func didTappedShowPasswordButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordField.isSecureTextEntry = !passwordField.isSecureTextEntry
    }
    
    /**
     登录按钮点击事件
     */
    @IBAction func didTappedLoginButton(_ button: UIButton) {
        
        view.isUserInteractionEnabled = false
        view.endEditing(true)
        
        let parameters: [String : Any] = [
            "username" : self.usernameField.text!,
            "password" : self.passwordField.text!
        ]
        
        JFProgressHUD.showWithStatus("正在登录")
        // 发送登录请求
        JFNetworkTool.shareNetworkTool.post(LOGIN, parameters: parameters) { (success, result, error) in
            log(result)
            
            if success {
                // 保存账号和密码
                UserDefaults.standard.set(self.usernameField.text, forKey: "username")
                UserDefaults.standard.set(self.passwordField.text, forKey: "password")
                
                if let successResult = result {
                    let account = JFAccountModel(dict: successResult["data"].dictionaryObject! as [String : AnyObject])
                    // 更新用户本地数据
                    account.updateUserInfo()
                    self.close()
                    JFProgressHUD.showSuccessWithStatus("登录成功")
                }
            } else if result != nil {
                guard let result = result else {
                    JFProgressHUD.showInfoWithStatus("登录失败")
                    return
                }
                
                JFProgressHUD.showInfoWithStatus(result["data"].dictionaryValue["info"]!.stringValue)
            } else {
                JFProgressHUD.showInfoWithStatus("登录失败")
            }
            
            self.view.isUserInteractionEnabled = true
        }
        
    }
    
    /// 注册
    @IBAction func didTappedRegisterButton(_ sender: UIButton) {
        let registerVc = JFRegisterViewController(nibName: "JFRegisterViewController", bundle: nil)
        registerVc.delegate = self
        navigationController?.pushViewController(registerVc, animated: true)
    }
    
    /// 忘记密码
    @IBAction func didTappedForgotButton(_ sender: UIButton) {
        let forgotVc = JFForgotViewController(nibName: "JFForgotViewController", bundle: nil)
        navigationController?.pushViewController(forgotVc, animated: true)
    }
    
    /// 监听文本框值改变
    @IBAction func didChangeTextField(_ sender: UITextField) {
        if usernameField.text?.characters.count ?? 0 > 5 &&
            passwordField.text?.characters.count ?? 0 > 5 {
            loginButton.isEnabled = true
            loginButton.backgroundColor = ACCENT_COLOR
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = DISENABLED_BUTTON_COLOR
        }
    }
    
    /// 点击了同意/取消同意注册条款
    @IBAction func didTappedAgree(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    /// 点击了注册条款
    @IBAction func didTappedRegisterAgree(_ sender: UIButton) {
        navigationController?.pushViewController(JFRegisterAgreeViewController(), animated: true)
    }
    
}

// MARK: - 第三方登录
extension JFLoginViewController {
    
    /// 新浪微博登录
    @IBAction func didTappedSinaLoginButton(_ sender: UIButton) {
        
        ShareSDK.getUserInfo(SSDKPlatformType.typeSinaWeibo, conditional: nil) { (state, user, error) in
            if state == SSDKResponseState.success {
                self.SDKLoginHandle(user?.nickname, avatar: user?.rawData["avatar_hd"] != nil ? user?.rawData["avatar_hd"] as? String : user?.icon, uid: user?.uid, type: 2)
            } else {
                JFProgressHUD.showInfoWithStatus("授权失败")
            }
        }
    }
    
    /// QQ登录
    @IBAction func didTappedQQLoginButton(_ sender: UIButton) {
        ShareSDK.getUserInfo(SSDKPlatformType.typeQQ, conditional: nil) { (state, user, error) in
            if state == SSDKResponseState.success {
                self.SDKLoginHandle(user?.nickname, avatar: user?.rawData["figureurl_qq_2"] != nil ? user?.rawData["figureurl_qq_2"] as? String : user?.icon, uid: user?.uid, type: 1)
            } else {
                JFProgressHUD.showInfoWithStatus("授权失败")
            }
        }
    }
    
    /// 第三方登录授权处理
    ///
    /// - Parameters:
    ///   - nickname: 昵称
    ///   - avatar: 头像url
    ///   - uid: 唯一标识
    ///   - type: 1QQ  2新浪
    func SDKLoginHandle(_ nickname: String?, avatar: String?, uid: String?, type: Int) {
        
        guard let nickname = nickname,
            let avatar = avatar,
            let uid = uid else { return }
        
        let string = uid.characters.count >= 12 ? (uid as NSString).substring(to: 12) : uid
        var lowerString = string.lowercased()
        lowerString = type == 1 ? "qq_\(lowerString)" : "wx_\(lowerString)"
        
        let parameters = [
            "username" : lowerString,
            "password" : string,
            "email" : "\(lowerString)@pcbshijie.com",
            "userpic" : avatar,
            "nickname" : nickname,
            ]
        
        JFNetworkTool.shareNetworkTool.post(REGISTER, parameters: parameters) { (success, result, error) in
            if success {
                self.usernameField.text = lowerString
                self.passwordField.text = string
                self.didChangeTextField(self.passwordField)
                self.didTappedLoginButton(self.loginButton)
            } else if result != nil {
                if result!["info"].stringValue == "此用户名已被注册" {
                    self.usernameField.text = lowerString
                    self.passwordField.text = string
                    self.didChangeTextField(self.passwordField)
                    self.didTappedLoginButton(self.loginButton)
                } else {
                    JFProgressHUD.showInfoWithStatus(result!["info"].stringValue)
                }
                
            }
        }
    }
    
}

// MARK: - 注册回调
extension JFLoginViewController: JFRegisterViewControllerDelegate {
    
    /// 注册成功
    ///
    /// - Parameters:
    ///   - username: 账号
    ///   - password: 密码
    func registerSuccess(_ username: String, password: String) {
        usernameField.text = username
        passwordField.text = password
        didChangeTextField(usernameField)
        didTappedLoginButton(loginButton)
    }
}
