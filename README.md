# 六阿哥网iOS版

## 项目介绍

资讯类客户端，数据来源我的个人网站 [六阿哥网](http://www.6ag.cn)。

## AppStore

<a target='_blank' href='https://itunes.apple.com/app/id1120896924'>
<img src='http://ww2.sinaimg.cn/large/0060lm7Tgw1f1hgrs1ebwj308102q0sp.jpg' width='144' height='49' />
</a>

## 主要技术

+ `tableView` / `scrollView` 手势冲突处理
+ 主流选项卡切换控制器、加载数据方式
+ 分类栏目自定义管理、 `collectionView` 排序
+ 主流图片浏览器处理、各种手势、用户体验增强
+ 使用 `sqlite` 数据库缓存列表页、幻灯片、新闻正文、图库正文数据
+ `js` 与 `swift` 交互，实现正文加载图片占位和缓存处理，并添加图片点击交互
+ 集成 `JPush` 实现各种远程推送，集成 `ShareSDK` 实现社交分享、第三方登录

## 开发环境

*XCode8.2.1* + *swift3.0* ，如果下载项目后，编译失败，请检查 `XCode` 版本是否满足。

## 讲解文章

+ [使用NSKeyedArchiver缓存app用户账号数据](https://blog.6ag.cn/1545.html)
+ [使用SQLite缓存数据分析与实现](https://blog.6ag.cn/1551.html)
+ [网易新闻app内容页实现分析与代码实现 完成图片缓存和交互](https://blog.6ag.cn/1514.html)

## 演示图

### 主流控制器切换

![image](https://github.com/6ag/LiuAGeIOS/blob/master/Show/1.gif)

### 自定义栏目管理

![image](https://github.com/6ag/LiuAGeIOS/blob/master/Show/2.gif)

### 性感的侧栏，无手势冲突

![image](https://github.com/6ag/LiuAGeIOS/blob/master/Show/3.gif)

### 支持各种手势的图片浏览器

![image](https://github.com/6ag/LiuAGeIOS/blob/master/Show/4.gif)

### 模仿网易新闻的内容正文

![image](https://github.com/6ag/LiuAGeIOS/blob/master/Show/5.gif)

### 便捷修改字体

![image](https://github.com/6ag/LiuAGeIOS/blob/master/Show/6.gif)

### 上拉退出详情

![image](https://github.com/6ag/LiuAGeIOS/blob/master/Show/7.gif)

### iPad列表页

![image](https://github.com/6ag/LiuAGeIOS/blob/master/Show/8.jpg)

### iPad正文

![image](https://github.com/6ag/LiuAGeIOS/blob/master/Show/9.jpg)

### iPad图库

![image](https://github.com/6ag/LiuAGeIOS/blob/master/Show/10.jpg)

## 许可

[MIT](https://raw.githubusercontent.com/Finb/V2ex-Swift/master/LICENSE) © [六阿哥](https://github.com/6ag)


