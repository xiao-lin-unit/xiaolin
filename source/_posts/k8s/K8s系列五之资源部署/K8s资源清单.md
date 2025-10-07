### 常用资源清单

#### 必选字段

| 参数名                  | 字段类型 | 说明                                                         |
| :---------------------- | :------- | :----------------------------------------------------------- |
| version                 | String   | 指 K8s API 的版本，目前基本上是 v1 ，可以用 kubectl api-versions 命令查询 |
| kind                    | String   | 指 yaml 文件定义的资源类型和角色，比如：Pod                  |
| metadata                | Object   | 元数据对象                                                   |
| metadata.name           | String   | 元数据对象的名字，比如命名 Pod 的名字                        |
| metadata.namespace      | String   | 元数据对象的命名空间（默认default）                          |
| spec                    | Object   | 详细定义对象                                                 |
| spec.containers[]       | List     | 容器列表的定义                                               |
| spec.containers[].name  | String   | 容器的名字                                                   |
| spec.containers[].image | String   | 容器镜像的名称                                               |

#### 主要字段

| 参数名                                      | 字段类型 | 说明                                                         |
| :------------------------------------------ | :------- | :----------------------------------------------------------- |
| spec.containers[].imagePullPolicy           | String   | 定义镜像的拉取策略，有Always、Never、IfNotPresent三个值可选，（1）Always：意思是每次都尝试重新拉取镜像，（2）Never：表示仅使用本地镜像，（3）IfNotPresent：如果本地有镜像就使用本地镜像，没有就拉取在线镜像。上面三个值都没设置的话，默认是Always。 |
| spec.containers[].command[]                 | List     | 指定容器启动命令，因为是数组可以指定多个，不指定则使用镜像打包时使用的启动命令。 |
| spec.containers[].args[]                    | List     | 批定容器启动命令参数，因为是数组可以指定多个。               |
| spec.containers[].workingDir                | String   | 指定容器的工作目录                                           |
| spec.containers[].volumeMounts[]            | List     | 指定容器内部的存储卷位置                                     |
| spec.containers[].volumeMounts[].name       | String   | 指定可以被容器挂载的存储卷的名称                             |
| spec.containers[].volumeMounts[].mountPath  | String   | 指定可以被挂载的存储卷的路径                                 |
| spec.containers[].volumeMounts[].readOnly   | String   | 设置存储卷路径的读写模式，true或者false，默认为读写模式      |
| spec.containers[].ports[]                   | List     | 指定容器需要用到的端口列表                                   |
| spec.containers[].ports[].name              | String   | 指定端口名称                                                 |
| spec.containers[].ports[].containerPort     | String   | 指定容器需要监听的端口号                                     |
| spec.containers[].ports[].hostPort          | String   | 指定容器所在主机需要监听的端口号，默认跟上面containerPort相同，注意设置了hostPort同一台主机无法启动该容器的相同副本（会端口冲突） |
| spec.containers[].ports[].protocol          | String   | 指定端口协议，支持TCP和UDP，默认为TCP                        |
| spec.containers[].env[]                     | List     | 指定容器运行前需要设置的环境变量列表                         |
| spec.containers[].env[].name                | String   | 指定环境变量名称                                             |
| spec.containers[].env[].value               | String   | 指定环境变量值                                               |
| spec.containers[].resources                 | Object   | 指定资源限制和资源请求的值（这里开始就是设置容器的资源上限） |
| spec.containers[].resources.limits          | Object   | 指定设置容器运行时资源的运行上限                             |
| spec.containers[].resources.limits.cpu      | String   | 指定CPU限制，单位为core数，将用于docker run --cpu-shares参数 |
| spec.containers[].resources.limits.memory   | String   | 指定MEM内存的限制，单位为MIB、GiB                            |
| spec.containers[].resources.requests        | Object   | 指定容器启动和调度时的限制设置                               |
| spec.containers[].resources.requests.cpu    | String   | CPU请求，单位为core数，容器启动时初始化可用数量              |
| spec.containers[].resources.requests.memory | String   | 内存请求，单位为MIB、GiB，容器启动时初始化可用数量           |

#### 额外字段

| 参数名                | 字段类型 | 说明                                                         |
| :-------------------- | :------- | :----------------------------------------------------------- |
| spec.restartPolicy    | String   | 定义Pod的重启策略，可选值为Always、OnFailure、默认为Always。 1. Always：Pod一旦终止运行，则无论容器是如何终止的，kubelet服务都将重启它 2.OnFailure：只有Pod以非零退出码终止时，kubelet才会重启该容器。如果容器正常结束（退出码为0），则kubelet不会重启它。 3.Never：Pod终止后，kubelet将退出码报告给master，不会重启该Pod |
| spec.nodeSelector     | Object   | 定义Node的Label过滤标签，以key:value格式指定                 |
| spec.imagePullSecrets | Object   | 定义pull镜像时使用secret名称，以name:secretkey格式指定       |
| spec.hostNetwork      | Boolean  | 定义是否使用主机网络模式，默认值是false，设置true表示使用主机网络，不使用docker网桥，同时设置了true将无法在同一台宿主机上启动第二个副本 |