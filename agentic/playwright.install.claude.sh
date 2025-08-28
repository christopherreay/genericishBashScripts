#!/bin/bash

# Simple Playwright MCP setup for Claude Code
# Assumes you have Node.js and Claude Code already installed

set -euo pipefail

echo "🎭 Playwright MCP for Claude Code"

# Add Microsoft's official Playwright MCP server
echo "📦 Adding Playwright MCP server..."
claude mcp add playwright -s user -- npx -y @playwright/mcp

# Install browser binaries
echo "🌐 Installing Playwright browsers..."
npx playwright install

echo "✅ Done. Test with:"
echo "  claude"
echo "  > Navigate to example.com and take a screenshot"
