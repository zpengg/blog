---
title: JAVA 数据结构源码 - TreeMap & 红黑树
copyright: true
date: 2020-06-11 23:24:41
tags:
 - JAVA源码
 - 数据结构
categories:
 - JAVA源码
 - 数据结构
top:
---

![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/0802f407ed9aee4a8cfabe142450e9dc.png)

TreeMap 对比 HashMap 
多继承了NavigableMap，NavigableMap则继承了 SortedMap
## SortedMap
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/feee604ddff88b5b20ad3af44ee9a507.png)
subMap, headMap, tailMap 等接口以SortedMap返回部分满足范围的K，V对， key在 fromKey，toKey 范围内
也可通过firstKey,lastKey 取得头尾key

## NavigableMap
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/a727aea5229e4f223269790f8679e061.png)
比起SortedMap多了可以访问相邻key和Entry的方法
还有celling floor 等向上向下找到最近key的方法

## 构造函数
``` java

    public TreeMap() {
        comparator = null;
    }

    public TreeMap(Comparator<? super K> comparator) {
        this.comparator = comparator;
    }

    public TreeMap(Map<? extends K, ? extends V> m) {
        comparator = null;
        putAll(m);
    }


    public TreeMap(SortedMap<K, ? extends V> m) {
        comparator = m.comparator();
        try {
            buildFromSorted(m.size(), m.entrySet().iterator(), null, null);
        } catch (java.io.IOException cannotHappen) {
        } catch (ClassNotFoundException cannotHappen) {
        }
    }
```
构造函数主要与比较器有关。决定Key以什么方式排序
comparater == null 的时候，调用具体方法时再取Key类型实现的比较器
```
Comparable<? super K> k = (Comparable<? super K>) key;
```


## 存取方法
所有Entry对 存储在红黑树中。
之前的HashMap有`treeify`过程，使用的也是红黑树。
简单的提到了插入时的平衡过程, 用到的一些变色，左旋，右旋操作。

在此再复习下红黑树的基本性质

 - 节点分红/黑色 boolean red
 - 根节点 黑色
 - 红子节点的子节点黑色。
 - 每个叶节点（NIL节点 无数据)是黑色 
 - root到NIL的黑色节点数目相同

红黑树也是二叉查找树的方法

get方法

``` java
public V get(Object key) {
    Entry<K,V> p = getEntry(key);
    return (p==null ? null : p.value);
}

final Entry<K,V> getEntry(Object key) {
    // Offload comparator-based version for sake of performance
    if (comparator != null)
        // 与下面的比较差不多 也是二叉查找
        return getEntryUsingComparator(key); 
    if (key == null)
        throw new NullPointerException();
    @SuppressWarnings("unchecked")
        Comparable<? super K> k = (Comparable<? super K>) key;
    Entry<K,V> p = root;
    while (p != null) {
        int cmp = k.compareTo(p.key);
        if (cmp < 0) // k<p.key 左
            p = p.left;
        else if (cmp > 0) // k>p.key 右
            p = p.right;
        else// until equals
            return p;
    }
    return null;
}
```
put方法

二叉查找树 左右子数查找key是否存在，在的话修改值
直至查找不到，则在该处插入 然后红黑树调整`fixAfterInsertion`
```
public V put(K key, V value) {
    Entry<K,V> t = root;
    if (t == null) {
        compare(key, key); // type (and possibly null) check

        root = new Entry<>(key, value, null);
        size = 1;
        modCount++;
        return null;
    }
    int cmp;
    Entry<K,V> parent;
    // split comparator and comparable paths
    Comparator<? super K> cpr = comparator;
    if (cpr != null) {
        do {
            parent = t;
            cmp = cpr.compare(key, t.key);
            if (cmp < 0)
                t = t.left;
            else if (cmp > 0)
                t = t.right;
            else
                return t.setValue(value);
        } while (t != null);
    }
    else {
        if (key == null)
            throw new NullPointerException();
        @SuppressWarnings("unchecked")
            Comparable<? super K> k = (Comparable<? super K>) key;
        do {
            parent = t;
            cmp = k.compareTo(t.key);
            if (cmp < 0)
                t = t.left;
            else if (cmp > 0)
                t = t.right;
            else
                return t.setValue(value);
        } while (t != null);
    }
    Entry<K,V> e = new Entry<>(key, value, parent);
    if (cmp < 0)
        parent.left = e;
    else
        parent.right = e;
    fixAfterInsertion(e);
    size++;
    modCount++;
    return null;
}
```

## 红黑树调整 
### fixAfterInsertion
跟HashMap的平衡操作对比一下。
左边TreeMap这个可读性好一点。。。
HashMap给变量赋值的过程写进了判断逻辑稍微难读点，不过相对的也少一些调用栈

![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/a6fa5a9eecb0000d6abec0d467ac40a5.png)

``` java
private void fixAfterInsertion(Entry<K,V> x) {
    // 新插入的节点为红色
    x.color = RED;
    // 自底向上 调整到根节点 or 父节点不是连续红色
    while (x != null && x != root && x.parent.color == RED) {
        if (parentOf(x) == leftOf(parentOf(parentOf(x)))) { // xp == xppl
            Entry<K,V> y = rightOf(parentOf(parentOf(x)));
            // 兄弟节点存在且同红色(相当于null为黑) 切颜色
            // 解决连续红色问题
            if (colorOf(y) == RED) { 
                setColor(parentOf(x), BLACK);
                setColor(y, BLACK);
                setColor(parentOf(parentOf(x)), RED);
                x = parentOf(parentOf(x));
            } else {
                if (x == rightOf(parentOf(x))) { // x == xpr && xp == xppl, 有拐弯
                    x = parentOf(x);// x = xp 此处x有一次引用变换
                    rotateLeft(x);//需先左旋到外侧 统一成 r<-r<-b 的连续左子树
                }
                //r<-r<-[b]->b
                setColor(parentOf(x), BLACK);
                //r<-b<-[b]->b
                setColor(parentOf(parentOf(x)), RED);
                //r<-b<-[r]->b
                rotateRight(parentOf(parentOf(x)));
                //r<-[b]->r->b
            }
        } else {
            Entry<K,V> y = leftOf(parentOf(parentOf(x)));
            // 兄弟节点同红色 切颜色
            if (colorOf(y) == RED) {
                setColor(parentOf(x), BLACK);
                setColor(y, BLACK);
                setColor(parentOf(parentOf(x)), RED);
                x = parentOf(parentOf(x));
            } else {
                if (x == leftOf(parentOf(x))) { //先右后左 也拐弯
                    x = parentOf(x);
                    rotateRight(x); // 相应的 统一成连续右子树
                }
                setColor(parentOf(x), BLACK);
                setColor(parentOf(parentOf(x)), RED);
                rotateLeft(parentOf(parentOf(x)));
            }
        }
    }
    root.color = BLACK;
}
```

### fixedDeletion
先看deleteEntry, 二叉查找树的删除方法。
deleteEntry 与 HashMap removeTreeNode L2061 开始看基本也是一致的
```java
/**
 * Delete node p, and then rebalance the tree.
 */
private void deleteEntry(Entry<K,V> p) {
    modCount++;
    size--;

    // If strictly internal, copy successor's element to p and then make p
    // point to successor.
    // 此处套了层有两个子节点的检查
    // 所以succesor里边只会寻找右子树的最小节点
    if (p.left != null && p.right != null) {
        Entry<K,V> s = successor(p);    
        p.key = s.key;
        p.value = s.value;
        p = s;
    } // p has 2 children

    // p处理过后 此时只剩一边有子节点或者都没有
    // Start fixup at replacement node, if it exists.
    Entry<K,V> replacement = (p.left != null ? p.left : p.right);

    if (replacement != null) {
        // Link replacement to parent
        replacement.parent = p.parent;
        if (p.parent == null)
            root = replacement;
        else if (p == p.parent.left)
            p.parent.left  = replacement;
        else
            p.parent.right = replacement;

        // Null out links so they are OK to use by fixAfterDeletion.
        p.left = p.right = p.parent = null;

        // Fix replacement
        // 原删除节点是黑色，不平衡，需要从替代节点开始做平衡
        if (p.color == BLACK)
            fixAfterDeletion(replacement);
    } else if (p.parent == null) { // return if we are the only node.
        // 上下都没有节点，自己唯一一个也删掉了，更新root
        root = null;
    } else { //  No children. Use self as phantom replacement and unlink.
        if (p.color == BLACK)
            fixAfterDeletion(p);

        if (p.parent != null) {
            if (p == p.parent.left)
                p.parent.left = null;
            else if (p == p.parent.right)
                p.parent.right = null;
            p.parent = null;
        }
    }
}
```

里边也有一个平衡用的方法fixedDeletion

``` java
/** From CLR */
private void fixAfterDeletion(Entry<K,V> x) {
    // 不断旋转直到x是个红色节点 or root
    while (x != root && colorOf(x) == BLACK) {
        if (x == leftOf(parentOf(x))) {
            Entry<K,V> sib = rightOf(parentOf(x));
            // 记住x BLACK
            // sib兄不同色, RED
            // xB- xp？-sibR
            if (colorOf(sib) == RED) {
                setColor(sib, BLACK); //兄变黑
                setColor(parentOf(x), RED);// 父节点变红
                rotateLeft(parentOf(x)); //兄 让你喊爸爸
                sib = rightOf(parentOf(x));// 更新下兄
                // xB- xpR - newsibB
            }
            // sib 有过变换 
            // 但还是可以保证sib是黑色的
            // 记住x BLACK, sib BLACK
            // xB- xp? -sibB
            if (colorOf(leftOf(sib))  == BLACK &&
                colorOf(rightOf(sib)) == BLACK) {
                // 记住x BLACK, sib BLACK
                // 记住[统一处理形状][需要迭代]
                // xB- xp? -sibB
                //       lB-sibB-rB  1. sib转色 与x平衡
                //                   2. 迭代平衡xp 
                // 让兄节点也减少一个黑色
                setColor(sib, RED);
                // 父节点子树黑色数少1，需要继续平衡
                // 迭代x
                x = parentOf(x);
            } else {
                // 记住x BLACK, sib BLACK
                // sib兄的 子节点 一黑一红
                // lR-sibB-rB 左红右黑 需要转换sib子树
                if (colorOf(rightOf(sib)) == BLACK) { 
                    setColor(leftOf(sib), BLACK);
                    setColor(sib, RED);
                    rotateRight(sib);
                    sib = rightOf(parentOf(x));
                }
                // 记住x BLACK, sib BLACK
                // sib兄的 子节点 左黑右红
                // 记住[统一处理形状] 
                // xB-xp?-sibB       1.先确保sib BLACK
                //     lB-sibB-rR    2.再确保sib 近x的一边是lBlack 远端rRED
                //                   3.调整后即可平衡
                setColor(sib, colorOf(parentOf(x)));//sib 涂成父亲颜色
                setColor(parentOf(x), BLACK); // 父亲变黑
                setColor(rightOf(sib), BLACK);// 兄 两子黑 +1
                rotateLeft(parentOf(x)); 
                // 子数根 变成 sib 颜色不变
                // 左边子树 xp变黑 下沉 黑色+1
                // 右边 sib 上升 -1 但sib->r黑色+1 中和了
                // 达到平衡
                x = root;
            }
        } else { // symmetric 
            // 对称的
            // 记住[需要迭代的形状]
            //    sibB - xp? -xB
            // lB-sibB-rB        1. sib转色 黑色-1 与x平衡
            //                   2. 迭代平衡xp 
            // 让兄节点也减少一个黑色
            
            // 记住[可通过连续旋转带走的形状]
            //    sibB-xp?-xB    1.先确保sib BLACK
            // lR-sibB-rB        2.再确保sib 近x的一边是lBlack 远端rRED
            //                   3.调整后即可平衡
            // 1 不满足，可以把父节点旋去另一子树 给一黑子 做新的sib
            // 2 不满足，sib 旋到远端，改红色
            // 3 最后， 2
            Entry<K,V> sib = leftOf(parentOf(x));

            if (colorOf(sib) == RED) {
                setColor(sib, BLACK);
                setColor(parentOf(x), RED);
                rotateRight(parentOf(x));
                sib = leftOf(parentOf(x));
            }

            if (colorOf(rightOf(sib)) == BLACK &&
                colorOf(leftOf(sib)) == BLACK) {
                setColor(sib, RED);
                x = parentOf(x);
            } else {
                if (colorOf(leftOf(sib)) == BLACK) {
                    setColor(rightOf(sib), BLACK);
                    setColor(sib, RED);
                    rotateLeft(sib);
                    sib = leftOf(parentOf(x));
                }
                setColor(sib, colorOf(parentOf(x)));
                setColor(parentOf(x), BLACK);
                setColor(leftOf(sib), BLACK);
                rotateRight(parentOf(x));
                x = root;
            }
        }
    }

    setColor(x, BLACK);
}
```

successor这个方法要获取删除后要替换的节点。

[BST-leetcode](https://leetcode.com/explore/learn/card/introduction-to-data-structure-binary-search-tree/141/basic-operations-in-a-bst/1019/)
leetcode上提到以下方法去删除需要最小的转换
>1. If the target node has no child, we can simply remove the node.
>2. If the target node has one child, we can use its child to replace itself.
>3. If the target node has two children, replace the node with its in-order successor or predecessor node and delete that node.
以上方法都不会改变中序遍历的顺序

```
/*
 * Returns the successor of the specified Entry, or null if no such.
 */
static <K,V> TreeMap.Entry<K,V> successor(Entry<K,V> t) {
    if (t == null)
        return null;
    else if (t.right != null) { 
        //右子树的最左边后代 or 没有后代的右子节点
        // 相当于中序遍历中的右边相邻节点
        Entry<K,V> p = t.right;
        while (p.left != null) // t.r.l.l...
            p = p.left;
        return p;           
    } else { // t.right == null
        // 向上直到递归找到第一个比他大的祖先
        // 直到自身是左子树根节点的时候
        // 还是中序遍历中的右相邻节点
        Entry<K,V> p = t.parent; 
        Entry<K,V> ch = t;
        while (p != null && ch == p.right) {// t.p.r == t
            ch = p;
            p = p.parent;
        }
        return p;
    }
}
```




看完也可以看看二叉搜索树相关的内容巩固一下
[BST-leetcode](https://leetcode.com/explore/learn/card/introduction-to-data-structure-binary-search-tree/141/basic-operations-in-a-bst/1019/)
