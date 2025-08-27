
#!/bin/bash

# Claude Code 专用启动脚本
# 只为Claude设置代理，不影响其他应用

export HTTPS_PROXY=http://127.0.0.1:18443
export HTTP_PROXY=$HTTPS_PROXY
export ANTHROPIC_BASE_URL=https://api.anthropic.com

# 启动Claude Code
exec /home/ubuntu/.claude/node_modules/@anthropic-ai/claude-code/cli.js "$@" 
