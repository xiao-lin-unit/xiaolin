master

```bash
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -
```

master_token 

```bash
cat /var/lib/rancher/k3s/server/node-token
```

worker

```bash
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL=https://$master_ip:6443 K3S_TOKEN=$master_token sh -
```

example

```bash
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL=https://172.24.145.101:6443 K3S_TOKEN=K10f8e8522270212fb73c4319615f123d8f7f493224f5a7abfe9c212f6df7e6b11a::server:055071889ba4a75bebc908dcd651cfb7 sh -
```



配置`/etc/rancher/k3s/registries.yaml`

```yaml
mirrors:
  docker.io:
    endpoint:
      - "https://docker.registry.cyou"
      - "https://docker-cf.registry.cyou"
      - "https://dockercf.jsdelivr.fyi"
      - "https://docker.jsdelivr.fyi"
      - "https://dockertest.jsdelivr.fyi"
      - "https://mirror.aliyuncs.com"
      - "https://dockerproxy.com"
      - "https://mirror.baidubce.com"
      - "https://docker.m.daocloud.io"
      - "https://docker.nju.edu.cn"
      - "https://docker.mirrors.sjtug.sjtu.edu.cn"
      - "https://docker.mirrors.ustc.edu.cn"
      - "https://mirror.iscas.ac.cn"
      - "https://docker.rainbond.cc"
```



```bash
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://docker.registry.cyou","https://docker-cf.registry.cyou","https://dockercf.jsdelivr.fyi","https://docker.jsdelivr.fyi","https://dockertest.jsdelivr.fyi","https://mirror.aliyuncs.com","https://dockerproxy.com","https://mirror.baidubce.com","https://docker.m.daocloud.io","https://docker.nju.edu.cn","https://docker.mirrors.sjtug.sjtu.edu.cn","https://docker.mirrors.ustc.edu.cn","https://mirror.iscas.ac.cn","https://docker.rainbond.cc"]
}
EOF
```



```json
{
  "registry-mirrors": [
    "https://www.docker-cn.com",
    "https://hub.rat.dev",
    "https://dockerhub.icu",
    "http://mirror.azure.cn",
    "https://dockerpull.org",
    "https://dockerproxy.com",
    "https://dhub.kubesre.xyz",
    "https://docker.chenby.cn",
    "https://docker.nju.edu.cn",
    "https://docker.unsee.tech",
    "https://docker.xuanyuan.me",
    "https://docker.1panel.live",
    "https://docker.rainbond.cc",
    "https://docker.awsl9527.cn",
    "https://mirror.iscas.ac.cn",
    "https://mirror.aliyuncs.com",
    "https://docker.jsdelivr.fyi",
    "https://docker.anyhub.us.kg",
    "https://mirror.baidubce.com",
    "https://docker.hpcloud.cloud",
    "https://docker.m.daocloud.io",
    "https://docker.registry.cyou",
    "https://docker.m.daocloud.io",
    "https://dockercf.jsdelivr.fyi",
    "https://docker-cf.registry.cyou",
    "https://dockertest.jsdelivr.fyi",
    "https://docker.mirrors.ustc.edu.cn",
    "https://zermyrir.mirror.aliyuncs.com",
    "https://docker.mirrors.sjtug.sjtu.edu.cn"
  ]
}
```







