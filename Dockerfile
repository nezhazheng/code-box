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

# Switch to developer user
USER developer
WORKDIR /home/developer

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Install GitHub Copilot CLI
RUN npm install -g @githubnext/github-copilot-cli

# Install Continue.dev
RUN npm install -g continue

# Install Aider
RUN pip3 install --user aider-chat

# Install Playwright and Chromium browser
RUN pip3 install --user playwright \
    && python3 -m playwright install chromium \
    && python3 -m playwright install-deps chromium

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
CMD ["/bin/bash"]
