#!/bin/bash
# entrypoint.sh - Agent Sandbox 启动脚本
# 负责启动虚拟显示器、窗口管理器、VNC 服务

set -e

echo "=========================================="
echo "🛡️  Agent Sandbox Starting..."
echo "=========================================="

# --- 0. 清理旧的 X server 锁文件 ---
rm -f /tmp/.X0-lock /tmp/.X11-unix/X0 2>/dev/null || true

# --- 1. 启动虚拟显示器 (Xvfb) ---
echo "🖥️  Starting Virtual Display (Xvfb)..."
Xvfb :0 -screen 0 ${RESOLUTION}x24 &
XVFB_PID=$!

# 等待 Xvfb 启动完成
sleep 2
if ! kill -0 $XVFB_PID 2>/dev/null; then
    echo "❌ Failed to start Xvfb"
    exit 1
fi
echo "✅ Xvfb started (PID: $XVFB_PID)"

# --- 2. 启动窗口管理器 (Openbox) ---
echo "🪟 Starting Window Manager (Openbox)..."
openbox &
OPENBOX_PID=$!
sleep 1
echo "✅ Openbox started (PID: $OPENBOX_PID)"

# --- 3. 启动 VNC 服务器 ---
echo "📡 Starting VNC Server (x11vnc)..."
x11vnc -display :0 -forever -shared -bg -nopw -o /tmp/x11vnc.log 2>/dev/null
sleep 1

# 验证 VNC 是否启动
if nc -z localhost 5900; then
    echo "✅ VNC Server started on port 5900"
else
    echo "❌ Failed to start VNC Server"
    exit 1
fi

# --- 4. 启动 noVNC (Web 代理) ---
echo "🌐 Starting noVNC Web Interface..."
websockify --web /usr/share/novnc/ --wrap-mode=ignore 6080 localhost:5900 &
NOVNC_PID=$!
sleep 2

# 验证 noVNC 是否启动
if nc -z localhost 6080; then
    echo "✅ noVNC started on port 6080"
else
    echo "❌ Failed to start noVNC"
    exit 1
fi

# --- 5. 输出状态信息 ---
echo ""
echo "=========================================="
echo "✅ Sandbox Ready!"
echo "=========================================="
echo "📺 VNC Web Access: http://localhost:6080"
echo "🖥️  Resolution: ${RESOLUTION}"
echo "🌐 Browser: Google Chrome (google-chrome)"
echo "🤖 Agent CLI: claude (Claude Code)"
echo "=========================================="
echo ""

# --- 6. 保持容器运行 ---
# 使用 wait 代替 tail -f，更优雅地处理信号
wait $XVFB_PID
