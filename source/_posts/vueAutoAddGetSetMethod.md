---
title: vue 自动添加 get/set 方法的时机
date: 2020-03-24 23:42:59
tags: vue
---

```
data() {
    return {
        form: {
            prop1: '',
            prop2: []
        }
    }
}
methods: {
    getCache() {
        const temp = JSON.parse(window.localStorage.getItem(id));
        
        // 此时会为temp对象添加get/set 方法
        this.form = temp;
        // 此时不会添加get/set方法
        this.form.prop2 = [];
    }
}
```
如图中的optionParam 就失去了get/set 方法
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/5bc745aca58e64e71c7b16148068c620.png)

根据官方文档定义：如果在实例创建之后添加新的属性到实例上，它不会触发视图更新。
https://www.jianshu.com/p/71b1807b1815

form 对象 是有get set 方法 
给form 设置一个新对象 会为 对象中的属性添加getset方法

但之后再添加属性的过程是不会添加getset方法的。
