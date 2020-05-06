---
title: Java 数据结构源码 - ArrayList
copyright: true
date: 2020-05-06 20:46:15
tags: JAVA源码
categories: JAVA源码
top:
---

![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/b582bdbc74401259648f0d6bb1a4b0a7.png)

Clonable 可克隆
Serializable 可序列化
RamdomAccess 随机访问
都是空接口, 相当于一个声明, 约定

## List
重点关注List接口
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/70282f18a00dc95df682759717b31906.png)
List 接口则主要是比Collection 接口多了一些 与index 相关 的接口

## AbstractList
定义了
- AbstractList
- SubList
- RandomAccessSubList
三个抽象类，暂时先略过后面两个
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/ef87acb8388cfdc3b3ad3e372c6eb891.png)

AbstractList 有 Itr 内部类，不作细述。
迭代器 日常使用得不多，Iterator模式是用于遍历集合类的标准访问方法。
```
for(Iterator it = c.iterater(); it.hasNext(); ) 
```
由集合本身实现, 它可以把访问逻辑从不同类型的集合类中抽象出来，从而避免向客户端暴露集合的内部结构。


里面通常有变量`modCount` 描述列表的结构变化次数。主要用于 failed-fast。当不是预期的修改出现，快速抛出异常

## ArrayList

三个常量, 给定默认值
```JAVA
// 没指定容量的时候，默认容量
private static final int DEFAULT_CAPACITY = 10;

//空数组
private static final Object[] EMPTY_ELEMENTDATA = {};

// 对应默认容量10的数组,方便赋值
private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};
```

两个变量
elementData 存储数据
size 存入数据的数量, 与capacity不一样
```JAVA
//存放数据的容器
transient Object[] elementData; // non-private to simplify nested class access

private int size;
```

构造函数会用到默认的常量
```JAVA
public ArrayList(int initialCapacity) {
    if (initialCapacity > 0) {
        //Object Array
        this.elementData = new Object[initialCapacity];
    } else if (initialCapacity == 0) {
        //空数组
        this.elementData = EMPTY_ELEMENTDATA;
    } else {
        throw new IllegalArgumentException("Illegal Capacity: "+
                initialCapacity);
    }
}


public ArrayList() {
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}

//从其他集合构造
public ArrayList(Collection<? extends E> c) {
    elementData = c.toArray();
    if ((size = elementData.length) != 0) {
        // c.toArray might (incorrectly) not return Object[] (see 6260652)
        if (elementData.getClass() != Object[].class)
            elementData = Arrays.copyOf(elementData, size, Object[].class);
    } else {
        // replace with empty array.
        this.elementData = EMPTY_ELEMENTDATA;
    }
}
```

具体的数据访问方式主要是实现了AbstractList。
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/0545378e5b916afb9bcfc95ee467a967.png)
这里不对具体的操作数据的方法细说。细节的可以自己翻源码查看一下。

主要关注扩容，数据检查的一些方法。
比如需要插入数据的时候，通常会`ensureCapacity`方法确保容量
```JAVA
public void ensureCapacity(int minCapacity) {
    int minExpand = (elementData != DEFAULTCAPACITY_EMPTY_ELEMENTDATA)
        // any size if not default element table
        ? 0
        // larger than default for default empty table. It's already
        // supposed to be at default size.
        : DEFAULT_CAPACITY;

    if (minCapacity > minExpand) {
        ensureExplicitCapacity(minCapacity);
    }
}

private static int calculateCapacity(Object[] elementData, int minCapacity) {
    if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
        return Math.max(DEFAULT_CAPACITY, minCapacity);
    }
    return minCapacity;
}

private void ensureCapacityInternal(int minCapacity) {
    ensureExplicitCapacity(calculateCapacity(elementData, minCapacity));
}

private void ensureExplicitCapacity(int minCapacity) {
    //记录修改容量的次数, 主要用于快速失败
    modCount++;

    // overflow-conscious code
    if (minCapacity - elementData.length > 0)
        grow(minCapacity);
}
```

最终判断需要扩容的话
调用 grow(minCapacity);
```JAVA
private void grow(int minCapacity) {
    // overflow-conscious code
    // 常规扩容 oldCapacity * 1.5
    int oldCapacity = elementData.length;
    int newCapacity = oldCapacity + (oldCapacity >> 1); 
    // 1.5倍还不够，一步到位
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;
    // 超过最大容量了
    if (newCapacity - MAX_ARRAY_SIZE > 0)
        newCapacity = hugeCapacity(minCapacity);
    // minCapacity is usually close to size, so this is a win:
    elementData = Arrays.copyOf(elementData, newCapacity);
}
```
minCapacity是需要达到的最小容量，与真正的扩展容量的大小是有区别的


```JAVA
/**
 * The maximum size of array to allocate.
 * Some VMs reserve some header words in an array.
 * Attempts to allocate larger arrays may result in
 * OutOfMemoryError: Requested array size exceeds VM limit
 */
private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;

private static int hugeCapacity(int minCapacity) {
    if (minCapacity < 0) // overflow
        throw new OutOfMemoryError();
    return (minCapacity > MAX_ARRAY_SIZE) ?
        Integer.MAX_VALUE :
        MAX_ARRAY_SIZE;
}

```
`MAX_ARRAY_SIZE`是 此处是部分VM会保留头部   数组的对象头信息相较于其他Object，多了一个表示数组长度的信息。 

但我的VM亲测设置为 `MAX_ARRAY_SIZE` 也没有问题。 再高就溢出了

基于index 的访问方法会进行rangeCheck
```JAVA
private void rangeCheck(int index) {
    if (index >= size)
        throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
}

private void rangeCheckForAdd(int index) {
    if (index > size || index < 0)
        throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
}

private String outOfBoundsMsg(int index) {
    return "Index: "+index+", Size: "+size;
}
```

基于object 的则是主要用到equals 方法遍历去寻找元素
```JAVA
for (int i = 0; i < size; i++)      
    if (o.equals(elementData[i]))
        return i;
```

修改数据需要通过复制数组实现，同时还会修改`modCount`
```
public static native void arraycopy(Object src,  int  srcPos,
        Object dest, int destPos,
        int length);
```
