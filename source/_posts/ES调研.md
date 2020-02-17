---
title: ElasticSearch基本概念&常见问题
date: 2020-02-17 23:28:13
tags:
 - ElasticSearch
 - Kibana
 - ELK
 - ES
categories: ElasticSearch
---
新安排的项目需要用到ElasticSearch作为数据存储和聚合分析, 官方的文档还是很详细的。  
虽然我觉得官方的client也挺好用的,但项目需要用到ESSQL,所以特别关注了这块的一些点。  
<!--more-->
## ELK
Elastic Stack(ELk) 相关产品
 - Elasticsearch 一个基于JSON的分布式搜索和分析引擎
 - Kibana 可视化、一个可扩展的用户界面
 - Beats 采集数据工具
 - Logstash 第三方数据库中提取数据
     
## 概念
  集群  
  节点  
  类型type  
  文档doc  
  索引index  
  分片shard  
  副本replica  

### index/type/doc
类比  
ES：indices --> types --> documents --> fields  
DB：databases --> tables --> rows --> columns  

documents为JSON形式  
### 分片shard
需要配置一个主分片数量，并永不再改变  
默认设置5个主分片  
ES 的每个分片（shard）都是lucene的一个index，而lucene的一个index只能存储20亿个文档，所以一个分片也只能最多存储20亿个文档。  

分片选择公式
shard = hash(routing) % number\_of\_primary\_shards  
routing 默认为文档id  

分片数过多会导致：  
1、  会导致打开比较多的文件  
2、  分片是存储在不同机器上的，分片数越多，机器之间的交互也就越多；  

分片数太少导致：  
单个分片索引过大，降低整体的检索速率  

将单个分片存储存储索引数据的大小控制在20G左右；绝对不要超过50G ， 否则性能很差
最终分片数量 = 数据总量/20G  

### 副本replica
主分片不可用时，集群选择副本提升为主分片。  
ES禁止同一分片的主分片,副本在同一个节点上。   
比如两个节点其中 node1 有某个索引的分片1、2、3和副本分片4、5，node2 有该索引的分片4、5和副本分片1、2、3。  
replication 配置 默认为sync，即修改完成后，同步到其他节点后，才返回结果到客户端。  

## 原理
trie字典树: 根据前缀快速找到单词。  
倒排索引: 将doc分词后倒过来建立索引 词value -> key(docId) -> doc  
索引缓存在内存中  

## 安装Elastic Search
启动脚本需要java8, 但101.3 java7？  

下载地址 elasticsearch.org/download  

elasticsearch/bin/elasticsearch 脚本运行  

提供两个端口进行访问  
 - 9300 java API
 - 9200 http RESTful API

浏览器127.0.0.1:9200 访问后可以看到   
![](http://zpengg.oss-cn-shenzhen.aliyuncs.com/ca2accf57de7ad4b7f99a97e8c857790.png)  
即运行成功, 节点版本为5.6.4。 开发时要选择匹配的版本的客户端进行请求。

### Kibana
kibana 默认端口5601 

kibana 可使用devTools  
可使用以下格式测试请求  
      GET /megacorp/employee/_search


## JAVA 客户端
ES Java 客户端目前主要提供两种方式，分别是 Java API 和 Java REST Client：  

Java API：https://www.elastic.co/guide/en/elasticsearch/client/java-api/current/index.html，其使用的核心传输对象是 TransportClient。但是 Elastic 官方已经计划在 Elasticsearch 7.0 中废弃 TransportClient，并在 8.0 中完全移除它，并由 Java High Level REST Client 代替。官网声明如下：https://www.elastic.co/guide/en/elasticsearch/client/java-api/current/client.html  

Java REST Client：https://www.elastic.co/guide/en/elasticsearch/client/java-rest/current/index.html，Java REST Client 又分为两种，Java Low Level REST Client 和 Java High Level REST Client。目前官方推荐使用 Java High Level REST Client。  

目前有flummi、Jest、还有国人开发的bboss。非官方封装的client。  
但更推荐使用官方支持的 Java High Level REST Client、或者spring-data-elasticsearch。  

spring-data-elasticsearch, 复杂的mapping可以自动完成，无需额外创建mapping。但版本要与spring版本匹配.  

所以使用Java High Level REST Client 更为合适。  
      
另附5.6的文档
      [API](https://artifacts.elastic.co/javadoc/org/elasticsearch/client/elasticsearch-rest-high-level-client/5.6.16/index.html)  
      [请求示例](https://www.elastic.co/guide/en/elasticsearch/client/java-rest/5.6/java-rest-high-document-get.html)  

## 基本操作
通过HTTP方法GET来检索文档，同样的，我们可以使用DELETE方法删除文档，使用HEAD方法检查某文档是否存在。如果想更新已存在的文档，我们只需再PUT一次。  
```
POST /index/type/xxx 创建
DELETE /index/type/xxx 删除
PUT /index/type/xxx 更新或创建
GET /index/type/xxx 查看
```
> 相应的JAVA中提供的API包含了检查存在exist，增index/create、删 delete、改index/update、查search。并提供带Async后缀的异步API。批量操作，查询ES基础信息等API

### 插入index/create
第一步判断是确定插入的文档是否指定id，如果没有指定id，系统会默认生成一个唯一id。这种情况下，不管index还是create会直接add文档。如果用户指定了id，那么就会走底层Lucene update，成本比Lucene add要高。  

第二步判断，是通过id来get文档版本号检查是否冲突，但无论是index还是create都不会get整个doc的全部内容，只是get出了版号。这也从一定程度上减少了系统开销。

index时会检查\_version。如果插入时没有指定\_version，那对于已有的doc，\_version会递增，并对文档覆盖。插入时如果指定\_version，如果与已有的文档\_version不相等，则插入失败，如果相等则覆盖，\_version递增。  

create使用内部版本控制，传入\_version会冲突  


### 更新update
底层Lucene update 实际上是先删除后创建,性能也比 Lucene add 差。  
Es update都会调用 InternalEngine中的get方法，来获取整个文档信息，从而实现针对特定字段进行修改，这也就导致了每次更新要获取一遍原始文档，性能上会有很大影响。所以根据使用场景，有时候使用index会比update好很多。  

### 搜索search
#### 简单搜索
```
GET /megacorp/employee/_search
```
不加条件，默认返回前10条
```
{
   "took":      6,
   "timed_out": false,
   "_shards": { ... },
   "hits": {
      "total":      3,
      "max_score":  1,
      "hits": [
         {
            "_index":         "megacorp",
            "_type":          "employee",
            "_id":            "3",
            "_score":         1,
            "_source": {
               "first_name":  "Douglas",
               "last_name":   "Fir",
               "age":         35,
               "about":       "I like to build cabinets",
               "interests": [ "forestry" ]
            }
         },
         {
            ...
         },
         {
            ...
         }
      ]
   }
}
```
查询语句可以附带参数 q=fieldName:xxx
```
GET /megacorp/employee/_search?q=fieldName:xxx
```
#### DSL 语句查询  
term：查询某个字段里含有某个关键词的文档, 只能查单个词  
terms：查询某个字段里含有多个关键词的文档, 多个词 或关系  
match: 知道分词器的存在，会对field进行分词操作，然后再查询  
match_phrase: 短语搜索，要求所有的分词同时出现在文档中，位置紧邻。  
...  
可以查看[更多查询](https://www.elastic.co/guide/en/elasticsearch/client/java-rest/5.6/java-rest-high-query-builders.html)  
```
GET /megacorp/employee/_search
{
    "query" : {
        "match" : {
            "last_name" : "Smith"
        }
    }
}
```
```
GET /megacorp/employee/_search
{
    "query" : {
        "filtered" : {
            "filter" : {
                "range" : {
                    "age" : { "gt" : 30 } <1>
                }
            },
            "query" : {
                "match" : {
                    "last_name" : "smith" <2>
                }
            }
        }
    }
}
```

#### 全文搜索
会同时返回 含相关字段的结果 和 相关性评分   
```
GET /megacorp/employee/_search
{
    "query" : {
        "match" : {
            "about" : "rock climbing"
        }
    }
}

{
   ...
   "hits": {
      "total":      2,
      "max_score":  0.16273327,
      "hits": [
         {
            ...
            "_score":         0.16273327, <1>
            "_source": {
               "first_name":  "John",
               "last_name":   "Smith",
               "age":         25,
               "about":       "I love to go rock climbing",
               "interests": [ "sports", "music" ]
            }
         },
         {
            ...
            "_score":         0.016878016, <2>
            "_source": {
               "first_name":  "Jane",
               "last_name":   "Smith",
               "age":         32,
               "about":       "I like to collect rock albums",
               "interests": [ "music" ]
            }
         }
      ]
   }
}
```

### 聚合
分为以下几种：  
指标聚合 Metrics Aggregation: 需要计算指标的,如平均值、最大最小值  
桶聚合 Bucket Aggregation: 给定边界，数据落入不同分类的桶中  

管道聚合（v5.6是实验性） Pineline Aggregation：将其他聚合结果基础上进行聚合 比如 每月 sum（sell）之后求 max 
矩阵聚合（实验性）  

桶聚合的结果，每个桶代表一组文档，因此桶聚合可以嵌套对里面的数据进行聚合  
除了矩阵聚合，其他几种都可以加上脚本简单计算（相当于自定义指标）  

> 5.x后对排序，聚合这些操作用单独的数据结构(fielddata)缓存到内存里了，需要单独开启，官方解释在此[fielddata](https://www.elastic.co/guide/en/elasticsearch/reference/current/fielddata.html)

> text类型的字段是要分词的, 默认不能作为field字段作为聚合用。Fielddata is disabled on text fields by default



### java RestHighLevelClient 请求示例

查询请求模版  
```
//构造查询请求
SearchRequest searchRequest = new SearchRequest(); 
SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder(); 
searchSourceBuilder.query(QueryBuilders.matchAllQuery()); 
searchRequest.source(searchSourceBuilder); 
//查询
SearchResponse resp = client.search(searchRequest);

// 插入等有类似IndexRequest 不再列举。
```

聚合请求  
![agg](http://zpengg.oss-cn-shenzhen.aliyuncs.com/613e47cdc9ae1215e9bcbdcf162ffd25.png)
请求结果  
![aggResult](http://zpengg.oss-cn-shenzhen.aliyuncs.com/c04d0cd995c0088b454e164c88ca9798.png)


## ES SQL
以上提到的，是dsl语句查询。
另有兼容sql的查询方法，但目前与目前测试机器上的版本不匹配。
5.x需要安装相关[插件](https://www.jianshu.com/p/b4032a7e5497)

V6.3开始官方提供sql查询，但有取消的可能。
SQL 特性是 xpack 的免费功能，语法为直接把sql语句从query传入
```
POST /_xpack/sql?format=txt
{
        "query": "SELECT * FROM twitter"
}
```

v7.5 导入默认数据，请求url 有所变更  
```
POST _sql?format=txt
{
      "query":"SELECT COUNT(*), MONTH_OF_YEAR(order_date) AS month_of_year, AVG(products.min_price) AS avg_price FROM kibana_sample_data_ecommerce GROUP BY month_of_year"
}
```

> [官方提到的SQL限制](https://www.elastic.co/guide/en/elasticsearch/reference/7.5/sql-limitations.html)

## 如何处理join
这篇文章说得比较详细了
https://blog.csdn.net/laoyang360/article/details/88784748
