---
title: JAVA 数据结构源码 - ArrayDeque & LinkedList
copyright: true
date: 2020-06-26 08:46:15
tags:
- JAVA源码
- 数据结构
categories:
- JAVA源码
- 数据结构
---

两个deque 放一起说了。
<!--more-->
## 继承关系
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/7f8e65651d9eee9c06cf5c6a4923564e.png)
queue已经介绍过了
现看下deque提供的接口

### Deque
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/4f1bcff8fe223388933253f5e29ec295.png)

deque 主要多了头尾的概念，两头都可以操作，同时提供了stack会用到的push pop接口。
双端队列,队列和栈的综合体

然后也会提供两个方向的迭代器

### AbstractSequetialList
AbstractSequetianList 区别于 AbstractList 主要是以顺序迭代访问的方式，实现了部分index访问接口（ramdon-access），需要通过迭代器来找到该位置
子类需要实现listIterator的方法。

用迭代器抽象的顺序列表。
LinkedList （双向）链表是其中一种实现。

## LinkedList
LinkedList 内部的节点修改
增加节点
- 从头
- 从尾
- 从某节点前插入
```JAVA
/**
 * Links e as first element.
 */
private void linkFirst(E e) {
    final Node<E> f = first;
    final Node<E> newNode = new Node<>(null, e, f);
    first = newNode;
    if (f == null)
        last = newNode;
    else
        f.prev = newNode;
    size++;
    modCount++;
}
/**
 * Links e as last element.
 */
void linkLast(E e) {
    final Node<E> l = last;
    final Node<E> newNode = new Node<>(l, e, null);
    last = newNode;
    if (l == null)
        first = newNode;
    else
        l.next = newNode;
    size++;
    modCount++;
}

/**
 * Inserts element e before non-null Node succ.
 */
void linkBefore(E e, Node<E> succ) {
    // assert succ != null;
    final Node<E> pred = succ.prev;
    final Node<E> newNode = new Node<>(pred, e, succ);
    succ.prev = newNode;
    if (pred == null)
        first = newNode;
    else
        pred.next = newNode;
    size++;
    modCount++;
}
```

删除节点
- 从头
- 从尾
- 删除中间节点，关联前后节点，有必要还更新头尾节点引用
```
/**
 * Unlinks non-null first node f.
 */
private E unlinkFirst(Node<E> f) {
    // assert f == first && f != null;
    final E element = f.item;
    final Node<E> next = f.next;
    f.item = null;
    f.next = null; // help GC
    first = next;
    if (next == null)
        last = null;
    else
        next.prev = null;
    size--;
    modCount++;
    return element;
}

/**
 * Unlinks non-null last node l.
 */
private E unlinkLast(Node<E> l) {
    // assert l == last && l != null;
    final E element = l.item;
    final Node<E> prev = l.prev;
    l.item = null;
    l.prev = null; // help GC
    last = prev;
    if (prev == null)
        first = null;
    else
        prev.next = null;
    size--;
    modCount++;
    return element;
}

/**
 * Unlinks non-null node x.
 */
E unlink(Node<E> x) {
    // assert x != null;
    final E element = x.item;
    final Node<E> next = x.next;
    final Node<E> prev = x.prev;

    if (prev == null) {
        first = next;
    } else {
        prev.next = next;
        x.prev = null;
    }

    if (next == null) {
        last = prev;
    } else {
        next.prev = prev;
        x.next = null;
    }

    x.item = null;
    size--;
    modCount++;
    return element;
}

```

## ArrayDeque
隐藏掉 Cloneable 和 Serializable 两个接口 方便对比一下。

<div align="center"> <img src="http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/92f077c99c9b8a1431179e2ab2acf9d8.png"/> </div>
功能上 ArrayList，LinkedList 两个是继承了 AbstractList，因此，他们都提供了机遇 index 访问的方式。
而 ArrayDeque 则是直接从 AbstractCollection 外加了 Deque 的两头访问的方法。

### ArrayDeque 构造函数
无参默认16，有参数取最近2的幂（8个起）。
```JAVA
    public ArrayDeque() {
        elements = new Object[16];
    }

    public ArrayDeque(int numElements) {
        allocateElements(numElements);
    }

    public ArrayDeque(Collection<? extends E> c) {
        allocateElements(c.size());
        addAll(c);
    }

    private void allocateElements(int numElements) {
        elements = new Object[calculateSize(numElements)];
    }

    private static int calculateSize(int numElements) {
        int initialCapacity = MIN_INITIAL_CAPACITY;
        // Find the best power of two to hold elements.
        // Tests "<=" because arrays aren't kept full.
        if (numElements >= initialCapacity) {
            initialCapacity = numElements;
            initialCapacity |= (initialCapacity >>>  1);
            initialCapacity |= (initialCapacity >>>  2);
            initialCapacity |= (initialCapacity >>>  4);
            initialCapacity |= (initialCapacity >>>  8);
            initialCapacity |= (initialCapacity >>> 16);
            initialCapacity++;

            if (initialCapacity < 0)   // Too many elements, must back off
                initialCapacity >>>= 1;// Good luck allocating 2 ^ 30 elements
        }
        return initialCapacity;
    }

```
## 环状
```JAVA
    public void addFirst(E e) {
        if (e == null)
            throw new NullPointerException();
        elements[head = (head - 1) & (elements.length - 1)] = e;
        if (head == tail)
            doubleCapacity();
    }

    public void addLast(E e) {
        if (e == null)
            throw new NullPointerException();
        elements[tail] = e;
        if ( (tail = (tail + 1) & (elements.length - 1)) == head)
            doubleCapacity();
    }
```
`head = (head - 1) & (elements.length - 1)` 这一句可以看到 `head` 更新是一哥 `&`操作，而元素长度刚好是2的幂，所以相当于是取模操作。
这时 head 和 tail 指针 相当于是数组头尾连接的 **环** 上移动。
head == tail 的情况就相当于整个环已经满了。
这样可以高效利用已分配的空间。

## 扩容
扩容相对于ArrayList来说简单一点，满了直接DoubleCapacity。
```JAVA
public void addFirst(E e) {
    if (e == null)
        throw new NullPointerException();
    elements[head = (head - 1) & (elements.length - 1)] = e;
    if (head == tail)
        doubleCapacity();
}


public void addLast(E e) {
    if (e == null)
        throw new NullPointerException();
    elements[tail] = e;
    if ( (tail = (tail + 1) & (elements.length - 1)) == head)
        doubleCapacity();
}

private void doubleCapacity() {
    assert head == tail;
    int p = head;
    int n = elements.length;
    int r = n - p; // number of elements to the right of p
    int newCapacity = n << 1;
    if (newCapacity < 0)
        throw new IllegalStateException("Sorry, deque too big");
    Object[] a = new Object[newCapacity];
    System.arraycopy(elements, p, a, 0, r);
    System.arraycopy(elements, 0, a, r, p);
    elements = a;
    head = 0;
    tail = n;
}

```
当然 double 之后，伴随着的是数组复制，以及 head tail 两个指针的重置为 0，n。



