---
title: K8s系列(一)---基本概念
top: 0
cover: 0
date: 2025-08-12 15:19:19
tags:
 - k8s
categories:
 - k8s
---

<!-- toc -->

### 前言

`Kubernetes`是一个开源的, 用于管理云平台中多个主机的容器化的应用, 目标是让部署容器化的应用简单并且高效. 本篇主要是想再开篇之前先说明一些基本概念, 后面就不再做说明了

### 集群架构与核心组件

#### 相关组件

##### 控制面板组件(`master`节点)

`kube-apiserver`: 接口服务,基于`REST`风格开放`k8s`接口的服务

`kube-controller-manager`: 控制器管理器, 负责运行控制器, 管理各个类型的控制器. 包括: 节点控制器,任务控制器,端点分片控制器,服务账号控制器

`cloud-controller-manager`: 云控制器管理器, 第三方云平台提供的控制器`API`对接管理功能

`kube-scheduler`: 调度器, 负责将`Pod`基于一定算法, 将其调用到更合适的节点上

`etcd`: `k8s`的数据库, 使用键值类型存储的分布式数据库, 提供了基于`Raft`算法实现自主的集群高可用

##### 节点组件(`Node`节点)

`kubelet`: 负责`Pod`的生命周期, 存储, 网络等管理

`kube-proxy`: 网络代理, 负责`service`的服务发现和负载均衡

`container runtime`: 容器运行时环境. `docker`, `containerd`, `CRI-O`

##### 附加组件

`kube-dns`: `DNS`服务

`ingress controller`: 外部网络访问

`Heapster`: 资源监控

`PrometheUS`: 资源监控

`Dashboard`: 控制台`UI`

`Federation`: 集群间的调度, 夸可用区的集群

`Fluentd-elasticsearch`: 日志采集, 存储, 查询

#### 分层架构

生态系统 -> 接口层 -> 管理层 -> 应用层 -> 核心层

### `k8s`的专业术语

#### 元空间型

对于资源的元数据描述, 所有资源都可以共享

`Horizontal Pod Autoscaler(HPA)`: `Pod`自动扩/缩容

`PodTemplate`: `Pod`模板

`LimitRange`: 资源限制

#### 集群型

作用于集群, 集群下的所有资源都可以共享

`Namespace`: 命名空间, 资源的逻辑隔离

`Node`: 节点, 只是管理节点资源

`ClusterRole`: 集群角色

`ClusterRoleBinding`: 集群角色绑定

#### 命名空间型

作用于命名空间, 同一命名空间内的所有资源都可以共享

##### 工作负载

`Pod`: `k8s`中最小的可部署单元, 内部是容器, 至少有一个容器. `Pod`内的容器通过`pause`共享网络内存等信息.

1. `replicas`: 副本数
2. 控制器(`Pod`描述器): 
   - 无状态: 
     - `ReplicationController`: 动态`Pod`副本
     -  `ReplicaSet`: 动态`Pod`副本 + 选择器
     -  `Deployment`: 创建`RS`/`Pod`副本 + 滚动升级/回滚 + 平滑扩/缩容 + 暂停与恢复`Deployment`
     
   - 有状态: 

     `StatefulSet`: 解决稳定网络和持久化存储问题

     - `Headless Service`: `DNS`, `StatefulSet`中每个`Pod`的`DNS`格式为`statefulSetName-{0,n-1}.serviceName.namespace.svc.cluster.local`,其中`serviceName`就是`Headless Service`的名字
     - `volumeClaimTemplate`: 用于创建持久化卷的模板

   - 守护进程: `DaemonSet`

   - 任务/定时任务: `Job`(一次性任务), `CronJob`

##### 服务发现

1. `Service`: 集群内部的网络通讯
2. `Ingress`: 集群与外部的网络通讯

##### 存储

1. `Volume`: 数据卷
2. `CSI`: 标准接口

##### 特殊类型配置

1. `ConfigMap`: `k-v`形式的配置
2. `Secret`: 保密形式的`ConfigMap`
3. `DownwardAPI`: 将`Pod`信息共享到容器中, 让容器可以读取`Pod`信息

##### 其他

1. `Role`: 命名空间的角色
2. `RoleBinding`: 绑定到命名空间