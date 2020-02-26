---
title: vue-cli3.0 前后端分离
date: 2020-02-26 10:01:06
tags: vue
---
前后端分离开发有几个阶段
1.纯前端开发，此时使用mock或自行模拟数据/请求
2.与后端联调接口,需要发送请求到后端
3.前后端分开部署/部署到同一机器上。

在涉及到第2/3步时，常见有跨域的问题。

vue-cli3.0通过配置devServer,proxy转发请求到后台url,可以解决跨域问题。
<!--more-->
## 跨域
浏览器为了安全需要，提出了一种同源策略的约定。
同源策略（同域）就是两个页面具有相同的协议（http等），主机（host）,端口号。
当三者其一不同时，即为跨域。

比如：
前后端联调时, vue 使用 npm run serve 启动devServer 运行在 localhost:8080，后端项目运行在8088端口。
这时候从静态页面所在的localhost:8080/page.html请求一个 localhost:8088/api，端口号不同就会产生跨域问题。

此时，浏览器会报，No 'Access-Control-Allow-Origin' 的错误。
这问题前后端都可以处理。

## 后端解决办法
java spring 可以添加一个filter，为response添加相关的header
https://blog.csdn.net/wangyy130/article/details/84397961uuu

## 前端解决办法（vue-cli3.0）
开发时可以直接利用vue 提供的 代理功能
在vue.config.js添加配置
```
devServer: {
    port:8081,
    proxy: {
        '/api':{
            target:  'http://localhost:8088',
        }
    }
}
```
此时看到请求还是 在请求8081端口的，但是devServer帮我们完成了转发功能。

## 生产使用nginx代理
可以将打包后的静态资源部署在nginx上。 
https://zpengg.github.io/2020/02/26/nginx/#more
