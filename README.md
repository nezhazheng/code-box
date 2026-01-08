# Code Box

A universal Docker sandbox environment for AI-powered coding tools. Code Box provides a secure, isolated environment with multiple AI coding assistants pre-installed and ready to use.

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

### 1. Build the Docker Image

```bash
docker build -t code_box .
```

### 2. Run the Container

Use the convenient launcher script:

```bash
chmod +x run-codebox.sh
./run-codebox.sh
```

The container will be automatically named based on your current directory (e.g., `code_box_myproject`).

### 3. Access the Environment

**Terminal Access:**
- The script automatically attaches you to the container shell
- Or manually: `docker exec -it code_box_<project> /bin/bash`

**Browser Access (noVNC):**
- Open: http://localhost:6080
- Click "Connect" to access the desktop environment

**VNC Client:**
- Connect to: `localhost:5900`
- No password required

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

## Launcher Script Commands

```bash
# Start or attach to container
./run-codebox.sh

# Stop the container
./run-codebox.sh --stop

# Remove the container
./run-codebox.sh --remove

# View container logs
./run-codebox.sh --logs

# Show help
./run-codebox.sh --help
```

## Configuration

### Resource Limits

Edit `run-codebox.sh` to adjust:

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
├── run-codebox.sh       # Smart launcher script
├── .gitignore          # Git ignore patterns
├── README.md           # This file
└── LICENSE             # MIT License
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
