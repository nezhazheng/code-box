# Code Box

A universal Docker sandbox environment for AI-powered coding tools. Code Box provides a secure, isolated environment with multiple AI coding assistants pre-installed and ready to use.

English | [简体中文](README.zh-CN.md)

## One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/nezhazheng/code-box/main/install.sh | bash
```

This will:
- Download the `code-box` command to your PATH
- Pull the latest Docker image
- Set up the configuration directory

After installation, you can use `code-box` from any directory:

```bash
cd /path/to/your/project
code-box              # Start container
code-box --list       # List all projects and ports
code-box --help       # Show help
```

## Features

### Installed Vibe Coding Tools

- **Claude Code** - Anthropic's official CLI for Claude AI
- **Codex** - OpenAI's powerful code generation AI (via OpenAI CLI)
- **Gemini CLI** - Google's Gemini AI for code assistance
- **oh-my-opencode** - OpenCode AI coding assistant
- **GitHub Copilot CLI** - GitHub's AI-powered command-line assistant
- **Playwright + Chromium** - Browser automation for testing and scraping

### System Capabilities

- **Base System**: Ubuntu 22.04 LTS
- **Languages**: Node.js 20, Python 3.10
- **Graphics**: Xvfb, Openbox window manager, VNC, noVNC web interface
- **Security**: Non-root user (developer) with sudo access
- **Resources**: Configurable CPU, memory, and shared memory limits

### Remote Access

- **VNC Server**: Port 5900 (for VNC clients)
- **noVNC Web UI**: Port 6080 (browser-based access)
- **Display**: Virtual X11 display (:99) for GUI applications

## Quick Start

### Option 1: One-Line Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/nezhazheng/code-box/main/install.sh | bash
```

Then use from any project directory:

```bash
cd ~/myproject
code-box
```

### Option 2: Manual Setup

```bash
# Clone the repository
git clone https://github.com/nezhazheng/code-box.git
cd code-box

# Copy command to your PATH
cp code-box /usr/local/bin/
chmod +x /usr/local/bin/code-box

# Pull the image
docker pull nezhazheng/code-box:latest
```

### Access the Environment

**Terminal Access:**
- The script automatically attaches you to the container shell
- Or manually: `docker exec -it code_box_<project> /bin/bash`

**Browser Access (noVNC):**
- Run `code-box --list` to see assigned ports
- Open: http://localhost:<novnc-port>
- Click "Connect" to access the desktop environment

**VNC Client:**
- Run `code-box --list` to see assigned ports
- Connect to: `localhost:<vnc-port>`
- No password required

### Port Management

Code Box automatically assigns random ports for each project and remembers them:

```bash
# List all projects and their ports
code-box --list

# Example output:
#   code_box_myproject
#     Path:   /home/user/myproject
#     VNC:    localhost:12345
#     noVNC:  http://localhost:23456
```

## Usage Examples

### Using Claude Code

```bash
# Inside the container
cd ~/workspace
claude "explain this codebase"
claude "refactor this function to be more efficient"
```

### Using GitHub Copilot CLI

```bash
# Get command suggestions
github-copilot-cli what-the-shell "find all python files modified in last week"

# Get git command help
github-copilot-cli git-assist "undo last commit but keep changes"
```

### Using Codex (OpenAI)

```bash
# Use OpenAI CLI for code generation
export OPENAI_API_KEY="your-api-key-here"

# Generate code
openai api completions.create \
  -m gpt-3.5-turbo-instruct \
  -p "Write a Python function to calculate fibonacci numbers"
```

### Using Gemini CLI (Google)

```bash
# Set up Gemini API key
export GOOGLE_API_KEY="your-api-key-here"

# Use Gemini for code assistance
python3 -c "
from google import generativeai as genai
genai.configure(api_key='your-api-key')
model = genai.GenerativeModel('gemini-pro')
response = model.generate_content('Write a React component for a todo list')
print(response.text)
"
```

### Using oh-my-opencode

```bash
# Start oh-my-opencode
cd ~/workspace/myproject
oh-my-opencode

# Follow the interactive prompts for AI-assisted coding
```

### Using Playwright

```bash
# Python example
python3 << 'EOF'
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    print(page.title())
    browser.close()
EOF
```

## Commands

```bash
# Start or attach to container (from any project directory)
code-box

# Stop the container
code-box --stop

# Remove the container
code-box --remove

# View container logs
code-box --logs

# List all projects and their ports
code-box --list

# Pull latest image
code-box --pull

# Clean up all stopped containers
code-box --clean

# Show help
code-box --help
```

## Configuration

### Config Directory

Code Box stores configuration in `~/.code-box/`:

```
~/.code-box/
└── ports.json    # Project-to-port mappings
```

### Resource Limits

Edit the `code-box` script or set environment variables:

```bash
MEMORY_LIMIT="4g"      # RAM limit
CPU_LIMIT="2"          # CPU cores
SHM_SIZE="2g"          # Shared memory (important for Chromium)
```

### Volume Mounts

By default, the script mounts:
- Current directory → `/home/developer/workspace`
- `~/.claude` → `/home/developer/.claude` (for Claude Code config)

Add more volumes in `run-codebox.sh`:

```bash
-v "/path/on/host:/path/in/container"
```

### Port Mappings

Default ports:
- VNC: 5900
- noVNC: 6080

Change in `run-codebox.sh` if needed:

```bash
VNC_PORT=5901
NOVNC_PORT=6081
```

## Directory Structure

```
code_box/
├── Dockerfile           # Multi-tool Docker image definition
├── entrypoint.sh        # Container startup script
├── code-box             # Global CLI command
├── install.sh           # One-line installer
├── package.json         # Vibe coding tool versions (for auto-update)
├── renovate.json        # Auto-update configuration
├── .github/workflows/   # CI/CD pipeline
├── README.md            # This file
└── LICENSE              # MIT License
```

## Troubleshooting

### Container Won't Start

```bash
# Check if container exists
docker ps -a | grep code_box

# Remove old container
./run-codebox.sh --remove

# Rebuild image
docker build -t code_box .
```

### VNC/noVNC Not Accessible

```bash
# Check if ports are in use
lsof -i :5900
lsof -i :6080

# View container logs
./run-codebox.sh --logs

# Check if X server is running
docker exec code_box_<project> ps aux | grep Xvfb
```

### Playwright/Chromium Issues

```bash
# Reinstall Chromium
python3 -m playwright install chromium
python3 -m playwright install-deps chromium

# Increase shared memory if needed
# Edit run-codebox.sh: SHM_SIZE="4g"
```

### Claude Code Authentication

```bash
# Your ~/.claude directory is mounted automatically
# Run claude login if needed
claude login
```

## Use Cases

1. **Multi-Tool AI Development**
   - Compare different AI coding assistants
   - Use the best tool for each task
   - Experiment with various AI workflows

2. **Safe Experimentation**
   - Test AI-generated code in isolation
   - Avoid polluting your main system
   - Easy cleanup and reset

3. **Browser Automation**
   - Run Playwright scripts with Chromium
   - Headless or headed (via VNC) testing
   - Web scraping and automation

4. **Team Collaboration**
   - Consistent development environment
   - Share AI tool configurations
   - Reproducible setups

5. **CI/CD Integration**
   - Automated code review with AI
   - AI-assisted testing
   - Code quality checks

## Requirements

- Docker Desktop or Docker Engine
- 4GB+ available RAM (configurable)
- 2+ CPU cores (configurable)
- ~5GB disk space for image

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Resources

- [Claude Code Documentation](https://github.com/anthropics/claude-code)
- [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli/)
- [Aider Documentation](https://aider.chat/)
- [Continue.dev Documentation](https://continue.dev/)
- [Playwright Documentation](https://playwright.dev/)

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing documentation for each tool
- Review container logs: `./run-codebox.sh --logs`

---

**Code Box** - Your universal sandbox for AI-powered coding.
