---
title: Zookeeper系列(一)---原理
date: 2024-05-28 16:12:45
tags: 
- zookeeper
categories: 
- zookeeper
top: 1
cover: 0

---

<!-- toc -->

### 前言

`zookeeper`开篇原本是想直接讲述安装和使用的, 但在介绍为啥要使用`zookeeper`时, 总是绕不过它的起源. 自此也就需要这样一篇博文来讲述一下`zookeeper`的前世.

==如果不想了解原理, 只是学习使用, 大可跳过本篇文章==

### 背景

随着业务需求量的逐步增长, 单体服务已经无法支撑整个系统, 此时就从**单节点的集中式架构**向**多节点的分布式架构**转型. 分布式机构能解决集中式架构中心化带来单点故障的问题，但同时也引入了一致性的问题. 通常说的一致性问题大多数人的第一印象是数据一致性, 但此处的一致性用状态的一致性来描述更为合理, 只不过状态通常通过数据来体现. `Paxos`算法是一种**通用性分布式一致性协议**

其中的**拜占庭问题**可以参考文章: <a href="https://juejin.cn/post/7065309063432634382">分布式一致性：你真的读懂了Paxos小岛的故事嘛？</a>

### `Paxos`算法

 `Lamport`老爷子提出了实现分布式一致性的解决方案, 并使用`paxos`小岛的方式进行了具象化描述, 当我去阅读网上的文章的解析文章的时候, 我疯了, 好似不同的人理解出了不一样的版本. 我只得去寻找原文: <a href="The Part-Time Parliament en.pdf">The Part-Time Parliament en.pdf</a>

相信对各位大佬来说简直小菜, 我个人英语水平不行, 我看中文译文版: <a href="The Part-Time Parliament CN.pdf">The Part-Time Parliament en.pdf</a>

