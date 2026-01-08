#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Clear any existing X server lock files
sudo rm -f /tmp/.X99-lock /tmp/.X11-unix/X99

# Start Xvfb (Virtual Framebuffer)
echo -e "${BLUE}Starting Xvfb on display ${DISPLAY}...${NC}"
Xvfb ${DISPLAY} -screen 0 1920x1080x24 &
XVFB_PID=$!
sleep 2

# Start Openbox window manager
echo -e "${BLUE}Starting Openbox window manager...${NC}"
openbox &
OPENBOX_PID=$!
sleep 1

# Start x11vnc server
echo -e "${BLUE}Starting VNC server on port ${VNC_PORT}...${NC}"
x11vnc -display ${DISPLAY} -forever -shared -rfbport ${VNC_PORT} -nopw &
VNC_PID=$!
sleep 2

# Start noVNC web server
echo -e "${BLUE}Starting noVNC web server on port ${NOVNC_PORT}...${NC}"
websockify --web=/usr/share/novnc ${NOVNC_PORT} localhost:${VNC_PORT} &
NOVNC_PID=$!
sleep 2

# Display status message
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Code Box - AI Coding Sandbox${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Installed Vibe Coding Tools:${NC}"
echo "  - Claude Code (Anthropic)"
echo "  - Codex (OpenAI)"
echo "  - Gemini CLI (Google)"
echo "  - oh-my-opencode (OpenCode)"
echo "  - GitHub Copilot CLI"
echo "  - Playwright + Chromium"
echo ""
echo -e "${YELLOW}Display & Remote Access:${NC}"
echo "  - Display: ${DISPLAY}"
echo "  - VNC Port: ${VNC_PORT}"
echo "  - noVNC Web UI: http://localhost:${NOVNC_PORT}"
echo ""
echo -e "${YELLOW}Workspace:${NC}"
echo "  - /home/developer/workspace"
echo ""
echo -e "${GREEN}========================================${NC}"
echo ""

# Cleanup function
cleanup() {
    echo -e "${BLUE}Shutting down services...${NC}"
    kill $NOVNC_PID $VNC_PID $OPENBOX_PID $XVFB_PID 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT

# Execute the main command
exec "$@"
