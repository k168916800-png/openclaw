@echo off
REM 🐳 Docker Compose 快速启动脚本 (Windows)
REM 这个脚本会自动配置并启动所有服务

setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║     🐳 OpenClaw Docker Compose 启动向导                    ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM 检查 Docker 是否安装
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker 未安装或不在 PATH 中
    echo 请从 https://www.docker.com/products/docker-desktop 下载 Docker Desktop
    pause
    exit /b 1
)

echo ✅ Docker 已安装
docker --version
echo.

REM 检查 Docker Compose
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose 未安装
    echo 请更新 Docker Desktop 或单独安装 Docker Compose
    pause
    exit /b 1
)

echo ✅ Docker Compose 已安装
docker-compose --version
echo.

REM 正式开始
echo [1/4] 检查配置文件...
if not exist .env (
    echo ⚠️  .env 文件不存在，正在创建...
    if exist .env.example (
        copy .env.example .env >nul
        echo ✅ 已创建 .env (从 .env.example 复制)
    ) else (
        echo.
        echo > .env REM Default configuration
        echo WEB_PORT=8000 >> .env
        echo TZ=Asia/Shanghai >> .env
        echo PYTHONUNBUFFERED=1 >> .env
        echo ✅ 已创建默认 .env
    )
)

if not exist config.yaml (
    echo ⚠️  config.yaml 不存在，检查示例文件...
    if exist config.example.yaml (
        copy config.example.yaml config.yaml >nul
        echo ✅ 已创建 config.yaml (从 config.example.yaml 复制)
    ) else (
        echo ⚠️  找不到 config.example.yaml，跳过 config.yaml 创建
    )
) else (
    echo ✅ config.yaml 已存在
)

echo.
echo [2/4] 停止旧容器 (如果存在)...
docker-compose down 2>nul
echo ✅ 已清理旧容器
echo.

echo [3/4] 构建和启动服务...
docker-compose up -d --build
if errorlevel 1 (
    echo ❌ 启动失败，请检查错误信息
    docker-compose logs
    pause
    exit /b 1
)

echo ✅ 服务已启动
echo.

echo [4/4] 等待服务就绪...
timeout /t 5 >nul
docker-compose ps
echo.

echo ╔════════════════════════════════════════════════════════════╗
echo ║                   ✨ 启动完成！                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

for /f "tokens=3" %%i in ('findstr /R "WEB_PORT" .env') do set PORT=%%i
if "!PORT!"=="" set PORT=8000

echo 🌐 Web 访问地址: http://localhost:%PORT%
echo.
echo 📋 常用命令:
echo   - 查看日志:     docker-compose logs -f codex-web
echo   - 停止服务:     docker-compose stop
echo   - 完全删除:     docker-compose down
echo   - 进入容器:     docker-compose exec codex-web bash
echo   - 查看帮助:     cat DOCKER_SETUP.md
echo.

pause
