---
title: leetcode 4.寻找两个正序数组的中位数
copyright: true
date: 2020-05-30 18:41:30
tags: leetcode
categories: leetcode
top:
---

参考官方答案：

数组长度 n
奇数 中位数idx `int mIdx = n/2`
偶数 中位数idx `int mIdxL = n/2 -1, mIdxR = n/2;` 需要计算两者平均值

有序数组中求指定位置。
但要注意 idx 是从0开始的。 对应的是第 k = idx + 1 小的元素

``` java
class Solution {
    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
        int length1 = nums1.length;
        int length2 = nums2.length;
        int total = length1 + length2;
        if (total % 2 == 1 ){
            int mid = total/2;
            double median = getKthElement(nums1, nums2, mid + 1);
            return median
        }else{
            int midIndex1 = totalLength /2 -1 , midIndex2 = totalLength/2;
            double median = (getKthElement(nums1, nums2, midIndex1 +1) + getKthElement(nums1, nums2, midIndex2 + 1));
            return median;
        }
}
```

第k小 可能落在两个数组其中一个上。
分布不均匀的话,最远可能落在一个数组上的k-1 位置,
分布均匀点的话, 可能落在一个其中一个数组上的half = k/2 位置,

那我们可以先比较 两个数组的 k/2 - 1 位置上的值,
比较
int newIndex1 = Math.min(index1+half,l1) -1;
int newIndex2 = Math.min(index2+half,l2) -1;

每次最多可以排除 index 到 newIndex 的值, 一共 newIndex - index +1

``` java
if(pivot1 <= pivot2){
    k -= (newIndex1- index1 +1);
    index1 = newIndex1+1;
}else {
    k -= (newIndex2- index2 +1);
    index2 = newIndex2+1;
}

```

补上其中一个数组越界时退化成一个有序数组的第k小问题。
``` java
/**
* 两个有序数组的第K小
*/
public int getKthElement(int[] nums1, int[] nums2, int k){
    int l1 = nums1.length, int l2 = nums2.length ;
    int index1 = 0;
    int index2 = 0;
    int kthElement = 0;
    while(true){
        // tui
         if (index1 = l1){
            return nums2[index2 + k-1];
        }
        if (index2 = l2){
            return nums1[index1 + k-1];
        }
        if( k == 1){
            return Math.min(nums1[index1], nums2[index2]);
        }
        int half =k/2;
        int newIndex1 = Math.min(index1+half,l1) -1;
        int newIndex2 = Math.min(index2+half,l2) -1;
        int pivot1 = nums1[newIndex1];
        int pivot2 = nums2[newIndex2];
        if(pivot1 <= pivot2){
            k -= (newIndex1- index1 +1);
            index1 = newIndex1+1;
        }else {
            k -= (newIndex2- index2 +1);
            index2 = newIndex2+1;
        }
    }

}

```

一开始一直在纠结为什么是要比较k/2 - 1 位置上的值,
为什么不直接k/2
是因为比较过程不是为了直接得到具体位置，而是为了排除,缩减k
直到让k =1；或者其中一个数组全被排除
