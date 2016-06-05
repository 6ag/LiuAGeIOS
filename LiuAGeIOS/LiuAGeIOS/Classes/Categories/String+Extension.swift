//
//  String+Extension.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/22.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import Foundation

extension String {
    
    /**
     时间戳转为时间
     
     - returns: 时间字符串
     */
    func timeStampToString() -> String {
        
        let string = NSString(string: self)
        let timeSta: NSTimeInterval = string.doubleValue
        let date = NSDate(timeIntervalSince1970: timeSta)
        return date.dateDescription()
    }
}