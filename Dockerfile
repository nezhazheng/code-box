FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    sudo \
    ca-certificates \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    python3-venv \
    # Graphics and VNC dependencies
    xvfb \
    x11vnc \
    openbox \
    novnc \
    websockify \
    xterm \
    # Additional utilities
    build-essential \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash -G sudo developer \
    && echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# === Install Vibe Coding Tools (as root) ===

# 1. Claude Code (Anthropic)
RUN npm install -g @anthropic-ai/claude-code

# 2. GitHub Copilot CLI (GitHub)
RUN npm install -g @githubnext/github-copilot-cli

# 5. oh-my-opencode (OpenCode)
# Install via npm if available, otherwise via git
RUN npm install -g oh-my-opencode || \
    (git clone https://github.com/oh-my-opencode/oh-my-opencode.git /tmp/oh-my-opencode && \
     cd /tmp/oh-my-opencode && \
     npm install -g . && \
     rm -rf /tmp/oh-my-opencode) || \
    echo "oh-my-opencode installation failed, skipping..."

# Install Playwright system dependencies (as root)
RUN pip3 install playwright && python3 -m playwright install-deps chromium

# Switch to developer user
USER developer
WORKDIR /home/developer

# 3. Codex CLI (OpenAI)
# Note: Install OpenAI CLI for Codex access
RUN pip3 install --user openai

# 4. Gemini CLI (Google)
RUN pip3 install --user google-generativeai

# Install Playwright and Chromium browser for user
RUN pip3 install --user playwright \
    && python3 -m playwright install chromium

# Add Python user bin to PATH
ENV PATH="/home/developer/.local/bin:${PATH}"

# Set up workspace directory
RUN mkdir -p /home/developer/workspace

# Set up VNC and X11 environment
ENV DISPLAY=:99
ENV VNC_PORT=5900
ENV NOVNC_PORT=6080

# Copy entrypoint script
COPY --chown=developer:developer entrypoint.sh /home/developer/entrypoint.sh
RUN chmod +x /home/developer/entrypoint.sh

# Expose VNC and noVNC ports
EXPOSE 5900 6080

# Set entrypoint
ENTRYPOINT ["/home/developer/entrypoint.sh"]
