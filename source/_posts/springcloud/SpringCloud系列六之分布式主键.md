---
title: SpringCloud系列(六)---分布式主键
date: 2023-12-11 20:27:46
tags: 
- SpringCloud
- 分布式主键
categories: 
- SpringCloud
top: 6
cover: 0
---

<!-- toc -->

### 前言

前面搭建`SpringCloud`项目, 主要是框架的使用, 其实对于框架而言, 一般的框架学会使用, 能解决生产和开发过程中的问题即可, 少数优秀的框架可以去深入学习一下源码, 其中学习的主要目的是其原理和思想, 而不是其实现, 其设计理念有没有可以借鉴的地方.

本篇要解决的问题是分布式应用中的主键问题, 分布式主键最好可以满足一下要求

- 全局唯一: 这是一个基本要求, 其实在不同的实体表中, 主键相同是不存在异常的, 如用户表中的主键为`1`不会影响字典主键是否为`1`, 但此种方式识别性差, 所以要求生成的主键全局唯一
- 高性能: 生成响应要快, 不能成为业务响应速度的瓶颈
- 趋势递增: 趋势递增在添加数据和查询时可以提高效率

此系列在本篇后暂停一段时间, 接下来还有登录授权, 分布式事务, 锁, 消息队列等内容, 但由于许多内容与业务相关, 本人能力有限, 无法想象各种场景, 所以准备着手创建一个相配的前端项目, 也学习前端内容, `VUE`系列, 在该系列中会学习使用总结前端内容, 并且会配合本项目开发基础功能. 

前端项目暂定使用的内容有: `TypeScript`, `node`, `pnpm`, `vue`等, 革命尚未成功啊!

### 定义

定义一个分布式主键接口, 然后定义其不同实现

```java
public interface IdGenerator {

    Serializable id();

}
```

### 实现

#### `UUID`

`UUID`的方式是最容易实现的方式, 但由于生成的字符串无序, 所以在一般情况下不建议使用

```java
public class UUIDIdGenerator implements IdGenerator {
    @Override
    public String id() {
        return UUID.randomUUID().toString();
    }
}
```

#### 雪花算法

雪花算法是常用的主键生成策略, 其生成的数字是有序的, 结构将一个长整型数值分为四个部分:

- 符号位: 占用一个`bit`位, 定义为0, 即永远为正数, 不变
- 时间位: 占用41个`bit`位, 时间偏移量
- 工作机器位: 占用10个`bit`位, 指明生成主键的机器
- 序列号位: 占用12个`bit`位, 轮询生成序列号

> 注意: 
>
> 1. 如果机器发生了时间回退, 则有可能产生重复值, 但概率几乎可以忽略不计
> 2. 雪花算法在分布式中也无法保证先生成的数据一定小于后生成的数据, 这与每台机器的机器时间和定义的机器号有关

实现步骤:

1. 定义常量: 时间戳偏移原点, 序列号位数, 序列号最大值, 机器号位数, 机器号最大值

   ```java
   /**
    * 序列号占用位数
    */
   private static final long SEQUENCE_BIT = 12;
   /**
    * 机器占用位数
    */
   private static final long MACHINE_BIT = 10;
   
   /**
    * 时间偏移的坐标原点
    * 此处使用2020年1月1日0时0分0秒000毫秒
    * 可自定义时间坐标原点
    */
   private static final long START_TIMESTAMP = 1577808000000L;
   
   /**
    * 序列号的最大值
    */
   private static final long SEQUENCE_MAX = ~ (-1 << SEQUENCE_BIT); // 1 << SEQUENCE_BIT - 1 按位取反就是 -1 << SEQUENCE_BIT
   
   /**
    * 机器号最大值
    */
   private static final long MACHINE_MAX = ~ (-1 << MACHINE_BIT);
   ```

2. 定义变量: 机器号(初始化一次即可), 机器位(初始化一次即可), 序列号(初始是为默认值)

   ```java
   /**
    * 当前序列号
    */
   private long sequence = 0;
   
   /**
    * 当前机器号
    * 初始化后不在改变
    */
   private final long machineId;
   
   private final long machine;
   
   /**
    * 构造器, 创建时添加机器号参数
    * @param machineId 机器号
    * @throws IllegalAccessException   参数异常
    */
   public SnowflakeIdGenerator(long machineId) throws IllegalAccessException {
       if (machineId > MACHINE_MAX) {
           throw new IllegalAccessException("机器号大于要求的最大值");
       }
       this.machineId = machineId;
       // 机器号所占位为 机器号向左偏移SEQUENCE_BIT
       machine = machineId << SEQUENCE_BIT;
   }
   ```

3. 定义各个部分的实现

   时间戳位

   ```java
   /**
    * 时间戳位的值
    * @return  时间戳位
    */
   private long timestamp() {
       // 时间戳偏移量按位左移 机器号位数+序列号位数
       return timestampOffset() << (MACHINE_BIT + SEQUENCE_BIT);
   }
   
   /**
    * 获取当前时间戳偏移量
    * @return  时间戳偏移量
    */
   private long timestampOffset() {
       long l = System.currentTimeMillis();
       return l - START_TIMESTAMP;
   }
   ```

   机器位

   ```java
   /**
    * 机器位
    * @return  机器位
    */
   public long machine() {
       return machine;
   }
   ```

   序列号位

   方案一: 所有时间戳使用共同的序列号

   ```java
   /**
    * 序列号位
    * @return  序列号位
    */
   private long sequence() {
       // 获取当前序列号的值
       long seq = sequence;
       // 判断是否达到最大序列值, 达到则重置
       if (seq == SEQUENCE_MAX) {
           seq = -1;
       }
       seq ++;
       // 将新的序列值赋给变量并返回
       return sequence = seq;
   }
   ```

   每个时间戳使用单独的序列号

   ```java
   /**
    * 序列号位
    * @return  序列号位
    */
   private long sequence(long timestamp) {
       // 当前时间戳小于最后一次的时间戳时, 返回-1
       if (timestamp < lastTimestamp) {
           return -1;
       }
       // 如果时间戳大于上次的时间戳, 则重置序列号
       if (timestamp > lastTimestamp) {
           sequence = -1;
           lastTimestamp = timestamp;
       }
       // 获取当前序列号的值
       long seq = sequence;
       // 判断是否达到最大序列值, 达到则返回 -1, 这是由于同一个时间戳中生成了大于序列号最大数的主键
       if (seq == SEQUENCE_MAX) {
           return -1;
       }
       seq ++;
       // 将新的序列值赋给变量并返回
       return sequence = seq;
   }
   ```

   

4. 定义主键

   ```java
   @Override
   public Long id() {
       return Long.MAX_VALUE & timestamp() | machine() | sequence();
   }
   ```

5. 优化

   - 分布式服务中保证唯一性

     这个是通过工作机器号实现的, 不同的服务使用不同的机器号, 还可以更细分, 将机器号分为数据中心+机器号, 共占用10位即可

   - 多线程下的序列号变量的安全问题

     使用同步即可

     ```java
     /**
      * 序列号位
      * @return  序列号位
      */
     private synchronized long sequence() {
         // 获取当前序列号的值
         long seq = sequence;
         // 判断是否达到最大序列值, 达到则重置
         if (seq == SEQUENCE_MAX) {
             seq = -1;
         }
         seq ++;
         // 将新的序列值赋给变量并返回
         return sequence = seq;
     }
     ```

     ```java
     /**
      * 序列号位
      * @return  序列号位
      */
     private synchronized long sequence(long timestamp) {
         // 当前时间戳小于最后一次的时间戳时, 返回-1
         if (timestamp < lastTimestamp) {
             return -1;
         }
         // 如果时间戳大于上次的时间戳, 则重置序列号
         if (timestamp > lastTimestamp) {
             sequence = -1;
             lastTimestamp = timestamp;
         }
         // 获取当前序列号的值
         long seq = sequence;
         // 判断是否达到最大序列值, 达到则返回 -1, 这是由于同一个时间戳中生成了大于序列号最大数的主键
         if (seq == SEQUENCE_MAX) {
             return -1;
         }
         seq ++;
         // 将新的序列值赋给变量并返回
         return sequence = seq;
     }
     ```

6. 疑问

   - 序列号为什么可以不在每个时间戳中都重置

     一: 序列号在主键生成的影响度是远小于时间戳的影响度的, 所以即使在不同的时间戳使用相同的序列号缓存也是不影响整体主键顺序的, 其影响性是在达到最大值时, 在同一个时间戳中生成主键时会产生后生成的主键小于先生成的主键的情况, 但是这种情况是可以接受的, 所以没有必要在每次生成时都判断是否是不同的时间戳然后选择是否重置序列号的操作

     二: 当序列号在同一个时间戳中达到最大值后进行重置操作, 然后又在该时间戳达到了最大值, 这个问题本身不是此种序列号方式的问题, 而是生成的数据量的问题. 序列号可以产生~(-1 << 12)个数值, 产生了这个问题说明要求在1毫秒之内生成大于该数量的值, 无论是哪种序列号生成方式都不可能在1毫秒内生成大于最大数量的不重复值

7. 全部内容

   ```java
   public class SnowflakeIdGenerator implements IdGenerator {
   
       /**
        * 序列号占用位数
        */
       private static final long SEQUENCE_BIT = 12;
       /**
        * 机器占用位数
        */
       private static final long MACHINE_BIT = 10;
   
       /**
        * 时间偏移的坐标原点
        */
       private static final long START_TIMESTAMP = 1577808000000L;
   
       /**
        * 序列号的最大值
        */
       private static final long SEQUENCE_MAX = ~ (-1 << SEQUENCE_BIT); // 1 << SEQUENCE_BIT - 1 按位取反就是 -1 << SEQUENCE_BIT
   
       /**
        * 机器号最大值
        */
       private static final long MACHINE_MAX = ~ (-1 << MACHINE_BIT);
   
       /**
        * 当前序列号
        */
       private long sequence = 0;
   
       /**
        * 当前机器号
        * 初始化后不在改变
        */
       private final long machineId;
   
       private final long machine;
   
       private long lastTimestamp;
   
       /**
        * 构造器, 创建时添加机器号参数
        * @param machineId 机器号
        * @throws IllegalAccessException   参数异常
        */
       public SnowflakeIdGenerator(long machineId) throws IllegalAccessException {
           if (machineId > MACHINE_MAX) {
               throw new IllegalAccessException("机器号大于要求的最大值");
           }
           this.machineId = machineId;
           // 机器号所占位为 机器号向左偏移SEQUENCE_BIT
           machine = machineId << SEQUENCE_BIT;
       }
   
   	// 生成主键由时间戳和序列号的两种方案, 方案二更完善些, 方案一也可用
       // 方案一
       @Override
       public Long id() {
           return Long.MAX_VALUE & timestamp() | machine() | sequence();
       }
       
       // 方案二
       @Override
       public Long id() {
           long sequence;
           long timestamp;
           // 循环, 返回的序列值小于0时, 则重新计算
           do {
               timestamp = timestamp();
               sequence = sequence(timestamp);
           } while (sequence < 0);
           System.out.println("time: " + timestamp + "; sequence: " + sequence);
           return Long.MAX_VALUE & timestamp | machine() | sequence;
       }
       
   
       /**
        * 序列号位
        * @return  序列号位
        */
       private synchronized long sequence() {
           // 获取当前序列号的值
           long seq = sequence;
           // 判断是否达到最大序列值, 达到则重置
           if (seq == SEQUENCE_MAX) {
               seq = -1;
           }
           seq ++;
           // 将新的序列值赋给变量并返回
           return sequence = seq;
       }
       
       /**
        * 序列号位
        * @param timestamp 时间戳
        * @return  序列号位
        */
       private synchronized long sequence(long timestamp) {
           // 当前时间戳小于最后一次的时间戳时, 返回-1
           if (timestamp < lastTimestamp) {
               return -1;
           }
           // 如果时间戳大于上次的时间戳, 则重置序列号
           if (timestamp > lastTimestamp) {
               sequence = -1;
               lastTimestamp = timestamp;
           }
           // 获取当前序列号的值
           long seq = sequence;
           // 判断是否达到最大序列值, 达到则返回 -1, 这是由于同一个时间戳中生成了大于序列号最大数的主键
           if (seq == SEQUENCE_MAX) {
               return -1;
           }
           seq ++;
           // 将新的序列值赋给变量并返回
           return sequence = seq;
       }
   
       /**
        * 机器位
        * @return  机器位
        */
       private long machine() {
           return machine;
       }
   
       /**
        * 时间戳位的值
        * @return  时间戳位
        */
       private long timestamp() {
           // 时间戳偏移量按位左移 机器号位数+序列号位数
           return timestampOffset() << (MACHINE_BIT + SEQUENCE_BIT);
       }
   
       /**
        * 获取当前时间戳偏移量
        * @return  时间戳偏移量
        */
       private long timestampOffset() {
           return System.currentTimeMillis() - START_TIMESTAMP;
       }
       
   }
   ```

#### `Redis`

`Redis`主键策略也是常用的分布式主键策略之一

`Redis`主键策略需要注意的点有:

- 持久化, 避免`Redis`重启导致的主键重置
- 设置起始值和步长, 避免多个`Redis`服务(集群)的导致的主键重复问题(`MySql`数据库也可通过这种方式获得不重复的主键)
- 可能还有其他问题, 我暂时没想到

实现步骤

1. 环境

   本次的`Redis`主键策略是基于上一篇中引入的`Redis`和分布式锁

2. 实现

   `Redis`主键策略可以有两种模式, 一种是单个主键模式, 一种是缓存主键模式

   ```java
   private final RedisUtil redisUtil;
   /**
    * 是否启用缓存模式
    */
   private final boolean cache;
   
   private final boolean startValue;
   ```

3. 单个主键模式

   ```java
   /**
    * 非缓存模式下启用
    * 步长
    */
   private final int step;
   
   private Long singletonId() {
       return DistributedLockUtil.lock("distributed_redis_id_generator_lock", () -> {
           long result = 0L;
           Object id = redisUtil.get("distributed_redis_id");
           if (!Objects.isNull(id)) {
               result = Long.parseLong(id.toString());
           }
           redisUtil.set("distributed_redis_id", result + step);
           return result;
       });
   }
   ```

4. 缓存主键模式

   ```java
   /**
    * 缓存模式下启用
    * 缓存主键数量
    */
   private final int size;
   
   /**
    * 缓存模式下启用
    * 下一个主键值
    */
   private long next;
   
   /**
    * 缓存模式下启用
    * 剩余主键数量
    */
   private int rest;
   
   private Long cacheId() {
       return DistributedLockUtil.lock("distributed_redis_id_generator_lock", () -> {
           if (rest > 0) {
               rest --;
               return next ++;
           }
           next = 0L;
           Object id = redisUtil.get("distributed_redis_id");
           if (!Objects.isNull(id)) {
               next = Long.parseLong(id.toString());
           }
           rest = size;
           redisUtil.set("distributed_redis_id", next + size);
           rest --;
           return next ++;
       });
   }
   ```

5. 疑问

   关于主键持久化, 请交给`Redis`的持久化处理, 在`Redis`服务停止或者宕机重启时, 需要将`Redis`持久化内容重新写入内存, 此时`Redis`中用于主键生成的内容值, 最好在原值的基础上增加一定数量的值, 避免持久化滞后带来的主键重复问题

6. 全部内容

   ```java
   public class RedisIdGenerator implements IdGenerator {
   
       private final RedisUtil redisUtil;
   
       /**
        * 是否启用缓存模式
        */
       private final boolean cache;
   
       private final long startValue;
   
       /**
        * 缓存模式下启用
        * 缓存主键数量
        */
       private final int size;
   
       /**
        * 缓存模式下启用
        * 下一个主键值
        */
       private long next;
   
       /**
        * 缓存模式下启用
        * 剩余主键数量
        */
       private int rest;
   
       /**
        * 非缓存模式下启用
        * 步长
        */
       private final int step;
   
       public RedisIdGenerator(RedisUtil redisUtil, boolean cache, long startValue, int size, int step) throws IllegalAccessException {
           this.redisUtil = redisUtil;
           this.cache = cache;
           // 缓存模式使用长度
           if (cache && size <= 0) {
               throw new IllegalAccessException("缓存模式下缓存长度必须大于0");
           }
           this.size = size;
           this.next = 0L;
           this.rest = 0;
           // 缓存模式不使用步长
           if (!cache && step <= 0) {
               throw new IllegalAccessException("非缓存模式下步长必须大于0");
           }
           this.step = step;
           this.startValue = startValue;
       }
   
       public RedisIdGenerator(RedisUtil redisUtil, boolean cache, long startValue, int size) throws IllegalAccessException {
           this(redisUtil, cache, startValue, size, 1);
       }
   
       public RedisIdGenerator(RedisUtil redisUtil, boolean cache, long startValue) throws IllegalAccessException {
           this(redisUtil, cache, startValue, 100);
       }
   
       @Override
       public Long id() {
           return cache ? cacheId() : singletonId();
       }
   
       private Long singletonId() {
           return DistributedLockUtil.lock("distributed_redis_id_generator_lock", () -> {
               long result = startValue;
               Object id = redisUtil.get("distributed_redis_id");
               if (!Objects.isNull(id)) {
                   result = Long.parseLong(id.toString());
               }
               redisUtil.set("distributed_redis_id", result + step);
               return result;
           });
       }
   
       private Long cacheId() {
           return DistributedLockUtil.lock("distributed_redis_id_generator_lock", () -> {
               if (rest > 0) {
                   rest --;
                   return next ++;
               }
               next = startValue;
               Object id = redisUtil.get("distributed_redis_id");
               if (!Objects.isNull(id)) {
                   next = Long.parseLong(id.toString());
               }
               rest = size;
               redisUtil.set("distributed_redis_id", next + size);
               rest --;
               return next ++;
           });
       }
   }
   ```

### 策略选择配置

#### 配置文件

```yml
project:
  id:
    type: redis
    redis:
      cache: false
      size: 1
      step: 1
      start-value: 0
    snowflake:
      machine-id: 1
```

#### 配置读取

```java
@Data
@Configuration
@ConfigurationProperties(prefix = "project.id")
public class IdGeneratorConfig {

    private IdType type = IdType.UUID;

    private RedisGeneratorConfig redis = new RedisGeneratorConfig();

    private SnowflakeGeneratorConfig snowflake = new SnowflakeGeneratorConfig();

    @Bean
    @ConditionalOnMissingBean(name = "idGenerator")
    public IdGenerator idGenerator(RedisUtil redisUtil) throws IllegalAccessException {
        switch (type) {
            case SNOWFLAKE: {
                return new SnowflakeIdGenerator(snowflake.getMachineId());
            }
            case REDIS: {
                return new RedisIdGenerator(redisUtil, redis.getCache(), redis.getStartValue(), redis.getSize());
            }
            case UUID: {

            }
            default: {
                return new UUIDIdGenerator();
            }
        }
    }

    @Getter
    public static class RedisGeneratorConfig {
        private Boolean cache = false;
        private int size = 1;
        private int step = 1;
        private long startValue = 0L;

        public void setCache(boolean cache) {
            this.cache = cache;
        }

        public void setSize(int size) {
            this.size = size > 0 ? size : 1;
        }

        public void setStep(int step) {
            this.step = step > 0 ? step : 1;
        }

        public void setStartValue(int startValue) {
            this.startValue = startValue;
        }
    }

    @Getter
    @Setter
    public static class SnowflakeGeneratorConfig {
        private long machineId = 1L;
    }

}

enum IdType {
    UUID,
    SNOWFLAKE,
    REDIS
}
```

### 出现问题:sob:

<i id="问题一">问题一</i>

问题: 生成的主键长于数据库主键字段长度

问题原因: 建表时, 数据库主键使用的是`int`类型, 主键生成中使用的是字符串或者`long`型, 导致数据库主键字段无法存储

解决办法: 修改数据库字段类型, 建议为`bigint`, 生成主键使用`long`型

### 挖坑





































