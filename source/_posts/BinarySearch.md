---
title: BinarySearch
tags:
  - leetcode
  - BinarySearch
categories:
  - leetcode
date: 2020-02-23 16:08:25
---

记录了一些官方提供的二分查找的模版，及做题时总结的左右边界迭代更新如何确定。 
 <!-- more -->

## 模版一 基本款
```
int binarySearch(vector<int>& nums, int target){
  if(nums.size() == 0)
    return -1;

  int left = 0, right = nums.size() - 1;
  while(left <= right){
    // Prevent (left + right) overflow
    int mid = left + (right - left) / 2;
    if(nums[mid] == target){ return mid; }
    else if(nums[mid] < target) { left = mid + 1; }
    else { right = mid - 1; }
  }

  // End Condition: left > right
  return -1;
}
```

搜索条件不需要通过相邻元素决定。
不需要后处理。

初始条件： left = 0， right = len - 1；
结束条件： left > right;
搜左边： right = mid-1；
搜右边: left = mid+1;

mid = left + (right - left) / 2;

需要注意的是 搜索条件放在前面,边界的思路会清晰点。
平常写的时候可能习惯性的拆开长判断

比如 Sqrt(x) 这题的 判断部分:
```
if(mid*mid>x){
    right = mid - 1;
} else if ((mid+1)*(mid+1) < x){ // 错误
    left = mid+1;
}else{
    return mid;// 这里的搜索条件不直观
}
```
```
//正确
if( mid * mid <= x && (mid + 1)* (mid + 1) >x){
    return mid;
}else if(mid*mid >x){
    right = mid-1;
}else {
    left = mid+1;
}
```
一眼看上去好像一样，但其实边界是有问题的。

## 变体2
```
int binarySearch(vector<int>& nums, int target){
  if(nums.size() == 0)
    return -1;

  int left = 0, right = nums.size();
  while(left < right){
    // Prevent (left + right) overflow
    int mid = left + (right - left) / 2;
    if(nums[mid] == target){ return mid; }
    else if(nums[mid] < target) { left = mid + 1; }
    else { right = mid; }
  }

  // Post-processing:
  // End Condition: left == right
  if(left != nums.size() && nums[left] == target) return left;
  return -1;
}
```

要访问右相邻元素决定 下个 搜索范围。
搜索范围需要保证至少有两个元素。
需要后处理，最终只有一个元素剩余，人需要判断 是否满足条件。

Initial Condition: left = 0, right = length
Termination: left == right
Searching Left: right = mid
Searching Right: left = mid+1

而isBadVersion 这题, 我边界的思路还是没处理好:
```
// Forward declaration of isBadVersion API.
bool isBadVersion(int version);

class Solution {
public:
    int firstBadVersion(int n) {
        if(n == 1){
            return 1;
        }
        int l = 1;
        int r = n;
        while(l<r){
            int mid = l + (r-l)/2;
            if(isBadVersion(mid) == false && isBadVersion(mid+1) ==true){
                return mid+1;
            }else if (isBadVersion(mid) == true){
                r = mid;
            }else{
                l = mid +1;
            }
        }
        return l;
    }
};
```

参考了一下，可以把最终的判断和return 留到循环外
循环里只用于缩小范围至跳出。

因为要找的值在 isBadVersion(）的右边，所以 mid 要确保在
isBadVersion(true)的地方。r = mid

若r = mid - 1 还有待确定。
原答案
```
bool isBadVersion(int version);

class Solution {
public:
	int firstBadVersion(int n) {
		int l = 1, r = n, mid;
		while (l < r)
		{
			mid = l + (r - l) / 2;
			if (isBadVersion(mid))
				r = mid;
			else
				l = mid + 1;
		}

		return l;
	}
};
```

总结:
最终确定 l/r 的迭代值时，最好先确定下 mid 还在不在搜索的范围中。
在的话可以将边界置mid。
不再的话边界可以按方向再挪动一位。

### 变体3
需要搜直接相邻的左右边界

### Search for a Range
这题需要搜左右边界,但不是直接相邻的。
其实分开两次搜两边感觉比较好
这里我直接搜到一个值去拓宽边界。
```
class Solution {
public:
    vector<int> searchRange(vector<int>& nums, int target) {
        vector<int> res = {-1,-1};
        int l = 0;
        int r = nums.size()-1;
        int mid;
        while(l<=r) {
            mid = l + (r-l)/2;
            if(nums[mid] == target){
                break;
            }else if(nums[mid]>target){
                r = mid -1;
            }else if(nums[mid]<target){
                l = mid +1;
            }else {
                r = mid;
            }
        }
        if(l>r){
            return res;

        }
        l = mid;
        r = mid;
        while(l>=0&&nums[l]==target){
            l--;
        }
        while(r<=nums.size()-1 && nums[r]==target){
            r++;
        }
        res = {++l, --r};
        return res;
    }
};
```

