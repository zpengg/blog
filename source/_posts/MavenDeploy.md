---
title: maven deploy 上传 jar 包到私服
copyright: true
date: 2020-05-24 11:41:27
tags: maven
categories: maven
top:
---

### 直接在nexus上界面填写信息上传
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/17bef8b0691ccbe5a9e0a8e2c6e0805d.png)

### mvn deploy 命令上传

![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/c91739b83dd209e1bf995becb6e34b73.png)
groupId,artifactId,version 这些可以参看包的meta信息

另外几个参数
file 本地jar包位置
url nexus仓库url
repositoryId 可以在nexus上看, repository path 的后缀

注意不要选择local仓库里的包
会报cannot deploy artifact from the local repositoy 的错

如果遇到return code is 401。需要在mvn 的setting.xml文件中配置server的账号密码, id为 repostioryId
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/e366afc5f1f0a1b810b50d0e348be6da.png)
