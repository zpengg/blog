---
title: Java 数据结构源码 - HashMap
copyright: true
date: 2020-05-11 20:27:44
tags:
 - JAVA 源码
 - 数据结构
categories:
 - JAVA 源码
 - 数据结构
top:
---
## AbstractMap
定义了 k-v pair, SimpleEntry和SimpleImmutableEntry
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/34e0113823f3c50d030f7e175981106c.png)

用以下容器存储K V 数据
```
Set<K> keySet
Collection<V> values
```

`Map.Entry<K,V>` 描述两者的映射
entrySet 则交给子类实现
```
public abstract Set<Entry<K,V>> entrySet();
```

## HashMap
### 默认值
```
    static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16

    static final int MAXIMUM_CAPACITY = 1 << 30;

    static final float DEFAULT_LOAD_FACTOR = 0.75f;

    static final int TREEIFY_THRESHOLD = 8; // 链表节点数树化阈值

    static final int UNTREEIFY_THRESHOLD = 6; // 取消树化阈值

    static final int MIN_TREEIFY_CAPACITY = 64;

```
### 结构
数组 -> 链表 -> 红黑树的结构
此处应有图

存放数据的链表节点由内部类Node来表示
```JAVA
static class Node<K,V> implements Map.Entry<K,V>{
    final int hash;
    final K key;
    V value;
    Node<K,V> next;
    ...
}
```
#### hash值 计算
hash 值是 key.hashCode 异或xor 自身高16位
```JAVA
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```
至于hash值怎么用，可以配合 get/put 方法食用, (可参考下一段代码 put相关方法)。
可以追溯到`n = tab.length`、`first = tab[(n - 1) & hash]` 中的索引`(n - 1) & hash`
(n-1)后bit全为1，hash值做mask掩码（像子网那样）
然后再看回前边为高16位异或。相当于融合了高低位的信息，减少低位一样时这种掩码导致的冲突。

```
public V put(K key, V value) {
    return putVal(hash(key), key, value, false, true);
}

    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)
            // 初始化 tab 数组
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            // tab[i] == null  插入 tab[i] 位置
            tab[i] = newNode(hash, key, value, null);
        else { // tab[i] != null  插入 tab[i] 位置
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                // tab[i] 的 头/根节点
                e = p;
            else if (p instanceof TreeNode) // 按树的方式找
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else { // 按链表的方式找
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        // 找不到节点 在链表最后插入
                        p.next = newNode(hash, key, value, null);
                        // 检查是否需要树化
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        // 节点在链表中已存在
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
}
```
数量少的时候是链表
多的时候会进行树化,
数化的时候Node会转换成另一个类TreeNode
```
static final class TreeNode<K,V> extends LinkedHashMap.Entry<K,V> {
    TreeNode<K,V> parent;  // red-black tree links
    TreeNode<K,V> left;
    TreeNode<K,V> right;
    TreeNode<K,V> prev;    // needed to unlink next upon deletion
    boolean red;
    ...
}
```
红黑树细节的话后面详谈

## resize 扩容
先看看容量有关的几个关键概念
loadFactor 负载因子 必须
threshold = capacity * loadFactor 扩容阈值 or 初始化成initCapacity最近的2的幂

size 键值对数量
capacity 桶数组大小 默认16，非默认根据threshold lazy init

前边提到数组是这样一个形式
```
transient Node<K,V>[] table;
```
table的一个slot中存放的是hash 相同的元素（hash冲突）
### 处理单个节点
` newTab[e.hash & (newCap - 1)] = e; ` 直接按新容量重新定位

### 处理链表
前文坐标计算 `(n-1) & hash`
扩容前oldCap为16
0000 1111 mask = 15
0000 0101 hash1
0001 0101 hash2

链表可以根据`e.hash & oldCap == 0`恰好分成低两组
0001 0000 oldCap = 16
0000 0101 hash1 -> low
0001 0101 hash2 -> high

```
Node<K,V> loHead = null, loTail = null;
Node<K,V> hiHead = null, hiTail = null;
```
### 处理树
split方法，按上面方法分成两个链表再看判断 treeify/untreeify
untreeify的话,本身是链表了,主要还是节点的转换
```
 final Node<K,V> untreeify(HashMap<K,V> map) {
            Node<K,V> hd = null, tl = null;
            for (Node<K,V> q = this; q != null; q = q.next) {
                Node<K,V> p = map.replacementNode(q, null);
                if (tl == null)
                    hd = p;
                else
                    tl.next = p;
                tl = p;
            }
            return hd;
        }
```


### 2的幂
这里可以看到size取2的幂是有原因的
另外初始门限也有个比较有趣的函数，作用是获得最近的2的幂
```
    static final int tableSizeFor(int cap) {
        int n = cap - 1;
        n |= n >>> 1;
        n |= n >>> 2;
        n |= n >>> 4;
        n |= n >>> 8;
        n |= n >>> 16;
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }
```
2的幂是某一位是1其余都是0
-1后，最高位置为1，然后移位后按位或则是将次高位后全都置的1
再加1则会进位成2的幂。

## treeify
先了解下红黑树的基本性质
 - 节点分红/黑色 boolean red
 - 根节点 黑色
 - 红子节点的子节点黑色。
 - 每个叶节点（NIL节点 无数据） 是黑色
 - root到NIL的黑色节点数目相同

前文提到的TreeNode节点继承LinkedHashMap.Entry<K,V>
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/c1486e4b84d176b08f13429b383dd33e.png)

在两个类绕来绕去，和HashMap在1.8进行了树化改进有关系。历史原因。

treeify
```
final void treeify(Node<K,V>[] tab) {
    TreeNode<K,V> root = null;
    for (TreeNode<K,V> x = this, next; x != null; x = next) {
        next = (TreeNode<K,V>)x.next;
        x.left = x.right = null;
        // 设置为根
        if (root == null) {
            x.parent = null;
            x.red = false;
            root = x;
        }
        else {
            K k = x.key;
            int h = x.hash;
            Class<?> kc = null;
            for (TreeNode<K,V> p = root;;) {
                int dir, ph;
                K pk = p.key;
                if ((ph = p.hash) > h)
                    dir = -1;
                else if (ph < h)
                    dir = 1;
                else if ((kc == null &&  // key 为null
                          (kc = comparableClassFor(k)) == null) ||
                         (dir = compareComparables(kc, k, pk)) == 0) //class 类型不为null，但比较了还是相等
                    dir = tieBreakOrder(k, pk); //
                // 得出dir 插入位置
                TreeNode<K,V> xp = p;
                if ((p = (dir <= 0) ? p.left : p.right) == null) {
                    x.parent = xp;
                    if (dir <= 0)
                        xp.left = x;
                    else
                        xp.right = x;
                    root = balanceInsertion(root, x);
                    break;
                }
            }
        }
    }
    moveRootToFront(tab, root);
}
```
balanceInsertion 平衡插入后的节点
```
static <K,V> TreeNode<K,V> balanceInsertion(TreeNode<K,V> root,
                                                    TreeNode<K,V> x) {
    x.red = true;
    for (TreeNode<K,V> xp, xpp, xppl, xppr;;) {
        // 自底向上调整
        if ((xp = x.parent) == null) {
            x.red = false;
            return x;
        }
        else if (!xp.red || (xpp = xp.parent) == null)
            return root; // 循环出口
        if (xp == (xppl = xpp.left)) {
            if ((xppr = xpp.right) != null && xppr.red) {
                // xxpr 存在 and 为红色
                xppr.red = false;
                xp.red = false;
                xpp.red = true;
                x = xpp;
            }
            else {
                // xppr 不存在 or 黑色
                if (x == xp.right) {
                    root = rotateLeft(root, x = xp);
                    xpp = (xp = x.parent) == null ? null : xp.parent;
                }
                //
                if (xp != null) {
                    xp.red = false;
                    if (xpp != null) {
                        xpp.red = true;
                        root = rotateRight(root, xpp);
                    }
                }
            }
        }
        else {
            if (xppl != null && xppl.red) {
                xppl.red = false;
                xp.red = false;
                xpp.red = true;
                x = xpp;
            }
            else {
                if (x == xp.left) {
                    root = rotateRight(root, x = xp);
                    xpp = (xp = x.parent) == null ? null : xp.parent;
                }
                if (xp != null) {
                    xp.red = false;
                    if (xpp != null) {
                        xpp.red = true;
                        root = rotateLeft(root, xpp);
                    }
                }
            }
        }
    }
}
```
这篇的图解很详细
https://www.cnblogs.com/oldbai/p/9890808.html

```
/**
 * 左旋
 */
static <K,V> TreeNode<K,V> rotateLeft(TreeNode<K,V> root,
                                      TreeNode<K,V> p) {
    TreeNode<K,V> r, pp, rl;
    if (p != null && (r = p.right) != null) {
        //  --- rl 交给 pr
        if ((rl = p.right = r.left) != null)
            rl.parent = pk;
        // --- pp 不存在, root = r
        if ((pp = r.parent = p.parent) == null)
            (root = r).red = false;
        // --- pp 指向p 的指针 指向r
        else if (pp.left == p)
            pp.left = r;
        else
            pp.right = r;
        // --- 将p置为r的左节点
        r.left = p;
        p.parent = r;
    }
    return root;
}
```

缩写
p 父节点
pp 爷节点
r 父的右
rl 父的右的左节点
s  子节点left or right
单看网上旋转的结果图是很难理解的。
这段代码赋值后变量名的含义其实有变化。
自己把父子**双向**的引用变化过程画出来会比较清楚

忽略判空的话大概是这样一个过程
```
// rl 交给 pr
p.r = rl
rl.p = p
// pp 指向p 的son引用 指向r
r.p = pp
p.s = r
// 最后修改r和p左旋候的父子关系
r.l = p
p.p = r
```
注意一般修改时 都是配对修改 父节点的left/right引用, 子节点的parent

树化部分就基本如此

## putTreeVal

```
final TreeNode<K,V> putTreeVal(HashMap<K,V> map, Node<K,V>[] tab,
                               int h, K k, V v) {
    Class<?> kc = null;
    boolean searched = false;
    TreeNode<K,V> root = (parent != null) ? root() : this;
    for (TreeNode<K,V> p = root;;) {
        int dir, ph; K pk;
        if ((ph = p.hash) > h)
            dir = -1;
        else if (ph < h)
            dir = 1;
        else if ((pk = p.key) == k || (k != null && k.equals(pk)))
            // equals 找到相同的节点，外层赋值
            return p;
        else if ((kc == null &&
                  (kc = comparableClassFor(k)) == null) ||
                 (dir = compareComparables(kc, k, pk)) == 0) {
            // hash相等 equals不等，其中一个不是Comparable类型或者两者类型不同
            // 继续子树寻找
            if (!searched) {
                TreeNode<K,V> q, ch;
                searched = true;
                if (((ch = p.left) != null &&
                     (q = ch.find(h, k, kc)) != null) ||
                    ((ch = p.right) != null &&
                     (q = ch.find(h, k, kc)) != null))
                    return q;
            }
            dir = tieBreakOrder(k, pk);
        }

        TreeNode<K,V> xp = p;
        if ((p = (dir <= 0) ? p.left : p.right) == null) {
            // 新节点插入
            Node<K,V> xpn = xp.next;
            TreeNode<K,V> x = map.newTreeNode(h, k, v, xpn);
            if (dir <= 0)
                xp.left = x;
            else
                xp.right = x;
            xp.next = x;
            x.parent = x.prev = xp;
            if (xpn != null)
                ((TreeNode<K,V>)xpn).prev = x;
            moveRootToFront(tab, balanceInsertion(root, x));
            return null;
        }
    }
}
```

寻找过程其实和treeify 相似。
不过插入比树化多一种情况是需要判断相同key的节点。有则只需修改value

find 函数则是一个递归查找过程, 也是类似的
```
final TreeNode<K,V> find(int h, Object k, Class<?> kc) {
    TreeNode<K,V> p = this;
    do {
        int ph, dir; K pk;
        TreeNode<K,V> pl = p.left, pr = p.right, q;
        if ((ph = p.hash) > h)
            p = pl;
        else if (ph < h)
            p = pr;
        else if ((pk = p.key) == k || (k != null && k.equals(pk)))
            return p;
        else if (pl == null)
            p = pr;
        else if (pr == null)
            p = pl;
        else if ((kc != null ||
                  (kc = comparableClassFor(k)) != null) &&
                 (dir = compareComparables(kc, k, pk)) != 0)
            // 跟treeify 那个条件刚好相反。
            // hash相等 equals不等，都是Comparable类型且两者类型不同
            // 继续子树寻找
            p = (dir < 0) ? pl : pr;
        else if ((q = pr.find(h, k, kc)) != null)
            return q;
        else
            p = pl;
    } while (p != null);
    return null;
}
```

但最后面几个判断却并不是对称的，但本质还是递归去遍历查询
