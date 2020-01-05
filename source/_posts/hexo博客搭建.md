---
title: hexo博客搭建
tags:
  - 生活
  - 效率
  - 工具
categories: 工具
date: 2020-01-06 00:45:57
---

年前开始做题发觉敲完代码，最好还能够记录下来中间的一些思考过程，因此想用git记录下来。
不过写了几次之后发觉，这些文档/代码在管理上有些混乱。
查阅了一下资料，发觉可以用hexo 搭建博客 放到 github page上。然后博客提供一些简单的基于tag/category的分类方式去整理文章。
## hexo + github 搭建博客
``` bash
$ npm install hexo-cli -g
$ hexo init blog
$ cd blog
$ npm install
$ hexo server
```
修改 \_config.yml 文件可以指定自己的github仓库,选用master分支（github page限制）
```
deploy:
  type: 'git'
  repository: git@github.com:zpengg/zpengg.github.io.git
  branch: master
```
hexo g -d 就可以部署上github了
## github action 部署
这时如果你把这个博客文件夹删掉的话，就再也找不回来以前的文章了。
只有生成的静态页面了。
所以我们也最好把源文件也放到github上
在仓库创建一个分支，拉下来，然后删掉里边的hexo生成的静态文件，把源文件托管上去

源文件托管之后。平时每次写完文章还得调用hexo的命令去部署，还是有点麻烦的。可以使用持续集成来帮我们避免重复执行这些命令。常用的有travis-CI，不过最近github也有提供了github Action。两个都没用过，挑了github Action试试
[https://gythialy.github.io/deploy-hexo-to-github-pages-via-github-actions/](https://gythialy.github.io/deploy-hexo-to-github-pages-via-github-actions/)
按着这个生成 ssh 及 yml 文件就可以了
注意修改一些自己的信息，私钥命名注意要和自己的相同
## 使用submodule 管理主题
这里使用了next的主题，扩展性很高，可以看官方文档介绍。
很多主题的文档建议直接在 themes/下clone主题, 但由于git仓库嵌套, 这时候是没法一起和博客源文件托管到GitHub 上
这篇文章提到，因为主题里也通常需要定制自己的信息,我们可以先fork主题到自己的github上，再在博客里创建subomdule

``` bash
$ cd zpengg.github.io
$ git submodule add https://github.com/zpengg/hexo-theme-next themes/next
```
以上命令可以关联起来，然后再拉取主题
``` bash
$ cd zpengg.github.io
$ git pull
$ git submodule update --init
```
中途配置出错，想删掉主题的话也注意也不要直接删目录，这样不完整，可以使用命令移除，并提交仓库。
``` bash
$ git rm --cached 子模块 
```
博客目录下 \_config.yml 指定theme
这时候本地hexo s是可以看到主题变化了
假设你已经按上面配置好了action，估计会看到个**空白的页面**

别慌！

原因是
配置好主题后，github Action也要添加相应的子模块update命令，不然就等于我们拉了博客仓库代码到本地然后没有主题一样。

## 图床
github仓库空间有限制，所以最好还是使用图床服务，网上大多数都推荐使用七牛，这里有一个工具可以把截图上传七牛，先记录一下  
[https://github.com/tiann/markdown-img-upload](https://github.com/tiann/markdown-img-upload)

每天回家有点晚，一周没做题,感觉也是有点慌。
也就断断续续的搞了一下博客，也记录下搭博客的问题，算是磨刀不误砍柴工吧。。
