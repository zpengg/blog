---
title: esConfig
date: 2020-03-24 23:39:26
categories:
 - ElasticSearch
tags:
 - ES
 - ElasticSearch
 - ELK
---


## 添加节点 信息
node.master
node.data

## 修改集群IP列表

## 修改elasticsearch-env脚本强制使用内部1.8的java 

## root用户无法运行, 创建个普通用户运行测试

创建elsearch用户组及elsearch用户
https://blog.csdn.net/lahand/article/details/78954112
```
groupadd elsearch
useradd elsearch -g elsearch -p elasticsearch
```
更改elasticsearch文件夹及内部文件的所属用户及组为elsearch:elsearch
```
chown -R elsearch:elsearch  /path/to/es
```
切换到elsearch用户再启动
```
su elsearch cd /path/to/es/bin
./elasticsearch
```
启动后打印信息如下

后台启动命令
```
./elasticsearch -d 
```
后台查看进程
```
ps -ef | grep elastic
kill -9 进程
```

启动时发觉
max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
设置
sysctl -w vm.max_map_count=262144
查看相应设置
sysctl -a|grep vm.max_map_count

ip:9200,可以看看是否启动成功，集群信息是否正确

kibana 理论上 也需要创建个用户
但有--allow-root 参数，自己测试可以使用。

kibana 后台运行
nohup /usr/local/kibana/bin/kibana &

查看kibana
ps -ef | grep '.*node/bin/node.*src/cli'

## 设置允许跨域
如head插件会用到
日常如果前端要直接请求 也会用到
yml配置文件添加
http.cors.enable = true
http.cors.allow-origin = *
