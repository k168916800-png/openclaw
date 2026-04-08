# Docker Compose 部分（添加到 README.md）

---

## 🐳 快速开始 - Docker Compose 部署

最简单的部署方式！只需一条命令即可启动完整应用。

### 前置条件

- **Docker Desktop** (Windows/Mac): https://www.docker.com/products/docker-desktop
- **Docker + Docker Compose** (Linux): `sudo apt-get install docker.io docker-compose -y`

### 一键启动（推荐）

#### Windows 用户
```bash
# 双击运行
docker-start.bat
```

#### Mac/Linux 用户
```bash
chmod +x docker-start.sh
./docker-start.sh
```

### 手动启动
```bash
# 复制配置文件
cp .env.example .env
cp config.example.yaml config.yaml

# 启动
docker-compose up -d

# 完成！访问 http://localhost:8000
```

### 常用命令

```bash
# 查看状态
docker-compose ps              # 容器列表和端口

# 查看日志
docker-compose logs -f codex-web    # 实时日志

# 停止/重启
docker-compose stop            # 停止服务
docker-compose restart codex-web   # 重启

# 进入容器
docker-compose exec codex-web bash

# 配置
nano .env                      # 修改端口等配置
nano config.yaml               # 修改应用配置

# 清理
docker-compose down            # 删除容器
docker system prune -a         # 清理无用文件
```

### 使用 Makefile（Mac/Linux）

```bash
make help              # 显示所有命令
make start             # 启动服务
make logs-tail         # 实时日志
make restart           # 重启
make shell             # 进入容器
make ps                # 查看状态
make clean             # 清理
```

### Docker Compose 文档

- 📖 **快速指南**: 详见 `DEPLOYMENT.md`
- 📚 **完整文档**: 详见 `DOCKER_SETUP.md`
- ⚙️ **技术细节**: 详见 `DOCKER_DEPLOYMENT_UPGRADE.md`

### 常见问题

**Q: 如何改变 Web 端口？**
```bash
# 编辑 .env
WEB_PORT=8080

# 重启
docker-compose down
docker-compose up -d
```

**Q: 数据会丢失吗？**
否。所有数据存储在 `./data` 目录中。删除容器不会丢失数据。

**Q: 如何更新应用？**
```bash
git pull origin main
docker-compose up -d --build
```

---
