# Code Box

The Ultimate Sandbox for Vibe Coding

- Free and fully open source!
- One-line installation, ready to use out of the box
- Container-level isolation for Coding Agents, with shared authentication where needed
- Built-in cc, oh-my-opencode, codex, and more
- 0-day tracking of the latest Vibe Coding tool versions
- Sandbox with browser support, accessible both remotely and locally

English | [简体中文](README.zh-CN.md)

## One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/nezhazheng/code-box/main/install.sh | bash
```

This will:
- Download the `code-box` command to your PATH
- Auto-configure PATH (supports bash, zsh, fish, and other common shells)
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

- **VNC Server**: Randomly assigned port (for VNC clients)
- **noVNC Web UI**: Randomly assigned port (browser-based access)
- **Display**: Virtual X11 display (:99) for GUI applications
- **Port Discovery**: Use `code-box --list` to see your assigned ports

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/nezhazheng/code-box/main/install.sh | bash
```

Then use from any project directory:

```bash
cd ~/myproject
code-box
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

### Port Assignment

Code Box uses automatic port allocation:

- Port range: 10000-60000 (randomly assigned)
- Each project gets persistent port assignments
- Port mappings stored in: `~/.code-box/ports.json`
- View ports: Run `code-box --list`

Code Box automatically assigns available ports when starting containers, avoiding port conflicts.

## Uninstall

### Complete Uninstallation

To completely uninstall Code Box, follow these steps:

```bash
# 1. Stop and remove all code_box containers
code-box --clean

# 2. Remove Docker image
docker rmi nezhazheng/code-box:latest

# 3. Remove configuration directory
rm -rf ~/.code-box

# 4. Remove code-box command (may require sudo)
sudo rm /usr/local/bin/code-box
# Or, if installed in a different location
which code-box | xargs rm
```

### Remove a Specific Project Container

To remove only a specific project's container:

```bash
# In the project directory
cd /path/to/your/project
code-box --remove
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

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing documentation for each tool
- Review container logs: `code-box --logs`

---

**Code Box** - The Ultimate Sandbox for Vibe Coding.
