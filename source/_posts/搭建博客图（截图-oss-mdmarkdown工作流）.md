---
title: 搭建博客图床（截图，同步云存储，返回markdown链接）
date: 2020-01-23 23:05:04
tags: 
- Markdown
- 工具
- 图床
- 博客搭建
categories: 工具
---
## MarkDown 写字工具使用历程
#### 笔记软件
最早是在笔记软件上做笔记的。笔记工具提供了较好的**整理&同步**
本和md模式，但以前用富文本编辑的笔记，感觉跟自己手写的一样，
。另外通常笔记软件导出也不太方便。
#### 编辑器
常见有两类
一类是左右分栏对比的
 - 各类编辑器自带/插件基本都提供了这种功能，看代码文档常用
 - CSDN 简书等 编辑器
 - 作业部落 
基本提供了正常的展示。
常见的还有**tag分类**、同步、**vim**等。
同步的话，最初还想用git来实现，不过好像在公司这么个操作法还是
博客网站的话相当于自带**图床**了，但是不同网站之间图片访问又
另一类是编写完立刻渲染, 所写即所见
 - Typora，使用流畅，最初
 - [MarkText](https://www.v2ex.com/t/464384) 比typora多了图床
 - 语雀, 这个做文档库感觉功能挺全的。
刚开始是有被惊艳到的，但是使用着发觉要用多一套快捷键。
另外直接整理文件也是不太好的。使用tag分类会多维度一点，更为合
综上，想找到一个满足以下条件的：
 - 多维度整理分类
 - 编辑体验一致性 （最好是VIM）
 - 共用一套图床
 - 同步
 - 流畅
 
后来，发觉hexo 的博客搭了之后，文档整理，同步等功能基本解决。
然后编辑使用 VIM 和 作业部落 也基本解决。
至此，剩下的就是图床问题了。
## 图床搭建
考虑到要访问不受限制，最好还是搭建自己的图床。
 - [sm.ms](https://www.v2ex.com/t/182703)marktext也是用的这个
 - 各类云服务的对象存储。最后精打细算挑了阿里云9块一年。个人
日常写字，使用图片的流程，基本就是以下步骤：
1. 截图
2. 保存图片
3. 已有图片上传
4. 图片URL按MD的格式填入文章里。
网上找到两个工具
[pngpaste 仅限于mac](https://github.com/jcsalterego/pngpaste)
可以保存截图，不过windows下无法用。brew 安装
brew install pngpaste
[qiniu4blog](https://github.com/wzyuliyang/qiniu4blog)
python实现的,可以监听文件夹，上传增改的文件，使用了另一位开发
pip install oss4blog
oss4blog需要在～/oss4blog.cfg配置自己的阿里云子账户
```
[config]
Bucket = zpengg
AccessKeyId = lLLLLLLLLLLLLLLlllllllll
AccessKeySecret = 6888888888888888888888888888m3
PathToWatch = /Users/***/DDDDDDDDD/llll/image
Endpoint = oss-cn-shenzhen.aliyuncs.com
SubPath = img/
[custom_url]
Enable = false
CustomUrl = custom
```
SubPath是自己找源文件加的，把这些截图统一放img/下。
再创建一个脚本simg.sh，需要保存截图的时候运行一下。
``` bash
#!/bin/bash -eu
dir=" /Users/***/DDDDDDDDD/llll/image"
remote_dir="http://zpengg.oss-cn-shenzhen.aliyuncs.com/img"
tmp_file=$(mktemp)
pngpaste $tmp_file
hash=$(md5 < $tmp_file)
img="/$hash.png"
remote_img="$remote_dir$img"
mv $tmp_file "$dir$img"
echo "![]($remote_img)" | tee >(pbcopy)
```
需要全局运行的话还可以需把脚本目录添加到PATH
![测试图床](http://zpengg.oss-cn-shenzhen.aliyuncs.com/img/cf34786ffef143ce3b8c3de4927b33b8.png)

目前使用上，感觉还可以压缩一下图片，日后再补。
