---
title: 前后端分离下，使用nginx部署前端
tags:
  - nginx
categories:
  - 网络
date: 2020-02-26 10:00:18
---

前后端分离下使用nginx 部署前端，转发请求到后端
 <!-- more -->
## 正向代理 反向代理

正向代理:客户端 <一> 代理  一>服务端  
反向代理:客户端  一> 代理 <一>服务端  

## 配置
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/999e13800b70998cdbec931f19cbc725.png)
此处的意思是i
监听localhost:8080端口
根目录即 localhost:8080/ 指向 nginx 目录下的 html文件夹里

在未做代理之前, 请求为 localhost:8080/datamarket-web/api
但此时后端为localhost:8088 前端调试时,需要将/datamarket-web开头的API转发到8088的端口  
因此如图中第二个location 配置 proxy_pass 即可

## Windows下nginx命令
在Windows下操作nginx，需要打开cmd 进入到nginx的安装目录下
（尝试过添加环境变量，但貌似执行时会以当前目录做某些参数导致启动失败）

```
# 1.启动nginx:

start nginx 
# 或
nginx.exe

# 2.停止nginx(stop是快速停止nginx，可能并不保存相关信息；quit是完整有序的停止nginx，并保存相关信息)

nginx.exe  -s stop 
# 或
nginx.exe -s quit

# 3.检查 重启：

nginx -t  修改nginx配置后执行检查配置是否正确
# 或
nginx -s reload 重启
```


