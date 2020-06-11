---
title: HyperLogLog 与基数统计
copyright: true
date: 2020-06-11 23:31:31
tags: 
 - 数据结构
 - redis
categories: 数据结构
top:
---
统计不重复的元素可以称为基数统计

基数统计可以用以下方法
HashMap
BitMap
LinearCounting LC
LogLogCounting LLC
HyperLogLogCounting HLL

在小数据量的时候常用 Hash方法去重进行统计
但当数据量变大时，存储大量数据的成本上升。
HLL提供了一种方法，通过牺牲一定精度来换取存储空间下降

## 应用

ES 提供一个Cardinality聚合 其中使用到了HyperLogLog++算法。

Redis 在 2.8.9 版本添加了 HyperLogLog 结构。有Pfadd Pfcount Pfmerge 等相关命令

## 基本原理
概率估计
记录小概率事件的出现，来倒推实验次数规模

HLL的基本原理是利用集合中数字的比特串第一个1出现位置的最大值来预估整体基数。通过分桶，使用调和平均数（LLC使用了几何平均数，偏差大）
这篇里面有较为详细的原理 和 JAVA实现
https://www.jianshu.com/p/55defda6dcd2

## redis 实现
redis中统计数组大小设置为，hash函数生成64位bit数组。
14bit 直接计算桶下标。50bit用来看连续0的位置

2^14 = 16834 个HyperLogLog 键（桶下标）
每个桶给6bit记录最大的连续0位置，
16384* 6 /8/1024/1024 = 12kB
只需要花费 12 KB 内存。（固定的大小去描述基数指标,不随基数改变）
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/1cadb29d72019597e05eed1053de31e3.png)

然后每次观察50bit的最大连续0数量，并更新相应的桶的6bit值
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/a9f7461e1dc9a52667ba0c1582c65f4c.png)


[底层还有一些优化]( https://mp.weixin.qq.com/s/dyXGKfpzd4MP9JrSYTZC6Q?utm_medium=hao.caibaojian.com&utm_source=hao.caibaojian.com) 
字节流中如何找到6bit位置
稀疏存储 和 密集存储的区别 
PfAdd 不会一次性分配，先存成稀疏矩阵，逐渐增加到阈值一次性分配12KB稠密矩阵。 
等等

## HLL演示网址
http://content.research.neustar.biz/blog/hll.html 
