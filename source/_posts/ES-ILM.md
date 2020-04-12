---
title: ES时序数据（索引生命周期管理）
copyright: true
date: 2020-04-12 11:31:11
tags: 
- ELK 
- ElasticSearch
categories: ElasticSearch
top:
---
## 背景
最初创建索引，没有特别处理。
随着时间增加，时序数据的数据量会不断上升，单索引文档过多时，搜索效率会下降，而且早晚会达到分片上限。
通常我们只关心最近时间的数据，时间过去越久，信息的价值就会下降。
最直接的办法是就是把过期的一些文档给删除掉。

## delete_by_query
scroll query/bulk delete 同理
**使用这些API删除数据效率较低**

>We could delete the old events with a scroll query and bulk delete, but this approach is very inefficient. When you delete a document, it is only marked as deleted (see Deletes and Updates). It won’t be physically deleted until the segment containing it is merged away.

```
curl -u 用户名:密码  -H'Content-Type:application/json' -d'{
        "query": {
                    "range": {
                                    "@timestamp": {
                                                        "lt": "now-7d",
                                                                            "format": "epoch_millis"
                                                                                            }
                                            }
                        }
}
' -XPOST "http://127.0.0.1:9200/*-*/_delete_by_query?pretty"
```

## 如何合理管理时间序列数据
2.x 的文档是这样说的
https://www.elastic.co/guide/en/elasticsearch/guide/current/time-based.html
文档中提到应该为索引建立别名

输入数据的业务系统用统一的别名,不用在修改索引时间切分方法时修改。
别名指向带时间后缀分割的实际索引名
\*\_YYYY-MM-dd

然后定期更新
```
POST /_aliases
{
      "actions": [
              { "add":    { "alias": "logs_current",  "index": "logs_2014-10" }}, 
              { "remove": { "alias": "logs_current",  "index": "logs_2014-09" }}, 
                  { "add":    { "alias": "last_3_months", "index": "logs_2014-10" }}, 
                      { "remove": { "alias": "last_3_months", "index": "logs_2014-07" }}  
        ]
}
```

另外也要提前建好索引模版,这样指向新index时,就不必重复设置 
## 7.x下的索引生命周期管理 ILM
现在使用的时7.4版本。
先说明几个操作概念
- rollover 重定向别名，跟上面说的基本一致
- shrink 减少一个索引中用到的主分片数量 
- force merge 合并分片中的 分段segment 释放空间
- freeze 变成只读
- delete 删除 永久移除一个索引

### 关联 生命周期策略，到 索引模版
ILM 提供一种 冷热分离结构
有hot-warm-cold-delet 四个阶段

### 使用ILM主要有四个步骤
1. 创建策略 定义什么阶段 有什么动作。
2. 创建模板关联索引
3. 初始化第一个写索引
4. 验证索引是否如期移动/删除

## rollover 如何命名
初始化索引按照【”-”+数字】的形式结尾）
rollover新创建的索引数字+1，es自动在前面以0补齐至6位数字
执行rollover后，别名logs的写指向最新索引，查询指向所有rollover下的索引。

## 自动rollover
有些博客提到要定时持续调用 \_rollover 接口
我以max_docs:2 测试过，插入3条数据时是不会马上触发rollover的
但等个（默认）10 分钟后再看，发觉是会自动rollover了 (v7.4)
    可以在集群设置里修改


## 将原有索引加入生命周期管理
将新数据写入到新的ILM管理的索引中
老索引可以通过应用另外的过期策略，主动过期
也可以通过reindex加入到新索引，但此时会混合新旧数据到同一索引中，直到满足了新策略

## 总结
1.所有索引必需有别名。相当于接口。
    可以避免写入方频繁修改。
    可以通过切换写索引，来对索引的一些设置mapping等进行修改。

2.新建的时序数据的索引，无论大小都可以尽量使用ILM去管理。
    小数据量的可以根据max_docs 去配置
    大数据量的可以按时间去配置。

3.有些配置数据，失效时间未必与插入文档的时间有明确的关系。比如活动排期此类非时序的配置。
    可以根据业务逻辑设定长一点的过期时间
    数据量特别少的话直接用别名管理也可以,日后有需要再加ILM。






