---
title: 如何给ES 索引设置合适的 ILM策略 和 分片数值
copyright: true
date: 2020-04-25 22:42:16
tags: ElasticSearch
categories: ElasticSearch
top:
---

## 背景
线上设置了几个一天Rollover 一次的索引。 然后之前数据设置了14天删除
几天之后就新建了几十个索引了。别人告知可能会有性能问题。

## 如何设置
针对索引建多少个，分片设置多少个比较合理
找到了官方指导
https://www.elastic.co/cn/blog/how-many-shards-should-i-have-in-my-elasticsearch-cluster

主分片 shard 可以处理索引请求
副本 replica 可以提升读和备份

写入分片的数据会定时 发布到 磁盘Lucene分段
对于每个 Elasticsearch 索引，映射和状态的相关信息都存储在集群状态中。这些信息存储在内存中，

**分片数量增加会消耗资源**

>提示： 分片过小会导致段过小，进而致使开销增加。您要尽量将分片的平均大小控制在至少几 GB 到几十 GB 之间。对时序型数据用例而言，分片大小通常介于 20GB 至 40GB 之间。

>提示： 由于单个分片的开销取决于段数量和段大小，所以通过 forcemerge 操作强制将较小的段合并为较大的段能够减少开销并改善查询性能。理想状况下，应当在索引内再无数据写入时完成此操作。请注意：这是一个极其耗费资源的操作，所以应该在非高峰时段进行。

>提示： 每个节点上可以存储的分片数量与可用的堆内存大小成正比关系，但是 Elasticsearch 并未强制规定固定限值。这里有一个很好的经验法则：**确保对于节点上已配置的每个 GB的堆内存，将分片数量保持在 20 以下**。如果某个节点拥有 30GB 的堆内存，那其最多可有 600 个分片，但是在此限值范围内，您设置的分片数量越少，效果就越好。一般而言，这可以帮助集群保持良好的运行状态。

/_cat/indeces?v 查看索引状态 平时可以多关注数据量, 但最好还是写入前预估好

举个例子
目前遇到的数据1天2g数据, 日常只关注7天内数据。
可以设置为

```
PUT _ilm/policy/1g_policy?pretty
{
    "policy":{
        "phase":{
            "hot":{
                "actions": {
                    "rollover": {
                        "max_age": "15d"
                    }
                }
            },
            "delete": {
                "min_age": "15d"
                "actions": {
                    "delete":{}
                }
            }
        }
    }
}
```
差不多是用到

而一些配置数据一天也没多少条的, 可以按容量或者max_doc来算(估计有生之年都不一定会发生roll-over）
```
PUT _ilm/policy/small_policy?pretty
{
    "policy":{
        "phase":{
            "hot":{
                "actions": {
                    "rollover": {
                        "max_size": "10gb" 
                    }
                }
            },
            "delete": {
                "min_age": "15d"
                "actions": {
                    "delete":{}
                }
            }
        }
    }
}
```

修改索引模版策略，不会对之前的索引产生影响的。
原有的索引 会按原有策略继续执行