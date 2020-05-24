---
title: maven-war-plougin 合并多个war工程
copyright: true
date: 2020-05-24 11:42:51
tags: maven
categories: maven
top:
---

父工程
```
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-war-plugin</artifactId>
    <version>3.2.2</version>
    <configuration>
      <overlays>
        <overlay>
          <groupId>com.xxx.xx<groupId>
          <artifactId>server-webapp</artifactId>
        </overlay>
        ...
      </overlays>
    </configuration>
 </plugin>

     ...
    <dependency>
      <groupId>com.xxx.xx</groupId>
      <artifactId>server-webapp</artifactId>
      <version>1.0.0</version>
        <type>war</type>
        <scope>runtime</scope>
    </dependency>

```
1.配置plugin 和 overlay 子项目
2.配置子项目依赖

最终父项目打出来的包
会用overlay的包 的文件替换同名文件

