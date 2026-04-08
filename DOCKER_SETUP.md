# 🐳 Docker Compose 启动指南

本项目已配置为使用 Docker Compose，可通过一条命令快速启动所有服务。

## 📋 前置条件

- **Docker Desktop** (Windows/Mac) 或 **Docker + Docker Compose** (Linux)
  - [下载 Docker Desktop](https://www.docker.com/products/docker-desktop)
  - Linux: `sudo apt-get install docker.io docker-compose -y`

- **Git** (可选，用于克隆项目)

## 🚀 快速启动（3步）

### 第 1 步：克隆或下载项目
```bash
git clone https://github.com/k168916800-png/openclaw.git
cd openclaw
```

### 第 2 步：创建配置文件
```bash
# 复制示例配置
cp .env.example .env

# 复制项目配置文件
cp config.example.yaml config.yaml
```

### 第 3 步：启动所有服务
```bash
# 首次启动（会自动构建镜像）
docker-compose up -d

# 查看日志
docker-compose logs -f codex-web
```

✅ **完成！** 服务已在 http://localhost:8000 启动

---

## 🔧 常用命令

### 查看服务状态
```bash
docker-compose ps
```

### 查看实时日志
```bash
# 所有服务日志
docker-compose logs -f

# 仅查看 codex-web 日志
docker-compose logs -f codex-web

# 查看最后 100 行日志
docker-compose logs --tail=100 codex-web
```

### 停止服务
```bash
# 停止但保留容器
docker-compose stop

# 完全移除容器和网络
docker-compose down
```

### 重新启动服务
```bash
docker-compose restart codex-web
```

### 重新构建镜像
```bash
# 重新构建（本地源代码变更后）
docker-compose up -d --build
```

### 进入容器调试
```bash
docker-compose exec codex-web bash
```

---

## ⚙️ 配置说明

### 1. 端口配置 (.env)
修改 `.env` 文件中的 `WEB_PORT` 来改变外部访问端口：

```bash
# 默认配置
WEB_PORT=8000

# 修改为其他端口（例如 8080）
WEB_PORT=8080
```

然后重启服务：
```bash
docker-compose down
docker-compose up -d
```

### 2. 项目配置 (config.yaml)
编辑 `config.yaml` 配置项目参数，容器会自动使用该配置：

```yaml
# 示例配置
log_level: INFO
api_timeout: 30
...
```

修改后重启容器使配置生效：
```bash
docker-compose restart codex-web
```

### 3. 数据持久化
所有数据存储在 `./data` 目录（会自动创建）：
```
data/
├── config.yaml       # 项目配置
├── logs/            # 日志文件
└── cache/           # 缓存数据
```

删除容器不会丢失数据（重启会恢复）。

---

## 🐛 故障排除

### 问题 1：端口已被占用
```bash
# 查看占用端口的进程
netstat -ano | findstr :8000  # Windows
lsof -i :8000                 # Mac/Linux

# 解决方案：修改 .env 中的 WEB_PORT
WEB_PORT=8080  # 改为其他端口
docker-compose down
docker-compose up -d
```

### 问题 2：无法访问服务
```bash
# 检查容器是否运行
docker-compose ps

# 查看错误日志
docker-compose logs codex-web

# 检查网络连接
docker-compose exec codex-web curl http://localhost:8000/api/stats
```

### 问题 3：镜像构建失败
```bash
# 删除旧容器和镜像
docker-compose down
docker system prune -a

# 重新构建
docker-compose up -d --build
```

### 问题 4：权限错误 (Linux)
```bash
# 添加当前用户到 docker 组
sudo usermod -aG docker $USER
newgrp docker
```

---

## 📊 监控和维护

### 查看资源使用
```bash
docker stats
```

### 清理无用镜像和文件
```bash
# 清理系统
docker system prune -a --volumes
```

### 查看完整日志
```bash
# 导出日志到文件
docker-compose logs codex-web > codex.log
```

---

## 🔄 自动更新

Watchtower 容器会每 24 小时自动检查并更新镜像（仅当有新版本时）：

### 禁用自动更新
修改 `docker-compose.yml` 中 watchtower 的 command：
```yaml
watchtower:
  command: --run-once  # 仅运行一次，不自动更新
```

---

## 📱 容器内访问主机服务

如果需要容器内访问主机服务（例如代理），使用：
```
http://host.docker.internal:PORT
```

已在 docker-compose.yml 中配置，可直接使用。

---

## 🎯 部署到生产环境

### 使用 Docker 私有仓库
```bash
# 1. 构建镜像
docker build -t my-registry/openclaw:v1.0 .

# 2. 推送到私有仓库
docker push my-registry/openclaw:v1.0

# 3. 修改 docker-compose.yml
# image: wenfxl/wenfxl-codex-manager:latest
# 改为
# image: my-registry/openclaw:v1.0

# 4. 部署
docker-compose pull
docker-compose up -d
```

### 使用 Docker Swarm
```bash
docker swarm init
docker stack deploy -c docker-compose.yml openclaw
```

### 使用 Kubernetes
```bash
# 转换 compose 文件为 k8s manifests
kompose convert -f docker-compose.yml -o k8s/
kubectl apply -f k8s/
```

---

## 💡 最佳实践

1. **定期备份数据**
   ```bash
   cp -r ./data ./data.backup
   ```

2. **使用 .env 管理敏感信息**
   - 不要在 docker-compose.yml 中硬编码敏感信息
   - 将 .env 添加到 .gitignore

3. **监控日志**
   ```bash
   docker-compose logs -f --tail=50
   ```

4. **定期清理**
   ```bash
   docker system prune -a
   ```

5. **健康检查**
   已配置自动健康检查，可通过以下命令验证：
   ```bash
   docker inspect codex-web | grep -A 20 "Health"
   ```

---

## 📞 常见问题

**Q: 如何更新代码后重新部署？**
```bash
git pull origin main
docker-compose up -d --build
```

**Q: 如何备份项目数据？**
```bash
docker-compose exec codex-web tar czf /app/data/backup.tar.gz /app/data/
docker cp wenfxl_codex_manager:/app/data/backup.tar.gz ./
```

**Q: 如何在不同主机间迁移容器？**
```bash
# 源主机：导出镜像和数据
docker save wenfxl/wenfxl-codex-manager:latest > image.tar
cp -r data/ data-backup/

# 目标主机：导入镜像和数据
docker load < image.tar
cp -r data-backup/ data/
docker-compose up -d
```

---

## 🎓 更多资源

- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 参考](https://docs.docker.com/compose/reference/)
- [项目 README](./README.md)

---

**有任何问题？** 提交 Issue 或查看项目文档。
