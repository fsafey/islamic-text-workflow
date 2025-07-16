#!/bin/bash
# Minimal Islamic Text Workflow Dev Container Setup Script

set -e

echo "🕌 Minimal Islamic Text Workflow Setup..."

# Set up project directory
cd /workspace

# Basic git configuration
git config --global --add safe.directory /workspace
git config --global user.email "developer@islamic-text-workflow.local" || true
git config --global user.name "Islamic Text Workflow Developer" || true

# Create essential aliases
cat >> ~/.bashrc << 'EOF'

# Essential aliases
alias ws='cd /workspace'
alias pkg='install-packages.sh'

# On-demand installation helpers
alias install-claude='install-packages.sh claude'
alias install-dev='install-packages.sh dev-tools'
alias install-all='install-packages.sh all'

EOF

# Quick start message
echo ""
echo "🎉 Minimal Dev Container Ready!"
echo ""
echo "📦 Install packages as needed:"
echo "   pkg claude           - Install Claude Code"
echo "   pkg dev-tools        - Install vim, nano, etc."
echo "   pkg python-dev       - Install pytest, jupyter, etc."
echo "   pkg graphiti         - Install Graphiti dependencies"
echo "   pkg all              - Install everything"
echo ""
echo "🚀 Fast startup, install only what you need!"
echo ""