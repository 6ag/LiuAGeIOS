//
//  JFSettingTableViewController.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/5.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFSettingTableViewController: JFBaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "设置"
        
        prepareData()
    }
    
    /**
     准备数据
     */
    fileprivate func prepareData() {
        
        let group1CellModel1 = JFProfileCellSwitchModel(title: "推送开关")
        let group1 = JFProfileCellGroupModel(cells: [group1CellModel1])
        
        groupModels = [group1]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }

}
