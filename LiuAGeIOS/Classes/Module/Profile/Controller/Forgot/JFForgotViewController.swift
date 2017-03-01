//
//  JFForgotViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFForgotViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var retrieveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "忘记密码"
        didChangeTextField(usernameField)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func didChangeTextField(_ sender: UITextField) {
        if usernameField.text?.characters.count ?? 0 > 5 &&
            emailField.text?.characters.count ?? 0 > 5 {
            retrieveButton.isEnabled = true
            retrieveButton.backgroundColor = ACCENT_COLOR
        } else {
            retrieveButton.isEnabled = false
            retrieveButton.backgroundColor = DISENABLED_BUTTON_COLOR
        }
    }
    
    @IBAction func didTappedRetrieveButton(_ sender: UIButton) {
        
        view.endEditing(true)
        
        let parameters = [
            "username" : self.usernameField.text!,
            "action" : "SendPassword",
            "email" : self.emailField.text!
        ]
        
        // 发送登录请求
        JFNetworkTool.shareNetworkTool.post(MODIFY_ACCOUNT_INFO, parameters: parameters) { (success, result, error) in
            if result != nil {
                if result!["data"]["info"].stringValue == "邮件已发送，请登录邮箱认证并取回密码" {
                    _ = self.navigationController?.popViewController(animated: true)
                }
                JFProgressHUD.showInfoWithStatus(result!["data"]["info"].stringValue)
                self.dismiss(animated: true, completion: nil)
            } else {
                JFProgressHUD.showInfoWithStatus("找回失败，请联系管理员！")
            }
            
        }
        
    }
    
}
