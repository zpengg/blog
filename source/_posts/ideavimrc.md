---
title: 我的IDEA VIM设置 ideavimrc
copyright: true
date: 2020-04-25 23:00:38
tags: 
 - IDEA
 - VIM
categories: 工具
top:
---

## 背景
为什么需要用到IDEAVIM?

本机:MAC
开发环境:Ctrix云桌面

虽然IDEA 针对mac和win提供了不同系统的键位。
跨系统的云桌面会遇到 像mac-cmd alt-option 的限制。
不同的云桌面软件会有不同的映射。
选用win 键位,MAC中 按 opion 单键是传不进去Ctrix；
选用mac 键位,有时 按cmd键又会被 当前mac的组合键拦截掉

VIM 是通过“单键序列” 顺序按下多个键来 作为组合键，这样就不会有系统按键差异
IDEA中使用IDEAVIM插件可以使用VIM的这种特色
从而在多系统保持一致的开发体验。

## .ideavimrc
但是,IDEA VIM 也有自己的限制 比如说 搜索时的提示 就不如 IDE自身方便。
vim里可以通过.vimrc设置自己常用的按键序列 idea vim 也有类似的功能.
在 ~/.ideavimrc 里编辑, 通过Leader键去组合一些按键，关联上IDEA原有的Action操作

用Leader键开头也是为了尽量不与VIM原有的键位冲突
Leader 是 \ 键, 可修改,但为了不冲突，还是沿用比较好
```
:set keep-english-in-normal-and-restore-in-insert
set number
set scrolloff = 3
nnoremap <Leader>fd :action FixDocComment<CR>
nnoremap <Leader>r :action Replace<CR>
nnoremap <Leader>l :action ReformatCode<CR>
nnoremap <Leader>' :action ShowIntentionActions<CR>
nnoremap <Leader><CR> :action CodeCompletion<CR>
nnoremap <Leader>gi :action GotoImplementation<CR>
nnoremap <Leader>su :action ShowUsages<CR>
nnoremap <Leader>fu :action FindUsages<CR>
vnoremap <Leader>/ :action Find<CR>
vnoremap <Leader>./ :action FindInPath<CR>
nnoremap <Leader>/ :action Find<CR>
nnoremap <Leader>./ :action FindInPath<CR>
nnoremap <Leader>wm :action ActivateMavenToolWindow<CR>
nnoremap <Leader>wd :action ActivateDatabaseToolWindow<CR>
nnoremap <Leader>wt :action ActivateTeminalToolWindow<CR>
nnoremap <Leader>hh :action HideAllWindows<CR>
nnoremap <Leader>hh :action HideAllWindows<CR>
nnoremap <Leader>rcfg :action ChooseRunConfiguration<CR>
nnoremap <Leader>dcfg :action ChooseDebugConfiguration<CR>
nnoremap <Leader><Right> :action Forward<CR>
nnoremap <Leader><Left> :action Back<CR>
nnoremap <C-W>r :action MoveEditorToOppositeTabGroup<CR>
```
以上是个人常用的一些因按键有冲突, 而重新定义快捷键
不知道快捷键叫什么名，可以在keymap 设置中先找个大概的名称。
然后这些名称可以在:actionList命令中按字母顺序找到。基本是一样的

不冲突的情况下 在Win下使用Mac键位
可以设置win -> cmd（meta） 键
HELP-> Edit Custom Properties ..
```
keymap.windows.as.meta
```
还是可以部分使用到原有的一些 文件导航等快捷键, 直接用就好了
:set keep-english-in-normal-and-restore-in-insert
是另一个插件IDEA vim extendion 的配置
方便保证进入normal 模式时候 自动转换成 英文输入。

## 优点 & 缺点
优点：
云里云外，在家公司都是同一套操作

缺点:
别人不会用你的机子了, 你也不会用别人的机子了......
