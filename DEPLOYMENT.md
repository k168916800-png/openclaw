# 📦 项目部署指南

## 🐳 Docker Compose 部署（推荐）

使用 Docker Compose 是最简单的部署方式，只需一条命令即可启动完整的应用。

### 快速启动（一键部署）

#### Windows 用户
```bash
# 双击运行
docker-start.bat

# 或在命令行执行
docker-start.bat
```

#### Mac/Linux 用户
```bash
# 给脚本执行权限
chmod +x docker-start.sh

# 运行启动脚本
./docker-start.sh
```

### 手动启动

如果不想使用自动脚本，可以手动执行以下步骤：

```bash
# 1. 复制配置文件
cp .env.example .env
cp config.example.yaml config.yaml

# 2. 启动 Docker Compose
docker-compose up -d

# 3. 查看日志
docker-compose logs -f codex-web
```

## ⚙️ 配置管理

### 环境变量 (.env)

修改 `.env` 文件来配置应用参数：

```bash
# Web 端口（默认 8000）
WEB_PORT=8000

# 时区
TZ=Asia/Shanghai

# Python 输出缓冲
PYTHONUNBUFFERED=1
```

### 应用配置 (config.yaml)

编辑 `config.yaml` 来配置应用功能：

```yaml
# 示例应用配置
log_level: INFO
api_timeout: 30
# 其他配置参数...
```

**重要：** 修改 `config.yaml` 后需要重启容器使配置生效：
```bash
docker-compose restart codex-web
```

## 📊 常用管理命令

### 查看状态
```bash
# 查看所有容器
docker-compose ps

# 查看实时日志
docker-compose logs -f codex-web

# 查看完整日志
docker-compose logs codex-web

# 查看资源使用情况
docker stats
```

### 服务控制
```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose stop

# 重启服务
docker-compose restart codex-web

# 完全删除容器和网络
docker-compose down

# 删除所有数据（谨慎操作）
docker-compose down -v
```

### 容器操作
```bash
# 进入容器内部
docker-compose exec codex-web bash

# 执行命令
docker-compose exec codex-web python -m pip list

# 查看完整容器信息
docker inspect codex-web
```

## 🔧 故障排除

### 常见问题

**Q: 容器启动失败，如何诊断？**
```bash
docker-compose logs codex-web  # 查看错误日志
docker-compose logs --tail=50 codex-web  # 查看最后 50 行
```

**Q: 如何更改 Web 端口？**
```bash
# 编辑 .env，然后重启
# WEB_PORT=8080
docker-compose down
docker-compose up -d
```

**Q: 容器一直停止或崩溃？**
```bash
# 检查日志
docker-compose logs codex-web

# 尝试重新构建
docker-compose up -d --build

# 如果还是不行，删除旧容器重新创建
docker-compose down
docker system prune -a
docker-compose up -d --build
```

**Q: 无法访问应用？**
```bash
# 检查容器是否运行
docker-compose ps

# 检查端口是否被占用（Windows）
netstat -ano | findstr :8000

# 检查防火墙设置
# 确保允许通过端口 8000（或配置的端口）
```

**Q: 权限错误 (Linux/Mac)？**
```bash
# 添加当前用户到 docker 组
sudo usermod -aG docker $USER

# 重新加载
newgrp docker

# 重试
docker-compose up -d
```

## 🔄 数据备份和恢复

### 备份数据
```bash
# 备份整个 data 目录
tar czf backup-$(date +%Y%m%d).tar.gz data/

# 或直接复制
cp -r data/ data_backup/
```

### 恢复数据
```bash
# 从备份恢复
docker-compose down
rm -rf data/
tar xzf backup-20240101.tar.gz
docker-compose up -d
```

## 🌍 网络和连接

### 主机服务访问

如果需要从容器内访问主机上的服务（如代理、数据库等），使用特殊地址：

```
http://host.docker.internal:PORT
```

已在 `docker-compose.yml` 中预配置，可直接使用。

### 容器间通信

多个容器之间可以通过服务名称通信（自动 DNS 解析）：

```
http://codex-web:8000
```

## 📈 性能优化

### 清理磁盘空间
```bash
# 删除无用容器、镜像、卷
docker system prune -a

# 同时删除未使用的卷
docker system prune -a --volumes
```

### 查看镜像大小
```bash
docker images

# 查看容器占用空间
docker ps -s
```

## 🔐 安全建议

1. **不要提交 .env 文件**
   - 已添加到 `.gitignore`
   
2. **保护敏感信息**
   - 将敏感信息放在 `.env` 文件中
   - 使用 Docker secrets（生产环境）

3. **定期更新依赖**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

4. **监控日志**
   ```bash
   docker-compose logs -f
   ```

## 📚 更多资源

- [完整 Docker 文档](DOCKER_SETUP.md)
- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)

---

**需要帮助？** 查看 `DOCKER_SETUP.md` 获取详细说明和高级配置。
