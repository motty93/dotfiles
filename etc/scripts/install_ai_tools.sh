#!/bin/bash

# AI系CLIツールのインストールスクリプト
# 前提: asdf経由でnodejsがインストール済み

set -eu

echo "=== install Claude Code ==="
# https://docs.anthropic.com/en/docs/claude-code/overview
curl -fsSL https://claude.ai/install.sh | sh

echo ""
echo "=== install Gemini CLI ==="
npm install -g @google/gemini-cli

echo ""
echo "=== install OpenAI Codex CLI ==="
npm install -g @openai/codex

echo ""
echo "=== install MCP servers ==="
npm install -g mcp-gemini-google-search

echo ""
echo "=== done ==="
echo "Claude Code: $(claude --version 2>/dev/null || echo 'restart shell')"
echo "Gemini CLI:  $(gemini --version 2>/dev/null || echo 'restart shell')"
echo "Codex CLI:   $(codex --version 2>/dev/null || echo 'restart shell')"
