---
title: JS正则表达式,数字千分位补逗号
copyright: true
date: 2020-04-21 19:33:40
tags: 
 - JS
 - 正则表达式
categories: JS
top:
---
```
function formatCommaNumber(number, fixed){
    return number.toString.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
}
```

补充一个没有小数的
```
str.replace(/\B(?=(?:\d{3})+\b)/g, ',');
```

此处正则匹配为两组
```
// 数字 分组1
(\d)
// ?=断言, 找到三位数字（多次）加小数点结尾的字符串  分组2
(?=(\d{3})+\.)
```

知乎上有人推荐了个工具,对新手比较友好。。
https://regex101.com/#javascript
可以看到更加详细的解析
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/03fa41c19401bed62a0997c90fc12e47.png)

## zero-width-assertions(零宽度断言)
匹配的是一个**位置**。
< -- lookbehind
空白 -- lookahead
! -- Negative
= -- Positive

(?=pattern) Positive Lookahead
该位置后面 能匹配 pattern

(?!pattern) Negative Lookahead
该位置后面 不能匹配 pattern

(?<=pattern)
该位置前面 能匹配 pattern

(?<!pattern)
该位置前面 不能匹配 pattern

(?:pattern)
例如“industr(?:y|ies)”就是一个比“industry|industries”更简略的表达式。

