---
title: Java 数据结构源码 - PriorityQueue & 堆
copyright: true
date: 2020-06-23 20:09:14
tags:
- JAVA源码
- 数据结构
categories:
- JAVA源码
- 数据结构
---
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/b97c9a03759e887d70fbffa0cff706ac.png)
priority queue 相对来说是比较独立的
优先队列 也可以称为优先堆

## Queue 接口
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/9365891d3e3289d4c0f70894d286a4d7.png)
其中,一些方法的作用是类似的
- add 插入失败时抛出异常
- offer 插入失败时返回false

获取队列头, 并移除。空队列
- remove, 会报异常
- poll, 返回null

获取队列头, 但不移除。空队列
- element, 抛异常
- peek, 返回null

## 存储
底层是数组实现, 默认容量是11
```JAVA
private static final int DEFAULT_INITIAL_CAPACITY = 11;
transient Object[] queue; // non-private to simplify nested class accessA
```
构造函数通过传入Comparator 或者 不另外传而直接使用元素继承Comparable 来决定元素的原始顺序

## 扩容
dobble if small else grow by 50% 
```JAVA
```

## 堆化
```JAVA
    // 堆化
    private void heapify() {
        // 最后一个非叶节点开始
        for (int i = (size >>> 1) - 1; i >= 0; i--)
            siftDown(i, (E) queue[i]);
    }
```
### 非叶节点下沉
```JAVA
    private void siftDown(int k, E x) {
        if (comparator != null)
            siftDownUsingComparator(k, x);
        else
            siftDownComparable(k, x);
    }

    private void siftDownComparable(int k, E x) {
        Comparable<? super E> key = (Comparable<? super E>)x;
        int half = size >>> 1;        // loop while a non-leaf
        while (k < half) {
            int child = (k << 1) + 1; // assume left child is least
            Object c = queue[child];
            int right = child + 1;
            if (right < size &&
                ((Comparable<? super E>) c).compareTo((E) queue[right]) > 0)
                c = queue[child = right];
            if (key.compareTo((E) c) <= 0)
                break;
            queue[k] = c;
            k = child;
        }
        queue[k] = key;
    }

    private void siftDownUsingComparator(int k, E x) {
        int half = size >>> 1;
        while (k < half) { // 更新过程节点会下沉，只用在非叶节点中迭代。
            int child = (k << 1) + 1;
            Object c = queue[child];
            // 比较左右节点, 找出小子节点与父交换
            int right = child + 1;
            if (right < size &&
                comparator.compare((E) c, (E) queue[right]) > 0)
                c = queue[child = right];
            if (comparator.compare(x, (E) c) <= 0)
                break;
            queue[k] = c;
            k = child;
        }
        queue[k] = x;
    }

```

## 插入
### 小的尾节点上浮
offer 在尾部插入，插入后向上检查调整
```JAVA
    private void siftUp(int k, E x) {
        if (comparator != null)
            siftUpUsingComparator(k, x);
        else
            siftUpComparable(k, x);
    }

    private void siftUpComparable(int k, E x) {
        Comparable<? super E> key = (Comparable<? super E>) x;
        while (k > 0) {
            int parent = (k - 1) >>> 1;
            Object e = queue[parent];
            if (key.compareTo((E) e) >= 0)
                break;
            queue[k] = e;
            k = parent;
        }
        queue[k] = key;
    }

    private void siftUpUsingComparator(int k, E x) {
        while (k > 0) {
            int parent = (k - 1) >>> 1;
            Object e = queue[parent];
            if (comparator.compare(x, (E) e) >= 0)
                break;
            queue[k] = e;
            k = parent;
        }
        queue[k] = x;
    }

```
## 取出元素
取出元素也要调整，取完head值，用尾节点x替换该位置，做siftDown（0，x)

但里面removeAt方法会有额外的操作
```JAVA
    private E removeAt(int i) {
        assert i >= 0 && i < size;
        modCount++;
        int s = --size;
        if (s == i) // removed last element
            queue[i] = null;
        else {
            E moved = (E) queue[s];
            queue[s] = null;
            siftDown(i, moved);
            if (queue[i] == moved) {
                siftUp(i, moved);
                if (queue[i] != moved)
                    return moved;
            }
        }
        return null;
    }
```
其中还有一个判断是做siftUp的操作，是因为使用迭代器删除时，从低序号开始，可能导致某个元素从末尾被移动到最近一次迭代位置的前面, 

## 总结
所以看到代码默认是一个小顶堆。
从中也可以了解到堆排序里面的建堆过程，节点上浮过程
