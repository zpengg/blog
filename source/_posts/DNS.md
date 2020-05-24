---
title: DNS
copyright: true
date: 2020-05-24 10:36:40
tags: 
 - 网络
 - DNS
categories:
 - 网络
top:
---
域名系统 Domain Name System

![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/589322fe2451bab764fd0a44775cc2c2.png)

根域名.
顶级域名 .com

全球13组域名根节点

## 查询方式
### 递归查询
主机向本地域名服务器的查询一般都是采用递归查询。

浏览器缓存→hosts&系统缓存→路由器缓存→ISP DNS 缓存→递归搜索

大多数的 linux 发行版都不使用本机 DNS 缓存。所以，一般也就不存在刷新问题。

### 迭代查询
本地域名服务器向根域名服务器的查询的迭代查询。
按上图的分层结构去查

![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/aa025de74609db4d7b14c32b571b6461.png)

## 命令查看dns解析过程
dig 命令可以查看dns解析过程

dig  @server   name  type
采用udp
```bash
$ dig www.baidu.com 
```
![](https://imgconvert.csdnimg.cn/aHR0cDovL3pwZW5nZy5vc3MtY24tc2hlbnpoZW4uYWxpeXVuY3MuY29tL2ltZy84ZGI2Y2IwYjBkMjYwZTFkMmMzNTJiNGQ3MTY2Mjk0ZS5wbmc?x-oss-process=image/format,png)

```bash
$ dig www.baidu.com ++trace
```
![](https://imgconvert.csdnimg.cn/aHR0cDovL3pwZW5nZy5vc3MtY24tc2hlbnpoZW4uYWxpeXVuY3MuY29tL2ltZy8yYmEzODZmODU5MzdkNzUxMWVmYjBiNDlhMzQ5NDEwNC5wbmc?x-oss-process=image/format,png)
可以看到迭代查询过程

类似的命令还有 nslookup，会返回更简介一点 
![](https://imgconvert.csdnimg.cn/aHR0cDovL3pwZW5nZy5vc3MtY24tc2hlbnpoZW4uYWxpeXVuY3MuY29tL2ltZy8xYzcwNjEyNTU4ZDhkZmNjMzk0OThhYTA2MDA2YTI5MC5wbmc?x-oss-process=image/format,png)


### 记录类型
type 包括
- A(address)记录
- NS记录（name server）
- MX（mail）
- CNAME

A记录是域名到ip的映射，即为ip起别名；

CNAME是域名别名到域名的映射，即为域名起别名。
CNAME有一个好处就是对外稳定, 不随IP变动

MX记录，它是与邮件相关的，MX记录记录了发送电子邮件时域名对应的服务器地址

NS解析服务器记录。用来表明由哪台服务器对该域名进行解析。这里的NS记录只对子域名生效。
NS 记录优先于A记录

## 8.8.8.8
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/589322fe2451bab764fd0a44775cc2c2.png)
8.8.8.8是一个IP地址，是Google提供的免费DNS服务器的IP地址，Google提供的另外一个免费DNS服务器的IP地址是：8.8.4.4 。用户可以使用Google提供的DNS服务器上网。

## TCP 查看解析过程

53端口为DNS(Domain Name Server，域名服务器)服务器所开放

```
$ sudo tcpdump -v port 53
```
## 浏览器dns缓存
chrome://net-internals/#dns

## 清除本地dns 缓存 mac
dscacheutil -flushcache


