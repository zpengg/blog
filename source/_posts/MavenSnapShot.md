---
title: SNAPSHOT jar包是否带时间戳的区别
copyright: true
date: 2020-05-24 11:45:24
tags: maven 
categories: maven
top:
---

![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/ef3b54e8e1a4b8e5a483d372210fd593.png)
时间戳是用来区分一个版本号的 SNAPSHOT 版本的多次deploy的，
别的项目引用的时候，会自动下载最新发布的。
如果在本地 install 就不会有时间戳，会认为是最新的。

但在父子工程中 又是另外一种表现。
比如

A parent 
|
|- B
|- C

子工程 B war 包 依赖 另一个 子工程 C 的war 包

在父工程A 执行 mvn package 时，是不会另外从私服下载最新的C
也不会从本地仓库取

而是会和本工程package 生成的 C的war建立依赖。(虽然还没有deploy)
其他不是A工程内的依赖的子工程，才会请求本地/远程仓库下载。 

但直接在B中mvn package 则会从远程仓库取 C的最新包

大致是这么一个顺序

工程->本地仓库->远程仓库
