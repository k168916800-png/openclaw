#!/bin/bash

# 🐳 Docker Compose 快速启动脚本 (Mac/Linux)
# 这个脚本会自动配置并启动所有服务

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}     🐳 OpenClaw Docker Compose 启动向导"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 检查 Docker
check_docker() {
    echo "[1/4] 检查 Docker..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装"
        echo "请从 https://www.docker.com/products/docker-desktop 下载安装"
        exit 1
    fi
    print_success "Docker 已安装"
    docker --version
}

# 检查 Docker Compose
check_docker_compose() {
    echo ""
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose 未安装"
        echo "请运行: sudo apt-get install docker-compose -y"
        exit 1
    fi
    print_success "Docker Compose 已安装"
    docker-compose --version
    echo ""
}

# 创建配置文件
setup_configs() {
    echo "[2/4] 检查配置文件..."
    
    if [ ! -f .env ]; then
        print_warning ".env 文件不存在，正在创建..."
        if [ -f .env.example ]; then
            cp .env.example .env
            print_success "已创建 .env (从 .env.example 复制)"
        else
            cat > .env <<EOF
WEB_PORT=8000
TZ=Asia/Shanghai
PYTHONUNBUFFERED=1
EOF
            print_success "已创建默认 .env"
        fi
    else
        print_success ".env 已存在"
    fi
    
    if [ ! -f config.yaml ]; then
        if [ -f config.example.yaml ]; then
            cp config.example.yaml config.yaml
            print_success "已创建 config.yaml (从 config.example.yaml 复制)"
        else
            print_warning "未找到 config.example.yaml，跳过"
        fi
    else
        print_success "config.yaml 已存在"
    fi
    echo ""
}

# 启动服务
start_services() {
    echo "[3/4] 停止旧容器 (如果存在)..."
    docker-compose down 2>/dev/null || true
    print_success "已清理旧容器"
    echo ""
    
    echo "[4/4] 构建和启动服务..."
    docker-compose up -d --build || {
        print_error "启动失败，请检查错误信息"
        docker-compose logs
        exit 1
    }
    print_success "服务已启动"
    echo ""
}

# 等待并显示状态
show_status() {
    echo "等待服务就绪..."
    sleep 5
    
    echo ""
    docker-compose ps
    echo ""
    
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                   ✨ 启动完成！"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # 读取端口配置
    PORT=$(grep -E "^WEB_PORT" .env | cut -d'=' -f2 | tr -d ' ' || echo "8000")
    
    echo -e "${GREEN}🌐 Web 访问地址: http://localhost:${PORT}${NC}"
    echo ""
    
    echo "📋 常用命令:"
    echo "   - 查看日志:     docker-compose logs -f codex-web"
    echo "   - 查看状态:     docker-compose ps"
    echo "   - 停止服务:     docker-compose stop"
    echo "   - 完全删除:     docker-compose down"
    echo "   - 重启服务:     docker-compose restart codex-web"
    echo "   - 进入容器:     docker-compose exec codex-web bash"
    echo ""
    echo "📖 更多帮助: cat DOCKER_SETUP.md"
    echo ""
}

# 主程序
main() {
    print_header
    
    # 检查权限
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if ! docker ps >/dev/null 2>&1; then
            print_error "没有访问 Docker 的权限"
            echo "请运行: sudo usermod -aG docker \$USER"
            echo "然后重新登录或运行: newgrp docker"
            exit 1
        fi
    fi
    
    check_docker
    check_docker_compose
    setup_configs
    start_services
    show_status
}

# 执行主程序
main
