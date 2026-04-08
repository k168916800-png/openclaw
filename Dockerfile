FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 复制并安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . .

# 清理不必要的文件
RUN rm -rf utils/auth_core/*.py 2>/dev/null || true

# 创建数据目录
RUN mkdir -p /app/data && chmod 755 /app/data

# 暴露端口
EXPOSE 8000

# 环境变量
ENV PYTHONUNBUFFERED=1
ENV TZ=Asia/Shanghai

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/api/stats || exit 1

# 启动命令
CMD ["python", "wfxl_openai_regst.py"]