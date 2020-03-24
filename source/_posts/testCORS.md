---
title: 使用XHR请求测试接口是否支持跨域
date: 2020-03-24 23:20:21
categories:
 - 网络
 - 工具
tags: 跨域
---

直接在浏览器console中输入js代码测试
```
var xhr = new XMLHttpRequest();
xhr.open('GET', 'http://10.43.43.11:9200');
xhr.send(null);
xhr.onload = function(e) {
        var xhr = e.target;
            console.log(xhr.responseText);
}
```
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/1ae1a19037ddfdc5a6bce19f9d80bc67.png)
