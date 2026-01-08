#!/bin/bash
# Smoke test script for code-box Docker image
# Verifies all vibe coding tools are installed and accessible

set -e

echo "=========================================="
echo "  Code Box Smoke Test"
echo "=========================================="

FAILED=0

check_command() {
    local cmd=$1
    local name=$2
    echo -n "Checking $name... "
    if $cmd > /dev/null 2>&1; then
        echo "OK"
    else
        echo "FAILED"
        FAILED=1
    fi
}

check_version() {
    local cmd=$1
    local name=$2
    echo -n "Checking $name... "
    if output=$($cmd 2>&1); then
        echo "OK ($output)"
    else
        echo "FAILED"
        FAILED=1
    fi
}

echo ""
echo "--- Vibe Coding Tools ---"

# Claude Code
check_version "claude --version" "Claude Code"

# OpenAI Codex
check_version "codex --version" "Codex"

# Gemini CLI
check_version "gemini --version" "Gemini CLI"

# OpenCode
check_version "opencode --version" "OpenCode"

# oh-my-opencode (uses 'omo' command)
check_version "omo --version" "oh-my-opencode"

echo ""
echo "--- System Tools ---"

# Node.js
check_version "node --version" "Node.js"

# npm
check_version "npm --version" "npm"

# Python
check_version "python3 --version" "Python"

# Git
check_version "git --version" "Git"

echo ""
echo "=========================================="
if [ $FAILED -eq 0 ]; then
    echo "  All checks passed!"
    exit 0
else
    echo "  Some checks failed!"
    exit 1
fi
