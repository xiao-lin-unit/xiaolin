---
title: K8s系列(六)---资源补充
top: 5
cover: 0
date: 2025-09-17 12:44:19
tags:
 - k8s
categories:
 - k8s
---

<!-- toc -->

### 前言

经过前面的折磨, 想必都有了一点体会. 为什么我们要先学习一次部署, 而不是先学习详细内容. 主要是基于以下考虑:

- 实践能力. 纸上得来终觉浅, 绝知此事要躬行
- 应用能力. 在学习完一次部署之后, 经过折磨之后大致能知道如何做部署工作, 可以直接应用, 经典的我就蹭蹭不进去
- 带着问题找答案. 部署过程中会遇到各种问题, 无论有没有部署成功, 过程中的问题会提醒你需要你特别关注的点, 这比盲目学习有用
- 此篇本身目的并不是要详细讲解其内容, 而是想做一些内容补充或者做重要内容的使用以及一些可能需要额外注意的内容. 资源配置详解可以从[官方文档](https://kubernetes.io/zh-cn/docs/home/)参考内容的[Kubernetes API](https://kubernetes.io/zh-cn/docs/reference/kubernetes-api/)中查看

### `Pod`

#### 探针

`Pod`容器中的程序在运行过程中可能会出现错误, 导致程序停止运行. 如, `java`项目可能会出现内存溢出而停止. 那么`Pod`是如何知道程序是否正常运行的呢? 答案就是探针. 

前文在部署资源时, 可能会遇到`Pod`的状态为`Running`, 但是`Ready`却是`0/1`, 而自己也确认容器中的程序没有错误, 那么就是探针没有配置好的结果

##### 类型

- `StartupProbe`(用来探测是否启动成功): 配置该探针后, 会先禁用其他探针, 直到该探针成功后, 其他探针才会启动使用. 这是为了解决不能准确预估应用一定是多长时间启动成功而新增的类型. 是一个启动时的状态探针
- `LivenessProbe`(用来探测是否需要重启): 用于探测容器中的应用是否仍正常运行, 如果探测失败, `kubelet`会根据配置的重启策略进行重启. 如果没有配置该探针, 默认就认为容器启动成功, 不会执行重启策略. 是一个启动成功后的周期探针
- `ReadinessProbe`(用来探测是否可以接收外部流量): 用于探测容器是否健康, 如果是, 则认为该容器已经完全启动, 并且可以接受外部流量. 多用来做在容器内程序启动后需要内容初始化完成后使用的探测. 是一个启动成功后的周期探针

##### 探测方式

- `ExecAction`: 执行命令进行探测

  ```yaml
  livenessProbe: 
    exec: 
      command: 
        - sh
        - -c
        - cat inited > 'Pod Success' # 自定义探测命令
  ```

- `TCPSocketAction`: 通过`tcp`链接检测容器端口是否开放, 若开放则证明该容器健康

  ```yaml
  livenessProbe: 
    tcpSocket: 
      port: 8080
  ```

- `HTTPGetAction`: 通过`http get`请求, 若结构返回的状态码在`200~400`之间, 则认为容器健康

  ```yaml
  livenessProbe: 
    httpGet: 
      path: /healthy
      port: 8080
  ```

#### 生命周期

`Pod`的整个生命过程有以下几个节点

- `initContainer`
- 启动
- `postStart`
- `StartUpProbe`
- `LivenessProbe/ReadinessProbe`
- `preStop`
- 结束

但对`Pod`的生命周期定义有两个, 即`postStart`和`preStop`, `postStart`不建议使用, 可能会与容器的`command`存在并行

```yaml
# 以Deployment的yaml配置
spec: 
  template: 
    spec: 
      initContainers: 
        # initContainers 的配置内容与 containers 一致, 只是这部分会在容器启动前执行
      containers: 
        lifecycle: 
          postStart: 
            exec: 
              command: ''
            httpGet: 
              port: 80
            tcpSocket: 
              port: 80
          preStop: 
            exec: 
              command: ''
            httpGet: 
              port: 80
            tcpSocket: 
              port: 80
```

`preStop`常用在释放资源, 注册中心下线等业务中

### 资源调度

#### 标签和选择器

在资源中可以在`metadata`中定义`labels`, 通过自定义键值对的方式为字段添加标签

通过选择器`selector`中定义`matchLabels`, 通过定义键值对匹配对应的资源

```yaml
metadata: 
  labels: 
    app: my-app
    version: v1.0.0
    role: admin
    namespace: test # 这个与k8s的namespace无关, 这个namespace是自定义的标签
```

```yaml
spec: 
  selector: 
    matchLabels: 
      app: my-app
      role: admin
    matchExpressions:
      - key: version
        operator: In/NotIn
        values: [v1.0.0, v1.0.1] # operator 为 In/NotIn时, values不能为空
      - key: namespace
        operator: Exists/DoesNotExist # operator 为 Exists/DoesNotExists时, values必须为空
        
```

#### `Deployment`

`Deployment`的内容在上一篇部署中配置的内容差不多, 本篇就只讲解一点关于版本更新的内容

- 滚动更新

  `Deployment`将现有`Pod`替换为新`Pod`称为更新, 更新是通过更新策略配置的, 默认是滚动更新

  ```yaml
  spec: 
    strategy: 
      type: RollingUpdate
      rollingUpdate: 
        maxSurge: 25%
        maxUnavailable: 25%
  ```

  上述配置中

  - `maxSurge`表示新旧`Pod`总数不会超过预期`Pod`数的`125%`

  - `maxUnavailabe`表示可用`Pod`总数不会少于预期`Pod`数的`75%`

  - `type`还可以选择`Recreate`, 当`type`值为`Recreate`时, 则不需要`rollingUpdate`相关配置

  滚动更新的过程:

  1. 基于原来的`ReplicaSet`创建一个新的`ReplicaSet`

  2. 在新的`ReplicaSet`中执行扩容操作

  3. 在旧的`ReplicaSet`中执行缩容操作
  4. 在滚动更新策略的配置数值基础上, 重复步骤2和步骤3, 全部更新完成

- 回滚版本

  ```bash
  kubectl rollout {command} {resource_type} {deploy_name} -n {ns_name} [options]
  
  # 查看 Deployment 的历史版本
  kubectl rollout history deployment abc [--revision={n}]
  
  # 回滚到先前的 Deployment 版本
  kubectl rollout undo deployment abc
    
  # 检查 Daemonset 的部署状态
  kubectl rollout status daemonset foo
    
  # 重启 Deployment
  kubectl rollout restart deployment abc
    
  # 重启带有 'app=nginx' 标签的 Deployment
  kubectl rollout restart deployment --selector=app=nginx
  ```

  需要注意的是, 版本回滚需要基于`revisionHistoryLimit`配置, 如果该配置设置为0, 则不会记录版本信息, 就不允许`Deployment`回退了

- 更新的暂停与恢复

  ```bash
  # 暂停更新服务, 执行之后任何修改配置都不会触发更新
  kubectl rollout pause {resource_type} {deploy_name}
  
  # 恢复更新服务, 执行后会将之前做的暂停的更新服务恢复
  kubectl rollout deploy {resource_type} {deploy_name}
  ```

#### `StatefulSet`

- 扩容和缩容

  1. 通过`scale`命令

     ```bash
     kubectl scale sts {sts_name} --replicas=5
     ```

  2. 修改配置文件的`replicas`数量修改

     ```yaml
     spec: 
       replicas: 5
     ```

  3. 通过`patch`命令修改

     ```bash
     kubectl patch sts {sts_name} -p '{"spec":{"replicas":5}}'
     ```

- 更新策略

  `StatefulSet`中, 更新策略字段不是`strategy`, 而是`updateStrategy`

  ```yaml
  spec: 
    updateStrategy: 
      type: RollingUpdate
      rollingUpdate: 
        maxUnavailable: 25%
        partition: 2
  ```

  `partition`表示分区, 只更新序列数`>=partition`的`Pod`. 如, `replicas`为`5`, `partition`为`3`, 那么更新时只更新序列数为3和4的`Pod`

  `StatefulSet`也可以采用滚动更新策略, 但由于`Pod`是有序的, 所以`StatefulSet`中更新时是基于`pod`的顺序倒序更新的. 利用滚动更新中的`partition`属性, 可以实现简易的灰度发布(金丝雀发布)的效果. 例如有5个`Pod`, 如果当前`partition`设置为`3`, 那么此时滚动更新时只会更新那些序号`>=3`的`Pod`. 通过`partition`的值, 来决定只更新启动一部分`Pod`, 确认没有问题户在逐渐增大`Pod`的更新数量

  `type`的值也可以选择使用`OnDelete`, 表示只有在删除`Pod`操作后, 在新建`Pod`时完成更新

- 镜像更新

  1. 修改配置文件的`image`修改

     ```yaml
     spec:
       template: 
         spec: 
           containers: 
             - image: nginx:1.22.1
     ```

  2. 通过`patch`命令修改

     ```bash
     kubectl patch sts {sts_name} --type='json' -p='[{"op":"replace","path":"/spec/template/spec/containers/0/image", "value":"nginx:1.22.1"}]'
     ```

- 级联删除和非级联删除

  `StatefulSet`在做删除操作时, 默认是级联删除, 即会将相关`Pod`资源一起删除, 可以通过添加参数做非级联删除

  ```bash
  # cascade 的参数值为true时为级联删除, false为非级联删除
  kubectl delete sts {sts_name} --cascade=true/false
  ```

### `DaemonSet`

`DaemonSet`是为每一个`node`节点都部署一个守护进程, 所以`DaemonSet`不存在人为修改扩缩容这个概念. 通常是部署公共功能, 如服务日志, 服务监控等.

指定节点的方式

- `nodeSelector`: 只掉督导匹配指定`label`的`Node`上
- `nodeAffinity`: 功能更丰富的`Node`选择器, 节点亲和力
- `podAffinity`: 调度到满足条件的`Pod`所在的`Node`上, `Pod`亲和力

亲和力部分先不讲解, 后面与污点一起

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: fluentd-pod-reader
rules:
  - apiGroups: [""]  # 空字符串表示核心API组
    resources: ["pods", "namespaces"]
    verbs: ["get", "watch", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: fluentd-pod-reader-binding
subjects:
  - kind: ServiceAccount
    name: default
    namespace: test  # 你的服务账户所在的命名空间
roleRef:
  kind: ClusterRole
  name: fluentd-pod-reader
  apiGroup: rbac.authorization.k8s.io

---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: test
spec:
  updateStrategy:
    type: OnDelete
  selector:
    matchLabels:
      app: logging # 与下面的 template 中定义的labels匹配
  template:
    metadata:
      labels:
        app: logging # 为定义的pod添加标签
        id: fluentd
      name: fluentd
    spec:
      nodeSelector:
        type: app-node
      containers:
        - name: fluentd-es
          image: fluent/fluentd-kubernetes-daemonset:v1.19-debian-graylog-1
          env:
            - name: K8S_NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
          volumeMounts:
            - name: containers
              mountPath: /var/lib/k8s/containers
            - name: varlog
              mountPath: /var/log
      volumes:
        - name: containers
          hostPath:
            path: /var/lib/k8s/containers
        - name: varlog
          hostPath:
            path: /var/log
```

==`ClusterRole`和`ClusterRoleBinding`配置是`fluentd`需要的, 并不是`DaemonSet`需要的==

#### `HPA`自动扩/缩容

根据`CPU`使用率或者自定义指标(`metrics`)自动对`Pod`进行扩/缩容

- 控制管理器每隔30s(可自定义修改)查询`metrics`的资源使用情况
- 支持三种`metrics`类型
  - 预定义`metrics`: 以利用率的方式计算
  - 自定义`metrics`: 以原始值的方式计算
  - 自定义的`object metrics`
- 支持两种`metrics`查询方式: `Heapster`和自定义的`REST API`
- 支持多`metrics`

```yaml
# 资源配置中设置占用资源情况
spec: 
  template: 
    spec: 
      containers: 
        - resources: 
            limits: 
              cpu: 1000m     # 1000m CPU = 1 CPU
              memory: 2Gi
            requests: 
              cpu: 500m
              memory: 1Gi
```

```yaml
# hpa 配置
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: mysql-slave-hpa.yaml
  namespace: test
  labels:
    role: slave
spec:
  maxReplicas: 5
  minReplicas: 2
  scaleTargetRef:
    apiVersion: apps/v1
    kind: StatefulSet
    name: mysql-slave-sts
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 6

```









