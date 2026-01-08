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
    jq \
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
# Copy package.json and install tools with pinned versions
COPY package.json /tmp/package.json
RUN TOOLS=$(cat /tmp/package.json | jq -r '.dependencies | to_entries | map("\(.key)@\(.value)") | join(" ")') \
    && echo "Installing: $TOOLS" \
    && npm install -g $TOOLS \
    && rm /tmp/package.json

# Install Playwright system dependencies (as root)
RUN pip3 install playwright && python3 -m playwright install-deps chromium

# Switch to developer user
USER developer
WORKDIR /home/developer

# Install Python tools for user
RUN pip3 install --user openai google-generativeai

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
