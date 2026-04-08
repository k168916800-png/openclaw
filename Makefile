.PHONY: help start stop restart logs ps clean build down shell status update logs-tail

# 默认目标
help:
	@echo "🐳 OpenClaw Docker Compose 常用命令"
	@echo ""
	@echo "启动服务:"
	@echo "  make start          - 启动所有服务"
	@echo "  make build          - 重新构建镜像后启动"
	@echo ""
	@echo "停止服务:"
	@echo "  make stop           - 停止所有服务"
	@echo "  make restart        - 重启所有服务"
	@echo "  make down           - 完全删除容器和网络"
	@echo ""
	@echo "日志和状态:"
	@echo "  make logs           - 查看日志（最后 50 行）"
	@echo "  make logs-tail      - 跟踪实时日志"
	@echo "  make status         - 查看容器状态"
	@echo "  make ps             - 查看容器列表和端口"
	@echo ""
	@echo "容器操作:"
	@echo "  make shell          - 进入 codex-web 容器"
	@echo "  make clean          - 清理无用镜像和文件"
	@echo "  make update         - 更新镜像并重启"
	@echo ""

# 启动服务
start:
	@echo "✅ 启动所有服务..."
	docker-compose up -d
	@echo "✨ 服务已启动"
	@sleep 3
	@make ps

# 停止服务
stop:
	@echo "🛑 停止所有服务..."
	docker-compose stop
	@echo "✅ 已停止"

# 重启服务
restart:
	@echo "🔄 重启所有服务..."
	docker-compose restart
	@echo "✅ 已重启"
	@sleep 2
	@make ps

# 完全删除
down:
	@echo "⚠️  完全删除容器和网络..."
	docker-compose down
	@echo "✅ 已删除"

# 查看日志
logs:
	docker-compose logs --tail=50 codex-web

# 实时日志
logs-tail:
	docker-compose logs -f codex-web

# 查看状态
status:
	@echo "📊 Docker 资源使用:"
	@docker stats --no-stream

# 容器列表
ps:
	@echo "📋 容器状态:"
	@docker-compose ps
	@echo ""
	@echo "🌐 访问地址:"
	@grep -E "^WEB_PORT" .env > /dev/null && PORT=$$(grep -E "^WEB_PORT" .env | cut -d'=' -f2 | tr -d ' ') || PORT=8000; \
	echo "   http://localhost:$$PORT" || echo "   http://localhost:8000"

# 进入容器
shell:
	docker-compose exec codex-web bash

# 重新构建并启动
build:
	@echo "🔨 重新构建镜像..."
	docker-compose up -d --build
	@echo "✅ 构建完成"
	@sleep 3
	@make ps

# 清理
clean:
	@echo "🧹 清理无用的 Docker 资源..."
	docker system prune -a --volumes -f
	@echo "✅ 已清理"

# 更新镜像
update:
	@echo "📦 更新镜像..."
	docker-compose pull
	docker-compose up -d
	@echo "✅ 已更新"
	@make ps

# 快速配置和启动
quickstart: start logs

# 显示帮助
.DEFAULT_GOAL := help
