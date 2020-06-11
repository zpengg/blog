---
title: JAVA 数据结构源码 - Vector
copyright: true
date: 2020-06-01 00:22:21
tags: 
 - JAVA源码
 - 数据结构
categories:
 - JAVA源码
 - 数据结构
top:
---
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/654739fc937480b0158534b05ac2dcf6.png)
Vector 它是JDK1.0版本添加的类。(元老级..)
与ArrayList相似, 继承于AbstractList，实现了List, RandomAccess, Cloneable这些接口。
下面主要对比着来分析

## 构造方法
ArrayList 无参构造 默认初始化长度0的数组, 但其实后面添加元素还是会扩容到10, 个人理解为Lazy init
Vector 初始化长度为10

## 访问方法
Vector大部分的访问方法 都是synchonized 的

## 扩容相关
扩容相关的方法 ensureCapacity、grow 也有些许不同。

ArrayList ensureCapacityInternal 内部计算modCount
Vector ensureCapacityHelper 不计算modCount，在外层 add 等方法计算。同时因为外层已经synchronized了所以该方法不必重复加synchronized

![扩容差别](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/d574c4bc06c98bef4cb4ae0029f10ca4.png)
左边ArrayList 的默认扩容是 1.5倍
右边Vector 的默认扩容与 若capacityIncrement 有初始化，则增加该值，否则为2倍

## 同步容器的缺陷
- 使用synchonized 性能会有下降(阻止编译器指令重排）

- synchronized 单方法是线程安全, 但组合操作时不具有原子性，还是会存在线程安全问题。
比如一个线程在fori get， 另一个线程在 fori remove。

- ConcurrentModificationException。这个问题在ArrayList 和 vector 都存在

ConcurrentModificationException，可观察其迭代过程中
1.若是用list.remove(); 会导致modCount != expectedModCount, 会抛异常
2.而单线程下使用 iterator.remove() 不会报这个错
3.多线程. 因为 expectedModCount 是在 Itr 的成员变量，与线程有关，初始化时候用 modCont 赋值。 然后modCount 在 中间被其他线程B修改， 在原来的线程A出现 modCount != expectedModCount 而抛出异常。

所以,日常还是避免使用古董代码Vector。（还有他的子类Stack。。）
非并发用ArrayList，并发情况就上其他并发容器。

