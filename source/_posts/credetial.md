---
title: the credentials flag is true
date: 2020-03-24 23:17:02
categories: 网络
tags: 跨域
---

请求报错：
A wildcard '\*' cannot be used in the 'Access-Control-Allow-Origin' header when the credentials flag is true

'Access-Control-Allow-Origin' 的\* 与 credential flag= true 有冲突 
The value of "\*" is special in that it does not allow requests to supply credentials

如果前端请求开启 withCredentials: true 后台接口也需要对应的将 Access-Control-Allow-Credentials 设为 true。

但前端开启不会表现在header上。

参考这篇文章补充记录一下credential 等跨域有关的一些参数
[或进一步了解fecth](https://www.cnblogs.com/libin-1/p/6815525.html)

常用的 mode 属性值有:
 - same-origin: 表示只请求同域. 如果你在该 mode 下进行的是跨域的请求的话, 那么就会报错.
 - no-cors: 正常的网络请求, 主要应对于没有后台没有设置 Access-Control-Allow-Origin. 话句话说, 就是用来处理 script, image 等的请求的. 他是 mode 的默认值.
 - cors: 用来发送跨域的请求. 在发送请求时, 需要带上.
 - cors-with-forced-preflight: 这是专门针对 xhr2 支持出来的 preflight，会事先多发一次请求给 server，检查该次请求的合法性。


另外, 还有一个关于 cookie 的跨域内容. 在 XHR2 中,我们了解到, withCredentials 这个属性就是用来设置在进行跨域操作时, 对不同域的 Server 是否发送本域的 cookie. 一般设置为 omit(不发送). 在 fetch 当中, 使用的是 credentials 属性.

credentials 常用取值为:
 - omit: 发送请求时,不带上 cookie. 默认值.
 - same-origin: 发送同域请求时,会带上 cookie
 - include: 只要发送请求,都会带上 cookie.
