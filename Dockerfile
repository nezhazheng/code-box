# Dockerfile - Agent Sandbox with Chrome
# Secure Agentic Sandbox (SAS) v2.0 - Chrome Edition

FROM ubuntu:22.04

# --- 1. 基础工具与依赖 ---
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    # 基础工具
    curl wget git unzip vim nano \
    # Python 环境
    python3 python3-pip python3-venv \
    # Node.js 前置依赖 (实际 Node.js 在后面单独安装)
    ca-certificates gnupg \
    # 图形界面支持 (X11 + VNC)
    xvfb x11vnc \
    # 轻量级窗口管理器
    openbox \
    # 终端
    xfce4-terminal \
    # noVNC (Web VNC 客户端)
    novnc websockify \
    # [关键] 中文字体 (Chrome 必备，防止乱码)
    fonts-noto-cjk fonts-wqy-zenhei \
    # 音频支持 (防止 Chrome 报错)
    libasound2 \
    # 健康检查工具
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# --- 2. 安装 Node.js 20 (Claude Code 需要 >= 18) ---
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# --- 3. 安装 Chromium 浏览器 (通过 Playwright) ---
# Ubuntu 22.04 的 chromium-browser 包是 snap 过渡包，在 Docker 中不可用
# 使用 Playwright 安装真正可用的 Chromium 到共享位置
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/playwright
RUN npm install -g playwright \
    && npx playwright install chromium \
    && npx playwright install-deps chromium \
    && chmod -R 755 /opt/playwright

# 创建浏览器启动脚本 (使用固定路径)
RUN CHROME_PATH=$(find /opt/playwright -name "chrome" -type f | head -1) \
    && echo "#!/bin/bash" > /usr/local/bin/google-chrome \
    && echo "exec $CHROME_PATH --no-sandbox --disable-dev-shm-usage \"\$@\"" >> /usr/local/bin/google-chrome \
    && chmod 755 /usr/local/bin/google-chrome

# --- 4. 修复 noVNC 路径问题 ---
# 创建软链接确保 index.html 可访问
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# --- 5. 安装 Agent 工具 (Claude Code) ---
RUN npm install -g @anthropic-ai/claude-code

# --- 6. 安全配置：非 Root 用户 ---
RUN useradd -m -s /bin/bash developer \
    && echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && mkdir -p /home/developer/.config /home/developer/.claude \
    && chown -R developer:developer /home/developer

# --- 7. 启动脚本配置 ---
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

# --- 8. 工作目录与用户 ---
RUN mkdir -p /workspace && chown developer:developer /workspace
WORKDIR /workspace
USER developer

# --- 9. 环境变量 ---
ENV DISPLAY=:0
ENV RESOLUTION=1280x800
# Chromium 在 Docker 中的必要参数
ENV CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage"
ENV CHROME_OPTS="--no-sandbox --disable-dev-shm-usage"

# --- 10. 暴露端口 ---
# 6080: noVNC Web 界面
# 5900: VNC 原生端口
EXPOSE 6080 5900

# --- 11. 健康检查 ---
# 检查 VNC 和 noVNC 服务是否正常
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD nc -z localhost 5900 && nc -z localhost 6080 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
