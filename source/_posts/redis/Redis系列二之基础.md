---
title: Redis系列(二)---基础
date: 2026-04-20 15:16:07
tags: 
- Redis
categories: 
- Redis
top: 2
cover: 0
---

<!-- toc -->

### 前言

前面我们已经完成了`redis`的安装工作，现在我们来学习使用`redis`

### `Redis`的数据类型

##### 1. `string`

基本的数据存储单元，可以存储字符串、整数、浮点数

`string`：普通字符串

`int`：整数类型，可以做自增自减操作

`float`：浮点类型，可以做自增自减操作

##### 2. `hash`

一个键值对集合，可以存储多个字段

##### 3. `list`

一个简单的列表，可以存储一系列的字符元素。双向链表型。有序，可重复，插入和删除快，查询速度一般

##### 4. `set`

一个无序集合，可以存储不重复的字符串元素。无序，不可重复，查找快，支持交集，并集，差集等操作

##### 5. `zset`

类似于集合，但是每个元素都有一个分数与之关联。可以基于`score`属性对元素排序，底层的是按是一个跳表`skiplist`加`hash`表。可排序，元素不重复，查询速度快

##### 6. 位图`(Bitmaps)`

基于字符串类型，可以对每个位进行操作

##### 7. 超日志`(HyperLogLogs)`

用于基数统计，可以估算集合中的唯一元素数量

##### 8. 地理空间`(Geospatial)`

用于存储地理位置信息

##### 9. 发布/订阅`(Pub/Sub)`

一种消息通信模式，允许客户端订阅消息通道，并接受发布到该通道的消息

##### 10. 流`(Streams)`

用于消息队列和日志存储，支持消息的持久化和时间排序

##### 11. 模块`(Modules)`

`redis`支持动态架子啊模块，可以扩展`redis`的功能

### `Redis`的常见命令

#### 1. 通用命令

##### 1. 帮助命令

获取某种类型有哪些命令

```redis
help @<数据类型>
# help @string
help <command>
# help keys
```

##### 2. `keys`

获取所有符合给定模板的`key`

```redis
keys <pattern>
# keys a*
```

##### 3. `del`

删除给定的`key`指向的键值对

```redis
del <key [key1 key2...]>
# del name age
```

##### 4. `exists`

判断一个给定的`key`是否存在

```redis
exists <key [key ...]>
# exists name
```

##### 5. `expire`

为给定`key`设置有效期，有效期到期时，给定的`key`会被自动删除

```redis
expire <key> <seconds>
# expire name 30
```

##### 6. `ttl`

查看给定`key`的剩余有效期，结果如果返回-2表示不存在，-1表示永久有效

```redis
ttl <key>
# ttl name
```

##### 7. `scan`

增量遍历`key`，与`keys`命令不同，此命令不会阻塞服务器

```redis
scan <cursor> [match <pattern>] [count <count>] [type <type>]
# scan 0 match n* count 10 type string
```

> `cursor`：游标，表示从指定位置开始便利
>
> `pattern`：匹配的模式
>
> `count`： 每次遍历返回的元素数量
>
> `type`： 指定返回的类型

#### 2. `string`

##### 1. `set`

添加或者修改已经存在的一个`string`类型的键值对

```redis
set <key> <value>
#set name xiao-lin
```

使用`:`可以让`key`创建层级结构

```redis
set user:xiaolin '{"name": "xiaolin", "age": 18}'
```

这会创建`user`这一层级，然后在这层级下创建一个`xiaolin`的`key`

##### 2. `get`

根据`key`获取`string`类型的值

```redis
get <key>
#get name
```

##### 3. `mset`

批量添加多个`string`类型的键值对

```redis
mset <key1> <value1> <key2> <value2>
#mset age 18 city qingdao
```

##### 4. `mget`

根据多个`key`获取多个`string`类型的值

```redis
mget <name> <age> <city>
#mget name age city
```

##### 5. `incr/decr`

让给定的`key`的整型值自增/自减1

```redis
incr <key>
#incr age
```

##### 6. `incrby/decrby`

让给定的`key`的整型值自增/自减指定步长

```redis
incrby <key> <step>
#incrby age 2
```

##### 7. `incrbyfloat`

让给定的`key`的浮点型值自增指定步长

```redis
incrbyfloat <key> <step>
#incrbyfloat money 10000000.2
```

##### 8. `setnx`

当给定的`key`不存在时，添加一个`string`类型的键值对，否则不执行

```redis
setnx <key> <value>
#setnx province shandong
```

##### 9. `setex`

添加一个`string`类型的键值对，并且指定有效期

```redis
setex <key> <seconds> <value>
# setex computer 30 thinkbook
```

##### 10. `APPEND`

为给定`key`的值追加内容

```redis
append <key> <value。
# appdend name "-unit"
```

##### 11. `strlen`

获取给定`key`的值的长度

```redis
strlen <key>
# strlen name
```

##### 12. `substr`

获取给定`key`的值的子串

```redis
substr <key> <start> <end>
# strlen name 0 7
```

#### 2. `hash`

| key            | field | value    |
| -------------- | ----- | -------- |
| user:xiaolin:1 | name  | xiao-lin |

> 注意：
>
> `field`和`value`才是整个`key`的`value`

##### 1. `hset`

添加或修改`hash`类型`key`的`field`的值

```redis
hset <key> <field> <value> <field2> <value2>
```

##### 2. `hget`

获取一个`hash`类型的`key`的`field`的值

```redis
gset <key> <field>
```

##### 3. `hmset`

批量添加多个`hash`类型`key`的`field`的值

```redis
hmset <key> <field1> <value1> <field2> <value2>
```

##### 4. `hmget`

批量获取多个`hash`类型`key`的`field`的值

```redis
hmget <key1> 
```

##### 5. `hgetall`

获取给定`hash`类型`key`的所有`field`和`value`

```redis
hgetall <key>
# hgetall user:xiao-lin
```

##### 6. `hkeys`

获取给定`hash`类型`key`中的所有`field`

```redis
hkeys <key>
# hkeys user:xiao-lin
```

##### 7. `hvals`

获取给定`hash`类型`key`中的所有`value`

```redis
hvals <key>
# hvals user:xiao-lin
```

##### 8. `hincrby/hdecrby`

让给定的`hash`类型的`key`的指定`field`自增/自减指定步长

```redis
hincrby <key> <field> <step>
# hvals user:xiao-lin age 2
```

##### 9. `hsetnx`

当给定的`hash`类型`key`的`field`不存在时，添加一个`field`和`value`的键值对，否则不执行

```redis
hsetnx <key> <field> <value>
# hsetnx user:xiao-lin city wf
```

##### 10. `hdel`

删除给定的`hash`类型`key`的`field`的值

```redis
hdel <key> <field>
# hdel user:xiao-lin city
```

##### 11. `hexists`

判断给定的`hash`类型`key`的`field`的值是否存在

```redis
hexists <key> <field>
# hexists user:xiao-lin city
```

##### 12. `hlen`

获取给定的`hash`类型`key`的`field`的数量

```redis
hlen <key>
# hlen user:xiao-lin
```

#### 3. `List`

##### 1. `lpush`

向列表左侧出入一个或多个元素

```redis
lpush <key> <element> [<element1> ...]
# lpush index 1 2 3
```

##### 2. `lpop`

移除并返回列表左侧的指定个元素（默认1个），没有则返回`nil`

```redis
lpop <key> [<count>]
# lpop index
```

##### 3. `rpush`

向列表右侧插入一个或多个元素

```redis
rpush <key> <element> [<element1> ...]
# rpush index 3 4
```

##### 4. `rpop`

移除并返回列表右侧的指定个元素（默认1个），没有则返回`nil`

```redis
rpop <key> [<count>]
# rpop index 2
```

##### 5. `lrange`

返回一段下表范围内的所有元素

```redis
lrange <key> <start> <end>
# lrange index 1 3
```

##### 6. `blpop/brpop`

与`lpop`和`rpop`类型，只不过在没有元素时等待指定时间，而不是直接返回`nil`

```redis
blpop <key> <timeout>
# blpop index 30
```

#### 4. `set`

##### 1. `sadd`

向`set`中添加一个或多个元素

```redis
sadd cset 1 2 3 4 5 6
```

##### 2. `srem`

移除`set`中的指定元素

```redis
srem
# srem cset 3
```

##### 3. `scard`

返回`set`中元素的个数

```redis
scard
# scard cset
```

##### 4. `sismember`

判断一个元素是否存在于`set`中

```redis
sismember
# sismember cset 2
```

##### 5. `smembers`

获取`set`中的所有元素

```redis
smembers <key>
# smembers cset
```

##### 6. `smove`

将某个集合中的元素某个元素移动到另一个集合中

```redis
smove <source_key> <destination_key> <member>
# smove dset cset 3
```

##### 7. `sinter`

指定`key`集合的交集

```redis
sinter <key> [<key1> <key2>]
# sinter cset dset
```

##### 8. `sdiff`

指定`key`集合的差集

```redis
sdiff <key> [<key1> <key2>]
# sdiff cset dset
```

> 注意：如果集合位置交换，结果可能不一样
>
> 如：`cset=[1, 2, 4, 5, 6], dset=[1,2,3,4,5,6]`，则`sdiff cset dset`为空集，`sdiff dset cset`为`[3]`

##### 9. `sunion`

指定`key`集合的并集

```redis
sunion <key> [<key1> <key2>]
# sunion cset dset
```

#### 5. `zset`

##### 1. `zadd`

添加一个或多个元素到`zset`中，如果已经存在则更新其`score`值

```redis
zadd <key> <score> <member>
# zadd students 85 J 89 L 82 R 95 T 92 A 76 M
```

##### 2. `zrem`

删除`zset`中的指定元素

```redis
zrem <key> <member>
# zrem students A
```

##### 3. `zscore`

获取`zset`中的指定元素的`score`值

```redis
zscore <key> <member>
# zscore students T
```

##### 4. `zrank`

获取`zset`中的指定元素的排名

```redis
zrank/zrevrank <key> <member>
# zrank students R
# zrevrank students R
```

> `zrank`是升序排名，如果要降序则使用`zrevrank`

##### 5. `zcard`

获取`zset`中的元素个数

```redis
zcard <key>
# zcard students
```

##### 6. `zcount`

统计`score`值在给定范围内的所有元素的个数

```redis
zcount <key> <min> <max>
# zcount students 0 80
```

##### 7. `zincrby`

让`zset`中的指定元素自增指定步长

```redis
zincrby <key> <step> <member>
# zincrby stadents 2 T
```

##### 8. `zrange`

按照`score`排序后，获取指定排名范围内的元素

```redis
zrange <key> <min> <max> [byscore|bylex] [rev] [limit <offset> <count>] [withscores]
# zrange students 0 80
```

> 默认是升序排名，如果要降序则在命令最后添加`rev`或者使用`zrevrange`

##### 9. `zdiff`

获取指定集合的差集

##### 10. `zinter`

获取指定集合的交集

##### 11 `zunion`

获取指定集合的并集