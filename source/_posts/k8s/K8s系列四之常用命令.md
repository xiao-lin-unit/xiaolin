---
title: K8s系列(四)---常用命令
top: 3
cover: 1
date: 2025-09-07 13:44:19
tags:
 - k8s
categories:
 - k8s
---

<!-- toc -->

### 前言

`k8s`使用`kubectl`命令行工具执行各种操作, 其基本使用格式

```bash
kubectl [command] [TYPE] [NAME] [flags]
```

> [TYPE]的常用的选项及别名如下
>
> `pods`: `po`
>
> `deployments`: `deploy`
>
> `services`: `svc`
>
> `namespace`: `ns`
>
> `nodes`: `no`
>
> `ReplicaSet`: `rc`

> [COMMAND]的选项可以到[Kubernetes官网](https://kubernetes.io/zh-cn/docs/reference/kubectl/generated/)查看, 本篇只讲几个常用命令

### 常用命令

#### 基于配置应用部署

这个命令使用频率非常高, 所以先放在首位, 这个命令的作用是基于文件创建或者修改资源

```bash
kubectl apply -f filename

kubectl apply -f ./my.yaml
```

#### 创建对象

```bash
kubectl create -f FILENAME

# 创建资源
kubectl create -f ./my.yaml
kubectl create -f ./my.json
# 创建多个资源
kubectl create -f ./my1.yaml ./my2.yaml
# 使用目录下的配置创建资源
kubectl create -f ./dir
# 使用远程配置文件创建资源
kubectl create -f https://example.com/example.yaml

# 基于传入到标准输入的 JSON 创建一个 Pod
cat pod.json | kubectl create -f -
# 以 JSON 编辑 registry.yaml 中的数据，然后使用已编辑的数据来创建资源
kubectl create -f registry.yaml --edit -o json

# 使用run创建并运行一个镜像资源
kubectl run NAME --image=image [--env="key=value"] [--port=port] [--dry-run=server|client] [--overrides=inline-json] [--command] -- [COMMAND] [args...]

kubectl run nginx --image=nginx
```

根据资源也可以获取到对应的配置文件

```bash
kubectl explain TYPE [--recursive=FALSE|TRUE] [--api-version=api-version-group] [-o|--output=plaintext|plaintext-openapiv2]

# 获取资源及其字段的文档
kubectl explain pods
  
# 获取资源中的所有字段
kubectl explain pods --recursive
  
# 获取被支持的 API 版本中 Deployment 的解释
kubectl explain deployments --api-version=apps/v1
  
# 获取资源中特定字段的文档
kubectl explain pods.spec.containers
  
# 获取资源的不同格式的文档
kubectl explain deployment --output=plaintext-openapiv2
```

### 查询资源

```bash
kubectl get [(-o|--output=)json|yaml|name|go-template|go-template-file|template|templatefile|jsonpath|jsonpath-as-json|jsonpath-file|custom-columns|custom-columns-file|wide] (TYPE[.VERSION][.GROUP] [NAME | -l label] | TYPE[.VERSION][.GROUP]/NAME ...) [flags]

# 以 ps 输出格式列举所有 Pod
kubectl get pods
  
# 以 ps 输出格式列举所有 Pod，并提供更多信息（如节点名称）
kubectl get pods -o wide
  
# 以 ps 输出格式列举指定名称的单个副本控制器
kubectl get replicationcontroller web
  
# 以 JSON 输出格式列举 "apps" API 组 "v1" 版本中的 Deployment
kubectl get deployments.v1.apps -o json
  
# 以 JSON 输出格式列举单个 Pod
kubectl get -o json pod web-pod-13je7
  
# 以 JSON 输出格式列举在 "pod.yaml" 中以 type 和 name 指定的 Pod
kubectl get -f pod.yaml -o json
  
# 列举 kustomization.yaml 所在目录（例如 dir/kustomization.yaml）中的资源
kubectl get -k dir/
  
# 仅返回指定 Pod 的 phase 值
kubectl get -o template pod/web-pod-13je7 --template={{.status.phase}}
  
# 在自定义列中列举资源信息
kubectl get pod test-pod -o custom-columns=CONTAINER:.spec.containers[0].name,IMAGE:.spec.containers[0].image
  
# 以 ps 输出格式同时列举所有副本控制器和服务
kubectl get rc,services
  
# 按类型和名称列举一个或多个资源
kubectl get rc/web service/frontend pods/web-pod-13je7
  
# 列举单个 Pod 的 “status” 子资源
kubectl get pod web-pod-13je7 --subresource status

# 列出 “backend” 命名空间中的所有 Deployment
kubectl get deployments.apps --namespace backend
  
# 列出所有命名空间中存在的所有 Pod
kubectl get pods --all-namespaces


# 获取信息时可以指定格式化输出方式
# -o json 以json格式输出
# -o name 仅打印资源名称
# -o wide 以纯文本格式输出
# -o yaml 以yaml格式输出

```

### 更新资源

```bash
kubectl edit (RESOURCE/NAME | -f FILENAME)

# 编辑名为 "registry" 的 Service
kubectl edit svc/registry

# 编辑资源配置文件
kubectl edit -f ./my.yaml
  
# 使用替代编辑器
KUBE_EDITOR="nano" kubectl edit svc/registry
  
# 使用 v1 API 格式编辑 JSON 中的 Job "myjob"
kubectl edit job.v1.batch/myjob -o json
  
# 在 YAML 中编辑 Deployment "mydeployment" 并将修改后的配置保存在其注解中
kubectl edit deployment/mydeployment -o yaml --save-config
  
# 编辑 "mydeployment" Deployment 的 "status" 子资源
kubectl edit deployment mydeployment --subresource='status'
```

### 删除资源

```bash
kubectl delete ([-f FILENAME] | [-k DIRECTORY] | TYPE [(NAME | -l label | --all)])

# 使用 pod.json 中指定的类型和名称删除一个 Pod
kubectl delete -f ./pod.json

# 基于包含 kustomization.yaml 的目录（例如 dir/kustomization.yaml）中的内容删除资源
kubectl delete -k dir

# 删除所有以 '.json' 结尾的文件中的资源
kubectl delete -f '*.json'

# 基于传递到标准输入的 JSON 中的类型和名称删除一个 Pod
cat pod.json | kubectl delete -f -

# 删除名称为 "baz" 和 "foo" 的 Pod 和 Service
kubectl delete pod,service baz foo

# 删除打了标签 name=myLabel 的 Pod 和 Service
kubectl delete pods,services -l name=myLabel

# 以最小延迟删除一个 Pod
kubectl delete pod foo --now

# 强制删除一个死节点上的 Pod
kubectl delete pod foo --force

# 删除所有 Pod
kubectl delete pods --all

# 仅在用户确认删除的情况下删除所有 Pod
kubectl delete pods --all --interactive
```

### 管理资源上线

```bash
kubectl rollout SUBCOMMAND

# SUBCOMMAND选项有
# history: 查看上线历史记录
# pause: 将资源标记为已暂停
# restart: 重启资源
# resume: 恢复暂停的资源
# status: 显示状态
# undo: 撤销上一次上线

# 回滚到先前的 Deployment 版本
kubectl rollout undo deployment/abc
  
# 检查 Daemonset 的部署状态
kubectl rollout status daemonset/foo
  
# 重启 Deployment
kubectl rollout restart deployment/abc
  
# 重启带有 'app=nginx' 标签的 Deployment
kubectl rollout restart deployment --selector=app=nginx
```

### 配置资源

```bash
kubectl set SUBCOMMAND
# SUBCOMMAND选项有
# env: 更新pod模板的环境变量
# image: 更新pod模板的镜像
# resources: 使用pod模板更新对象的资源请求/限制
# selector: 设置资源上的选择器
# serviceaccount: 更新资源的服务账户
# subject: 更新角色绑定或集群角色绑定中的用户, 组或服务账户
```

### 修改`kubeconfig`文件

```bash
kubectl config SUBCOMMAND
# SUBCOMMAND选项有
# current-context: 显示当前上下文
# delete-cluster: 从kubeconfig删除出指定集群信息
# delete-context: 从kubeconfig删除指定的上下文信息
# delect-user: 从kubeconfig中删除指定的用户信息
# get-clusters: 显示kubeconfig中指定的集群信息
# get-contexts: 显示kubeconfig中指定的上下文信息
# get-users: 显示kubeconfig中指定的用户信息
# rename-context: 重命名kubeconfig文件的上下文
# set: 在kubeconfig中设置单个值
# set-cluser: 在kubeconfig中设置集群条目
# set-context: 在kubeconfig中设置上下文条目
# setcredentials: 在kubeconfig中设置用户条目
# unset: 取消设置kubeconfig文件中的单个值
# use-context: 设置在kubeconfig文件中的当前上下文
# view: 显示合并的kubeconfig设置或指定的kubeconfig文件
```

### 显示资源细节

```bash
kubectl describe TYPE NAME_PREFIX
kubectl describe (-f FILENAME | TYPE [NAME_PREFIX | -l label] | TYPE/NAME)

# 描述一个节点
kubectl describe nodes kubernetes-node-emt8.c.myproject.internal
  
# 描述一个 Pod
kubectl describe pods/nginx
  
# 描述在 "pod.json" 中通过类别和名称标识的 Pod
kubectl describe -f pod.json
  
# 描述所有 Pod
kubectl describe pods
  
# 描述带标签 name=myLabel 的 Pod
kubectl describe pods -l name=myLabel
  
# 描述由 “frontend” 副本控制器管理的所有 Pod
# （副本控制器所创建的 Pod 在 Pod 名称中带有此副本控制器的名称作为前缀）
kubectl describe pods frontend
```

### 扩缩容

```bash
kubectl scale [--resource-version=version] [--current-replicas=count] --replicas=COUNT (-f FILENAME | TYPE NAME)

# 将名为 “foo” 的 ReplicaSet 扩缩容到 3 个副本
kubectl scale --replicas=3 rs/foo
  
# 将 "foo.yaml" 中以 type 和 name 指定的某资源扩缩容到 3 个副本
kubectl scale --replicas=3 -f foo.yaml
  
# 如果名为 mysql 的 Deployment 当前有 2 个副本，则将 mysql 扩容到 3 个副本
kubectl scale --current-replicas=2 --replicas=3 deployment/mysql
  
# 扩缩容多个 ReplicationController
kubectl scale --replicas=5 rc/example1 rc/example2 rc/example3
  
# 将名为 “web” 的 StatefulSet 扩缩容到 3 个副本
kubectl scale --replicas=3 statefulset/web
```

