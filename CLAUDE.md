# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Code Box is a Docker-based sandbox environment for AI coding tools (Claude Code, Codex, Gemini CLI, OpenCode, etc.). The project uses **automated dependency updates via Renovate** and **CI/CD via GitHub Actions** to keep vibe coding tools up-to-date.

## Auto-Update Architecture

This project maintains a "downstream distribution" model:

```
npm releases new tool version
    ↓
Renovate detects update (checks hourly)
    ↓
Auto-creates PR updating package.json
    ↓
Auto-merges PR (if CI passes)
    ↓
GitHub Actions builds Docker image
    ↓
Pushes to Docker Hub (nezhazheng/code-box:latest)
    ↓
Users get latest tools on next `docker pull`
```

### Key Files for Auto-Update System

- **`package.json`**: Single source of truth for tool versions. Renovate monitors only these 5 packages:
  - `@anthropic-ai/claude-code`
  - `@openai/codex`
  - `@google/gemini-cli`
  - `opencode-ai`
  - `oh-my-opencode`

- **`renovate.json`**: Configured to ONLY update npm dependencies in package.json. Dockerfile and GitHub Actions updates are explicitly disabled to avoid infrastructure drift.

- **`.github/workflows/docker-publish.yml`**: Triggers on changes to:
  - `package.json` (tool version updates)
  - `Dockerfile`
  - `entrypoint.sh`
  - `smoke-test.sh`
  - The workflow file itself

  Does NOT trigger on README.md, run-*.sh, or other files.

- **`Dockerfile`**: Uses `jq` to parse package.json and install tools dynamically:
  ```dockerfile
  COPY package.json /tmp/package.json
  RUN TOOLS=$(cat /tmp/package.json | jq -r '.dependencies | to_entries | map("\(.key)@\(.value)") | join(" ")') \
      && npm install -g $TOOLS
  ```

## Installation and Usage

### One-Line Install
```bash
curl -fsSL https://raw.githubusercontent.com/nezhazheng/code-box/main/install.sh | bash
```

### Usage
```bash
code-box              # Start container for current directory
code-box --list       # List all projects and their ports
code-box --stop       # Stop container
code-box --remove     # Remove container
code-box --pull       # Pull latest image
code-box --clean      # Clean up all stopped containers
```

### Port Management
- Ports are automatically assigned randomly (range: 10000-60000)
- Port mappings are stored in `~/.code-box/ports.json`
- Each project gets persistent port assignments

## Building and Testing

### Local Build
```bash
docker build -t nezhazheng/code-box:latest .
```

### Smoke Tests
The `smoke-test.sh` verifies all vibe coding tools are installed and executable. CI runs this automatically before pushing images.

Manually run inside container:
```bash
docker run --rm nezhazheng/code-box:latest bash -c "
  claude --version &&
  codex --version &&
  gemini --version &&
  opencode --version &&
  omo --version
"
```

## CI/CD Pipeline

### Workflow Stages
1. **build-and-test**: Builds image and runs smoke tests
2. **push**: Only runs on `main` branch push; pushes to Docker Hub with tags:
   - `latest`
   - `<git-sha>`
   - `YYYY.MM.DD`

### Required GitHub Secrets
- `DOCKER_USERNAME`: Docker Hub username
- `DOCKER_PASSWORD`: Docker Hub access token (NOT password)

### Troubleshooting Failed Builds

**Docker Hub push fails with 400 Bad Request:**
- Ensure repository exists on Docker Hub
- Solution: Add `provenance: false` and `sbom: false` to build-push-action (already configured)

**Renovate PRs not auto-merging:**
- Enable "Allow auto-merge" in repository settings
- Check that PR passed CI checks

## Important Constraints

### What Renovate Should Update
- ✅ npm packages in `package.json` (vibe coding tools only)

### What Renovate Should NOT Update
- ❌ Dockerfile base image (ubuntu:22.04)
- ❌ GitHub Actions versions (actions/checkout, docker/build-push-action, etc.)
- ❌ Python packages (openai, google-generativeai, playwright)

**Rationale**: Infrastructure stability. Python packages are user-facing utilities, not core vibe coding tools.

### What Triggers CI Builds
- ✅ Changes to package.json, Dockerfile, entrypoint.sh, smoke-test.sh, workflow file
- ❌ Changes to README.md, run-*.sh, CLAUDE.md, or other docs

## Container Architecture

### Entrypoint Flow
`entrypoint.sh` starts services in this order:
1. Xvfb (virtual display on :99)
2. Openbox (window manager)
3. x11vnc (VNC server on port 5900)
4. websockify/noVNC (web VNC on port 6080)
5. Keeps running with `tail -f /dev/null` or executes passed command

### Volume Mounts
- Current directory → `/home/developer/workspace` (user's project)
- `~/.claude` → `/home/developer/.claude` (Claude Code auth)

### User Context
- Container runs as non-root user `developer` (UID varies)
- Has passwordless sudo access
- Python packages installed to `~/.local/bin` (in PATH)

## When Making Changes

### Adding a New Vibe Coding Tool
1. Add to `package.json` dependencies with pinned version
2. Add to `renovate.json` packageRules.matchPackageNames array
3. Add version check to `smoke-test.sh`
4. Update README.md features list
5. Commit triggers CI build automatically

### Modifying Dockerfile
- Always preserve the `jq` parsing logic for package.json
- Keep `provenance: false` and `sbom: false` in workflow (prevents Docker Hub issues)
- Test locally before pushing

### Updating Infrastructure (GitHub Actions, base images)
- Do NOT rely on Renovate (it's disabled for these)
- Manually update and test thoroughly
- Infrastructure changes are intentionally manual to avoid breakage

## Key Design Decisions

1. **Single source of truth**: package.json contains exact versions; Dockerfile reads from it
2. **Automerge enabled**: Vibe coding tool updates merge automatically if tests pass
3. **Infrastructure locked**: Base images and CI tools don't auto-update to prevent cascade failures
4. **Docker Hub as distribution**: Users pull `nezhazheng/code-box:latest`, not local builds

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
├── README.md            # English documentation
├── README.zh-CN.md      # Chinese (Simplified) documentation
├── CLAUDE.md            # This file
└── LICENSE              # MIT License
```

## Troubleshooting

### Container Won't Start

```bash
# Check if container exists
docker ps -a | grep code_box

# Remove old container
code-box --remove

# Rebuild image
docker build -t nezhazheng/code-box:latest .
```

### VNC/noVNC Not Accessible

```bash
# Check if ports are in use
lsof -i :5900
lsof -i :6080

# View container logs
code-box --logs

# Check if X server is running
docker exec code_box_<project> ps aux | grep Xvfb
```

### Playwright/Chromium Issues

```bash
# Reinstall Chromium
python3 -m playwright install chromium
python3 -m playwright install-deps chromium

# Increase shared memory if needed
# Edit code-box script: SHM_SIZE="4g"
```

### Claude Code Authentication

```bash
# ~/.claude directory is mounted automatically
# Run claude login if needed
claude login
```
