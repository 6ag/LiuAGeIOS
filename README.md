# 六阿哥网iOS版

### 项目介绍

基于我写的另一个项目 [BaoKanIOS](https://github.com/6ag/BaoKanIOS) 代码基础上进行重构改进、重写后台接口、重写优化app、还有那啥。。诞生的。这个项目数据来源我的网站 [六阿哥网](http://www.6ag.cn)  。

整个项目结构清晰、注释详细、代码通俗易懂，主要运用到的技术：手势冲突处理、js与swift交互、缓存管理和一些UI技巧。项目难度比较低，适合 `swift` 新手参考，不喜勿喷。有任何问题或者建议都可以随时叫我啊！

### 项目结构

+ LiuAGeIOS *项目主目录*
+ ------------ Resource *资源目录*
+ ------------ Classes *项目所有类文件*
+ ---------------------- Application *应用级别类*
+ ---------------------- Vendor *第三方库*
+ ---------------------- Categories *分类*
+ ---------------------- Model *公共模型*
+ ---------------------- Utils *工具类*
+ ---------------------- Module *模块目录*
+ ------------------------------------- Main *主模块*
+ ------------------------------------- News *新闻模块*
+ ------------------------------------- Profile *个人中心模块*

### 开发环境

*XCode7.3* + *swift2.2* ，如果下载项目后，编译失败，请检查 `XCode` 版本是否满足。

### 特别注意

资讯正文部分的图片是用 `YYWebImage` 进行缓存管理的，而由于 `YYWebImage` 的缓存策略原因，低于 `20kb` 的文件不会直接存文件，所以我们必须要修改框架原文件。修改`YYCache` -> `YYDiskCache.m` 的第 `171` 行，将 `1024 * 20` 修改为 `0` 即可。

### 讲解文章

[网易新闻app内容详情页实现分析
](https://blog.6ag.cn/1514.html)

### 主流控制器切换

![image](https://github.com/6ag/LiuAGeIOS/blob/master/1.gif)

### 自定义栏目管理

![image](https://github.com/6ag/LiuAGeIOS/blob/master/2.gif)

### 性感的侧栏，无手势冲突

![image](https://github.com/6ag/LiuAGeIOS/blob/master/3.gif)

### 支持各种手势的图片浏览器

![image](https://github.com/6ag/LiuAGeIOS/blob/master/4.gif)

### 模仿网易新闻的内容正文

![image](https://github.com/6ag/LiuAGeIOS/blob/master/5.gif)

