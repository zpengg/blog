---
title: 3.1 Implement strStr() 
date: 2020-02-17 21:03:12
tags: leetcode, KMP
categories: leetcode
---
试图搞懂KMP算法的next数组
<!--more-->
kmp算法，算法题字符串处理中是常遇到的。
但据说java寻找子串的方法其实也是暴力法。
每次做完还是会晚，决定这次用自己的思路来实现一下。
## 题目
Implement strStr().

Return the index of the first occurrence of needle in haystack, or -1 if needle is not part of haystack.

Example 1:  

Input: haystack = "hello", needle = "ll"  
Output: 2  

Example 2:

Input: haystack = "aaaaa", needle = "bba"  
Output: -1  

### 暴力法
先看看暴力逐个对比
ori: 源串  
at: 模版串
``` c++
int strStr( string ori, string pat){
    int i=0, j=0;
    while(i<ori.size()&& j<pat.size()){
        if(ori[i]!= pat[j]){ //不等
            j=0;
            i=i-j+1;
        }else{ // 相等
            i++;
            j++;
        }
   } 
   
    if(j== pat.size()){
        return i-j;
    }else{
        return -1;
    }
    
}
```
### 优化重复的比较过程
那么来看看一个匹配的中间过程例子  
|origin 串|...|...|...| ori[i]| ...|
|-|-|-|-|-|
|pattern 串|...| pat[k]|...|pat[j]|...|
|移动后pattern 串| | |...|pat[k]

关注不匹配的时候，假设现在比较到i和j，即0～j-1是已匹配的。   
暴力法 k = j-n 只移动n=1位，同时要把i=i-j，j=0回退，然后又把0-k比较了一次。  
然而0~j部分其实是已匹配的,对于已匹配部分，其实是pattern 与 移位的pattern串自身的比较。
假如pattern自身有重复的部分，其实是可以 不用 0到k 从新比较一遍,此时i是不必回退的。
比如
ori: aaaab  
pat: aab  
> pattern串应该向右移动到什么地方? 停止移动时又应该有什么特性呢？

假设应该要移动到k位置，k=next[j]
|pattern 串|pat[0]|...| pat[j-k]|...|pat[j-1]|...|
|-|
|pattern 串| | |pat[0]|...|pat[k-1]|...|

移动到[j-k, j-1] 与 [0, k-1] 第一次相等的时候即可继续进行后续字符串的比较。
这时候[j-k, j-1]为已匹配部分的后缀， 而[0, k-1] 是字符串的前缀。
而第一次相等时候，意味着最长的前后缀,长度为k。
k可以提前通过比较字符串获得,因此可以得到 完整的next[j]数组

### 经验
第一次写完之后。
 - 其实暴力法挺快的。因为毕竟不是所有字符串都有这么多重复子字符串。 
 - 最初把next定义成了需要一动的距离，然后导致了以下一下列的问题。
 - 中途遇到好多因为0或者pattern.size（）没处理好的BUG。
 - 另外,执着于用for循环，最好的i++ j++ 没处理好。也是不够灵活。
 - 最终一些多余判断也可能会影响性能。

另外还有个c++基础不牢的引起的问题：
> 当进行int型与size()、length()返回值比较时，特别要注意返回值进行相关运算后可能出现的负数，这时将会发生类型转换。  尽量取成局部变量取比较比较好。

### next[0] 的意义
补充考虑j=0还失配的情况,
|i=0|-|-|
|-|
|A|B|C|
|C| | |
|j=0| | |

|-|i=1|-|
|-|
|A|B|C|
||C||
|j=-1|j=0||
此时应该让 i++；j=0; 继续下一步的比较。

也有人理解为 刚好让 j = next[j]= -1；再更新i,j,next[i]
先翻回暴力法，改写下不适配时的更新过程。(其实暴力法我是后来才写的)
``` c++
int strStr( string ori, string pat){
    int i=0, j=0;
    int l_ori = ori.size();
    int l_pat = pat.size();
    while(i<l_ori&& j<l_pat){
        if(ori[i]!= pat[j]){ //不等
            if(j==0){
                i++;
            }else{
                //i不用动；
                //跳转更新j;
                j = next[j];
            }
        }else{ // 相等
            i++;
            j++;
        }
   } 
   
    if(j== pat.size()){
        return i-j;
    }else{
        return -1;
    }
}
```

找next数组时，我之前其实是直接滑动着去求。是从最长的开始判断。
这样的话也是没有利用好已有的信息。

看了这篇文章，发觉 j位失配的最长相同前后缀，是可以通过j-1位求出来的。
https://www.cnblogs.com/yjiyjige/p/3263858.html
我们获得了一个字符串的最长前后缀,在此基础上加上一个字母。
我们可以找到上次前缀的下一位来比较即可:  

从中间的一次迭代举个例子：  
比如已知  
DBADB\*\# 
对DBADB 子字符串求前后缀 next[5] = 2  
此时后缀i=5 指着\*
前缀k=2 指着C

那么我们对ABCAB\*求前后缀的的时候,有两种情况
```
if(pat[i] == pat[k]){
    // * is A
    // DBADBA#
    next[i+1] = k + 1;
    i++;
    k++;
}else{
    // * is not A
    // DBADBD#
    // 此时相当于失配的情形，DBA！=DBD
    // 但前缀的前缀 还可能与 后缀的后缀相等,此处为 i=0 的D 和 i=5的D 
    // 用next数组更新下k = 1 的情况
    // i不需要动位置
    
    k = next[k]  
}
```

所以再套层循环。这次还用while来写感觉会清晰点。

```
vector<int> nextHelper(string pat){
    vector<int> next;
    next.resize(pat.size());
    next[0] = -1; // 该位置用不上，设置为非法值 
    //至少2位开始才有前后缀
    //错位开始比较
    int i = 1;
    int k = 0; 
    int len = pat.size();
    while(i<len-1){
        if(pat[i]!= pat[k]){ //不等
            // 相当失配时的更新公式
                if(k == 0){
                    //没找到前后缀
                    i++;
                    next[i]=0;
                    continue;
                }else{
                    k =  next[k];
                }
        }else{ // 相等
               i++;
               k++;
               next[i] = k;
        }
    }
    return next;
} 
```

这道题前前后后做个几遍了，以前算是记住答案就算了。  
但这种其实还是很容易忘记的，思路上要自己踩到坑点，才容易记住。  
