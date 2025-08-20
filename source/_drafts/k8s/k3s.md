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
      - "https://docker.m.daocloud.io"
```



```bash
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://docker.m.daocloud.io"]
}
EOF
```



```json
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io"
  ]
}
```







