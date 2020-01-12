---
title: 2.2 Tranverse
tags: leetcode
categories: leetcode
date: 2020-01-13 00:04:47
---

##### NO.496
Given a matrix of M x N elements (M rows, N columns), return all elements of the matrix in diagonal order as shown in the below image.
#### 图床还没建 以后补上

#### Input:
[
 [ 1, 2, 3 ],
 [ 4, 5, 6 ],
 [ 7, 8, 9 ]
]

#### Output:  [1,2,4,7,5,3,6,8,9]
``` c++
class Solution {
public:
    vector<int> findDiagonalOrder(vector<vector<int>>& matrix) {
        vector<int> v;  
        // row
        int m = matrix.size();
        // col
        if(m == 0) return v;
        int n = matrix[0].size();
        if(n == 0) return v;
            
        // 此处之前一直写成了 int i,j =0; 导致一致出现越界问题；
        // 印象中以前好像java一直是这么写的。。
        int i,j =0;
        for(int route = 0; route <m+n-1; route++){
            while(i<m&&j<n){
                v.push_back(matrix[i][j]);
                if(route%2 ==0){
                   if(j==n-1){
                       i++;
                       break;
                   }else if(i==0){
                       j++;
                       break;
                   }else{
                       i-=1;
                       j+=1; 
                   }
                }else{
                   if(i==m-1) {
                       j++;
                       break;
                   }else if(j==0){
                       i++;
                       break;
                   }else{
                       i+=1;
                       j-=1;
                   }
                }
                
            }

        }
        return v;
    }
};
```
### 思路
路线会来回换方向。跟路线的奇偶有关
然后碰边会返回；
向上碰边 往右走
向右碰边 往下走；
同时碰上右 也是往下走；

下左一样；
直至出界；

### 收获
这次其实很早写好了。但是一直报越界。
这周晚上加班都有点严重，断断续续的搞vector如何初始化，每次刚熟悉了点又太晚了要睡觉了。
c++ 的语言基础还是掌握的不好。肉眼调bug 没调出来。
最后还是借助playground 中 打印了信息 才发觉是变量初始化的问题；

回头看看java 的初始化也是有讲究的：
定义为类的属性自然赋值0
定义为方法的局部变量一定要初始化
后来试了下 int i，j = 0; 这种写法还是有问题的，要避免.

而c++
在全局域中声明 会自动初始化为0;
而在局部也是要初始化；


