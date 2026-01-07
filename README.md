# Agent Sandbox (SAS)

**Secure Agentic Sandbox - 为 AI Agent 打造的安全、隔离且持久化的沙盒环境**

[![Docker](https://img.shields.io/badge/Docker-Required-2496ED?logo=docker)](https://www.docker.com/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-lightgrey)]()
[![License](https://img.shields.io/badge/License-MIT-green)]()

## 📖 概述

Agent Sandbox 是一个专为 AI Agent（如 Claude Code）设计的隔离运行环境，提供：

- **完全隔离** - 基于 Docker 容器，隔离存储、进程、网络
- **预装浏览器** - 内置 Chromium 浏览器，Agent 可直接操作
- **VNC 远程桌面** - 通过 noVNC 在浏览器中实时查看图形界面
- **持久化存储** - 项目文件和配置自动挂载，重启不丢失
- **资源限制** - 可配置 CPU、内存、共享内存限制
- **开箱即用** - 一键启动，自动健康检查

## 🎯 核心特性

### 🔒 安全隔离

- 每个项目独立容器，互不干扰
- 宿主机免受潜在危险操作影响
- 支持同时运行多个项目沙盒

### 🌐 浏览器支持

- Chromium 浏览器（Playwright 提供）
- 支持图形界面操作
- 预配置 `--no-sandbox` 参数
- 支持中文字体渲染

### 🖥️ 图形界面

- Xvfb 虚拟显示器（1280x800）
- Openbox 窗口管理器
- VNC Server (端口 5900)
- noVNC Web 界面 (端口 6080)

### 🤖 Agent 支持

- Claude Code CLI 预装
- 配置持久化（挂载 `~/.claude_config_docker`）
- 工作目录自动挂载
- 支持 ANTHROPIC_API_KEY 环境变量

## 🏗️ 架构设计

```
┌─────────────────────────────────────────────────┐
│                  宿主机 (Host)                   │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │     Docker Container (Agent Sandbox)      │ │
│  │                                           │ │
│  │  ┌─────────────┐  ┌──────────────────┐   │ │
│  │  │   Xvfb      │  │   Openbox WM     │   │ │
│  │  │  (Display)  │  │  (Window Mgr)    │   │ │
│  │  └─────────────┘  └──────────────────┘   │ │
│  │         │                  │              │ │
│  │  ┌──────▼──────────────────▼──────────┐   │ │
│  │  │      Chromium Browser              │   │ │
│  │  │  (Playwright managed)              │   │ │
│  │  └────────────────────────────────────┘   │ │
│  │         │                                 │ │
│  │  ┌──────▼──────────┐  ┌───────────────┐  │ │
│  │  │   VNC Server    │  │  Claude Code  │  │ │
│  │  │   (Port 5900)   │  │     CLI       │  │ │
│  │  └────────┬────────┘  └───────────────┘  │ │
│  │           │                               │ │
│  │  ┌────────▼────────┐                      │ │
│  │  │     noVNC       │                      │ │
│  │  │   (Port 6080)   │◄─────────────────┐  │ │
│  │  └─────────────────┘                  │  │ │
│  │                                        │  │ │
│  │  Volumes:                              │  │ │
│  │  • /workspace ◄─ 项目目录              │  │ │
│  │  • ~/.claude  ◄─ Claude 配置           │  │ │
│  └────────────────────────────────────────┼──┘ │
│                                           │    │
│         浏览器访问 http://localhost:6080  │    │
└───────────────────────────────────────────┼────┘
                                            │
                                     宿主机浏览器
```

## 🚀 快速开始

### 前置要求

- Docker Desktop（已安装并运行）
- macOS 或 Linux 系统

### 1. 构建镜像

```bash
cd /path/to/agent_box
docker build -t agent-box-image .
```

构建时间约 3-5 分钟，下载内容包括：
- Ubuntu 22.04 基础镜像
- Node.js 20 + npm
- Chromium 浏览器（~280MB）
- Claude Code CLI

### 2. 创建配置目录

```bash
mkdir -p ~/.claude_config_docker
```

### 3. 启动沙盒

```bash
cd ~/your-project-directory
/path/to/agent_box/run-agent.sh
```

或自定义端口：
```bash
/path/to/agent_box/run-agent.sh 8080
```

### 4. 访问 VNC 界面

在浏览器打开：`http://localhost:6080`

### 5. 首次登录 Claude

在容器终端内：
```bash
claude login
```

按提示在 VNC 浏览器中完成登录。登录信息会保存到 `~/.claude_config_docker/`，下次启动自动加载。

## 📂 项目结构

```
agent_box/
├── Dockerfile          # 镜像定义
├── entrypoint.sh       # 容器启动脚本
├── run-agent.sh        # 智能启动器
└── README.md           # 本文档
```

## 🔧 配置说明

### 资源限制

编辑 `run-agent.sh` 修改默认值：

```bash
MEMORY_LIMIT="4g"      # 内存限制
CPU_LIMIT="2"          # CPU 核心数
SHM_SIZE="2gb"         # 共享内存（Chrome 需要）
```

### 分辨率调整

编辑 `entrypoint.sh` 或在 `run-agent.sh` 中添加环境变量：

```bash
-e RESOLUTION=1920x1080
```

### 环境变量

```bash
# Claude API Key（可选）
export ANTHROPIC_API_KEY="your-api-key"

# 浏览器参数（已预设）
CHROME_OPTS="--no-sandbox --disable-dev-shm-usage"
```

## 📚 使用指南

### 基本操作

```bash
# 启动沙盒（首次）
./run-agent.sh

# 启动沙盒（自定义端口）
./run-agent.sh 8080

# 停止容器
./run-agent.sh --stop

# 删除容器
./run-agent.sh --remove

# 查看日志
./run-agent.sh --logs

# 帮助信息
./run-agent.sh --help
```

### 在沙盒内操作

```bash
# 启动浏览器
google-chrome

# 运行 Claude Code
claude

# 查看工具版本
google-chrome --version
claude --version
node --version
python3 --version

# 安装 Python 包
pip3 install requests

# 安装 Node.js 包
npm install axios
```

### 多项目管理

每个项目目录会自动创建独立容器：

```bash
cd ~/project-a
./run-agent.sh  # 创建容器 agent_box_project-a

cd ~/project-b
./run-agent.sh  # 创建容器 agent_box_project-b
```

## 🐛 故障排查

### 问题 1: 容器启动失败 - Display 0 已存在

**现象：**
```
Fatal server error:
Server is already active for display 0
```

**解决：**
删除旧容器重新启动：
```bash
./run-agent.sh --remove
./run-agent.sh
```

**原因：** 容器重启时 X server 锁文件未清理（已在 v2.0 修复）

---

### 问题 2: Chromium 页面崩溃 (Aw, Snap!)

**现象：** 浏览器打开网页后崩溃

**解决：** 确保 `--shm-size` 参数至少 2GB：
```bash
docker run --shm-size=2gb ...
```

**原因：** Chrome 依赖共享内存，Docker 默认仅 64MB

---

### 问题 3: 中文显示为方块

**现象：** 网页中文显示异常

**解决：** 已在 Dockerfile 中安装字体包：
```dockerfile
fonts-noto-cjk fonts-wqy-zenhei
```

如仍有问题，进入容器安装额外字体：
```bash
sudo apt-get update
sudo apt-get install fonts-noto-cjk-extra
```

---

### 问题 4: Claude 登录失败

**现象：** `claude login` 无法保存凭证

**检查：**
```bash
# 确认挂载路径正确
docker inspect <container_name> | grep Mounts -A 10

# 应该看到：
# ~/.claude_config_docker -> /home/developer/.claude
```

**解决：**
```bash
# 手动创建目录
mkdir -p ~/.claude_config_docker

# 检查权限
ls -la ~/.claude_config_docker
```

---

### 问题 5: 端口冲突

**现象：** `Port 6080 is already in use`

**解决：**
```bash
# 使用其他端口
./run-agent.sh 8080

# 或查找占用进程
lsof -i:6080
```

---

### 问题 6: 健康检查失败

**检查日志：**
```bash
docker logs <container_name>
```

**常见原因：**
- VNC Server 未启动 → 检查 `entrypoint.sh` 日志
- noVNC 未启动 → 检查 websockify 进程
- 端口未暴露 → 检查 `docker run -p` 参数

---

### 问题 7: Docker 构建速度慢

**优化方法：**

1. 使用国内镜像源（编辑 Dockerfile）：
```dockerfile
# Node.js 镜像
ENV NPM_CONFIG_REGISTRY=https://registry.npmmirror.com

# apt 镜像（可选）
RUN sed -i 's/ports.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
```

2. 使用构建缓存：
```bash
# 不清除缓存
docker build -t agent-box-image .

# 仅在代码变更时清除
docker build --no-cache -t agent-box-image .
```

---

### 调试命令

```bash
# 进入运行中的容器
docker exec -it <container_name> bash

# 查看容器进程
docker top <container_name>

# 查看资源使用
docker stats <container_name>

# 查看健康状态
docker inspect --format='{{.State.Health.Status}}' <container_name>
```

## 🔒 安全建议

### 生产环境注意事项

1. **移除 sudo 免密**
   ```dockerfile
   # 生产环境移除这一行：
   # echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
   ```

2. **限制网络访问**
   ```bash
   docker run --network none ...  # 完全隔离
   docker run --network bridge ...  # 部分隔离
   ```

3. **只读挂载**
   ```bash
   -v "$(pwd)":/workspace:ro  # 只读模式
   ```

4. **使用 secrets 管理 API Key**
   ```bash
   # 不要硬编码 ANTHROPIC_API_KEY
   # 使用 Docker secrets 或环境变量管理
   ```

## 🛠️ 高级用法

### 1. 自定义浏览器扩展

```bash
# 进入容器
docker exec -it <container_name> bash

# 下载扩展并使用 --load-extension 参数
google-chrome --load-extension=/path/to/extension
```

### 2. 安装额外工具

编辑 Dockerfile 添加：
```dockerfile
RUN apt-get install -y \
    ffmpeg \
    imagemagick \
    postgresql-client
```

### 3. 自定义启动脚本

编辑 `entrypoint.sh`，在最后添加：
```bash
# 启动自定义服务
echo "Starting custom service..."
/usr/local/bin/my-service &
```

### 4. 与 CI/CD 集成

```yaml
# GitHub Actions 示例
- name: Build Agent Sandbox
  run: docker build -t agent-box-image .

- name: Run Tests in Sandbox
  run: |
    docker run --rm agent-box-image \
      bash -c "cd /workspace && pytest"
```

## 📊 性能优化

### 镜像大小优化

当前镜像大小约 **1.2GB**，主要组成：
- Ubuntu 22.04: ~80MB
- Chromium: ~280MB
- Node.js: ~50MB
- 图形库依赖: ~200MB

优化建议：
1. 使用 `alpine` 基础镜像（需重写 Dockerfile）
2. 多阶段构建分离运行时和构建依赖
3. 清理 apt 缓存（已实现）

### 启动速度优化

- 首次启动：~5-8 秒
- 重启容器：~2-3 秒

优化方法：
- 使用 `--restart unless-stopped` 保持容器运行
- 预热：提前启动容器，需要时直接 `docker exec`

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📝 更新日志

### v2.0.0 (2026-01-07)

- ✨ 使用 Playwright Chromium 替代 snap 版本
- ✨ 升级 Node.js 到 v20（支持 Claude Code 2.0）
- ✨ 添加 Openbox 窗口管理器
- ✨ 修复 X server 锁文件重启问题
- ✨ 修复 Claude 配置路径（`~/.claude`）
- ✨ 添加健康检查机制
- 🐛 修复权限问题（entrypoint.sh）
- 📝 完善 README 文档

### v1.0.0 (Initial)

- 🎉 初始版本
- 支持 Docker 容器隔离
- 集成 VNC + noVNC
- 预装 Claude Code

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

- [Anthropic Claude](https://www.anthropic.com/) - AI Agent 平台
- [Playwright](https://playwright.dev/) - 浏览器自动化工具
- [noVNC](https://novnc.com/) - Web VNC 客户端
- Docker 社区

## 📞 联系方式

- 问题反馈：[GitHub Issues](https://github.com/your-username/agent-box/issues)
- 讨论交流：[GitHub Discussions](https://github.com/your-username/agent-box/discussions)

---

**⚠️ 免责声明**

本工具仅供学习和开发使用。在生产环境中使用前，请仔细评估安全风险。作者不对使用本工具造成的任何损失负责。
