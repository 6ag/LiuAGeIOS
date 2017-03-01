//
//  JFRegisterViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFRegisterViewControllerDelegate {
    func registerSuccess(_ username: String, password: String)
}

class JFRegisterViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    var delegate: JFRegisterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "注册"
        didChangeTextField(usernameField)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    /// 隐藏显示密码
    @IBAction func didTappedShowPasswordButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordField.isSecureTextEntry = !passwordField.isSecureTextEntry
    }
    
    /// 文本值改变
    @IBAction func didChangeTextField(_ sender: UITextField) {
        if usernameField.text?.characters.count ?? 0 > 5 &&
            passwordField.text?.characters.count ?? 0 > 5 &&
            emailField.text?.characters.count ?? 0 > 5 {
            registerButton.isEnabled = true
            registerButton.backgroundColor = ACCENT_COLOR
        } else {
            registerButton.isEnabled = false
            registerButton.backgroundColor = DISENABLED_BUTTON_COLOR
        }
    }
    
    /// 注册
    @IBAction func didTappedLoginButton(_ sender: UIButton) {
        
        view.endEditing(true)
        
        let parameters = [
            "username" : self.usernameField.text!,
            "password" : self.passwordField.text!,
            "email" : self.emailField.text!
        ]
        
        JFProgressHUD.showWithStatus("正在注册")
        
        // 发送登录请求
        JFNetworkTool.shareNetworkTool.post(REGISTER, parameters: parameters) { (success, result, error) in
            if success {
                JFProgressHUD.showInfoWithStatus("注册成功，自动登录")
                _ = self.navigationController?.popViewController(animated: true)
                // 注册成功后回调成功
                self.delegate?.registerSuccess(self.usernameField.text!, password: self.passwordField.text!)
            } else if result != nil {
                JFProgressHUD.showInfoWithStatus(result!["info"].stringValue)
            }
            
        }
        
    }
    
}
