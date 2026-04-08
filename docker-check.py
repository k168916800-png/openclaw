#!/usr/bin/env python3
"""
🐳 Docker Compose 启动检查工具
验证环境和配置是否正确
"""

import os
import sys
import subprocess
import json
from pathlib import Path

class DockerChecker:
    def __init__(self):
        self.project_root = Path(__file__).parent
        self.errors = []
        self.warnings = []
        self.success = []
    
    def check_docker(self):
        """检查 Docker 是否安装"""
        try:
            result = subprocess.run(['docker', '--version'], capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                self.success.append(f"✅ Docker 已安装: {result.stdout.strip()}")
                return True
            else:
                self.errors.append("❌ Docker 版本检查失败")
                return False
        except FileNotFoundError:
            self.errors.append("❌ Docker 未安装，请从 https://www.docker.com/products/docker-desktop 下载")
            return False
        except subprocess.TimeoutExpired:
            self.errors.append("❌ Docker 命令超时")
            return False
    
    def check_docker_compose(self):
        """检查 Docker Compose 是否安装"""
        try:
            result = subprocess.run(['docker-compose', '--version'], capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                self.success.append(f"✅ Docker Compose 已安装: {result.stdout.strip()}")
                return True
            else:
                self.errors.append("❌ Docker Compose 版本检查失败")
                return False
        except FileNotFoundError:
            self.errors.append("❌ Docker Compose 未安装")
            return False
        except subprocess.TimeoutExpired:
            self.errors.append("❌ Docker Compose 命令超时")
            return False
    
    def check_files(self):
        """检查必需文件"""
        required_files = [
            'docker-compose.yml',
            'Dockerfile',
            'requirements.txt',
            'wfxl_openai_regst.py',
        ]
        
        for file in required_files:
            file_path = self.project_root / file
            if file_path.exists():
                self.success.append(f"✅ 文件存在: {file}")
            else:
                self.errors.append(f"❌ 文件缺失: {file}")
        
        # 检查示例文件
        example_files = ['.env.example', 'config.example.yaml']
        for file in example_files:
            file_path = self.project_root / file
            if file_path.exists():
                self.success.append(f"✅ 示例文件存在: {file}")
            else:
                self.warnings.append(f"⚠️  示例文件缺失（可选）: {file}")
    
    def check_docker_compose_file(self):
        """验证 docker-compose.yml 的正确性"""
        try:
            result = subprocess.run(
                ['docker-compose', 'config'],
                cwd=self.project_root,
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode == 0:
                self.success.append("✅ docker-compose.yml 语法正确")
                return True
            else:
                self.errors.append(f"❌ docker-compose.yml 配置错误: {result.stderr}")
                return False
        except Exception as e:
            self.errors.append(f"❌ 无法验证 docker-compose.yml: {str(e)}")
            return False
    
    def check_dockerfile(self):
        """检查 Dockerfile 的完整性"""
        dockerfile_path = self.project_root / 'Dockerfile'
        if not dockerfile_path.exists():
            return False
        
        try:
            with open(dockerfile_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            required_keywords = ['FROM', 'WORKDIR', 'COPY', 'RUN', 'EXPOSE', 'CMD']
            missing = [kw for kw in required_keywords if kw not in content]
            
            if not missing:
                self.success.append("✅ Dockerfile 结构完整")
                return True
            else:
                self.warnings.append(f"⚠️  Dockerfile 缺少关键字: {', '.join(missing)}")
                return True
        except Exception as e:
            self.errors.append(f"❌ 无法读取 Dockerfile: {str(e)}")
            return False
    
    def check_requirements(self):
        """检查 requirements.txt 是否存在且非空"""
        requirements_path = self.project_root / 'requirements.txt'
        if not requirements_path.exists():
            self.errors.append("❌ requirements.txt 文件缺失")
            return False
        
        try:
            with open(requirements_path, 'r', encoding='utf-8') as f:
                lines = [l.strip() for l in f if l.strip() and not l.startswith('#')]
            
            if lines:
                self.success.append(f"✅ requirements.txt 包含 {len(lines)} 个依赖")
                return True
            else:
                self.errors.append("❌ requirements.txt 为空")
                return False
        except Exception as e:
            self.errors.append(f"❌ 无法读取 requirements.txt: {str(e)}")
            return False
    
    def check_startup_scripts(self):
        """检查启动脚本"""
        scripts = ['docker-start.bat', 'docker-start.sh']
        for script in scripts:
            script_path = self.project_root / script
            if script_path.exists():
                self.success.append(f"✅ 启动脚本存在: {script}")
            else:
                self.warnings.append(f"⚠️  启动脚本缺失（可选）: {script}")
    
    def check_docker_daemon(self):
        """检查 Docker daemon 是否运行"""
        try:
            result = subprocess.run(['docker', 'info'], capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                self.success.append("✅ Docker daemon 正在运行")
                return True
            else:
                self.errors.append("❌ Docker daemon 未运行，请启动 Docker Desktop 或 Docker 服务")
                return False
        except Exception as e:
            self.errors.append(f"❌ 无法检查 Docker daemon: {str(e)}")
            return False
    
    def report(self):
        """生成检查报告"""
        print("\n" + "="*60)
        print("🐳 Docker Compose 环境检查报告")
        print("="*60 + "\n")
        
        if self.success:
            print("✅ 成功项:")
            for msg in self.success:
                print(f"   {msg}")
        
        if self.warnings:
            print("\n⚠️  警告:")
            for msg in self.warnings:
                print(f"   {msg}")
        
        if self.errors:
            print("\n❌ 错误:")
            for msg in self.errors:
                print(f"   {msg}")
        
        print("\n" + "="*60)
        if not self.errors:
            print("✨ 所有检查通过！可以开始部署")
            print("\n快速启动:")
            if sys.platform.startswith('win'):
                print("   docker-start.bat")
            else:
                print("   chmod +x docker-start.sh && ./docker-start.sh")
            print("\n或者:")
            print("   docker-compose up -d")
            return 0
        else:
            print(f"❌ 发现 {len(self.errors)} 个错误，请修复后重试")
            return 1

def main():
    checker = DockerChecker()
    
    print("🔍 正在检查环境...\n")
    
    # 执行所有检查
    checker.check_docker()
    checker.check_docker_compose()
    checker.check_docker_daemon()
    checker.check_files()
    checker.check_requirements()
    checker.check_dockerfile()
    checker.check_docker_compose_file()
    checker.check_startup_scripts()
    
    # 生成报告
    return checker.report()

if __name__ == '__main__':
    sys.exit(main())
