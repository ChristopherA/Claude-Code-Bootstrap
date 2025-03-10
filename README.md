# Claude Code Bootstrap

> A toolkit for bootstrapping community-driven projects with Claude Code CLI

## Introduction

Managing open source projects with multiple contributors requires structured processes for requirements, development, and community engagement. This toolkit streamlines these processes by leveraging Claude Code CLI to assist with:

- **Parallel Development Streams** - Manage multiple work branches simultaneously
- **Requirements-Driven Development** - Ensure implementation aligns with defined requirements
- **Context Preservation** - Maintain continuity across development sessions
- **Standardized Documentation** - Create consistent, high-quality project documentation
- **Community-Friendly Processes** - Establish contributor-friendly workflows from day one

By establishing these structured processes early, your project can scale more effectively while maintaining quality and consistency.

## Overview

This folder contains templates and guidance for initializing new open source projects with structured workflows managed by Claude Code CLI. Rather than cloning this entire repository, selectively use these files to bootstrap your project's process framework.

## Purpose

The Claude Code Bootstrap toolkit provides:

1. **Structured Workflow Process** - Templates for managing parallel work streams
2. **Context Management** - Tools for maintaining Claude's understanding across sessions
3. **Requirements-Driven Development** - Separation of requirements from implementation tasks
4. **Community Best Practices** - Guidance for establishing community standards and documentation

## How to Use This Toolkit

This toolkit provides a structured approach to initialize and develop projects with Claude's assistance:

1. **Start with the Bootstrap Files**
   - Create a new directory for your project
   - Copy these core bootstrap files to your new directory:
     - README.md (you may customize this for your project)
     - CLAUDE.md
     - WORK_STREAM_TASKS.md
     - setup_local_git_inception.sh
     - create_github_remote.sh
     - install_bootstrap_templates.sh
     - (optional) feature-test-and-update-claude-code-bootstrap-CONTEXT.md

2. **Let Claude Guide the Initialization**
   - Start Claude in your new project directory:
     ```bash
     claude "I'm starting a new project using the Claude Code Bootstrap. Please review CLAUDE.md and then WORK_STREAM_TASKS.md first to understand the proper initialization sequence, then follow those instructions."
     ```
   - Claude will:
     - Check if your repository needs initialization
     - Run the bootstrap scripts in the proper sequence:
       1. Set up local Git with inception commit
       2. Create GitHub repository (public by default for branch protection)
       3. Install bootstrap templates and organize files
     - Set up the proper directory structure and GitHub repository
     - Move scripts to their appropriate locations
     - Guide you through each initialization step

3. **Ongoing Project Development with Claude**
   - Claude will facilitate your development by tracking tasks in WORK_STREAM_TASKS.md
   - As your project evolves, Claude will help maintain and update this file
   - Claude will assist in creating and managing feature branches for parallel work streams
   - Each work stream maintains its own context file to preserve knowledge across sessions
   - Claude will help adapt the process to your project's specific needs over time

4. **Continuing Development Sessions**
   - When resuming work after a break or when switching branches, restart Claude with:
     ```bash
     claude "load CLAUDE.md and follow its instructions, identify our current branch, and continue with the next task on that branch"
     ```
   - This ensures Claude has the proper context for your current work stream.
   - Claude will maintain continuity across development sessions.  (#TBRW)
   - As your Claude session context begins to approach full, tell Claude to "Close this session's context." (#TBRW)
   - Use `/compact` or `/exit` long sessions rather than starting over, and your context file will serve as a new starting point. (#TBRW)


## Contents

### Core Bootstrap Files (needed to start)

- **README.md** - This file explaining the bootstrap process
- **CLAUDE.md** - Core file for Claude Code CLI guidance and context
- **WORK_STREAM_TASKS.md** - Template for tracking development tasks across branches
- **setup_local_git_inception.sh** - Script to set up the initial repository with proper commit signing
- **create_github_remote.sh** - Script to create and configure GitHub repository
- **install_bootstrap_templates.sh** - Script to install templates and create directories

### Files Created During Bootstrap Process

- **requirements/** - Folder containing requirements documents (created by install_bootstrap_templates.sh)
- **templates/** - Folder containing template files for project documentation
- **context/** - Folder containing branch context files for Claude Code CLI
- **scripts/** - Folder where bootstrap scripts will be moved after initialization

These files will evolve and be updated by Claude.  (#TBRW)

### Optional Files

- **feature-test-and-update-claude-code-bootstrap-CONTEXT.md** - Context file for developing the bootstrap itself

## Requirements

1. **Git** (version 2.34.0+) - Required for SSH signing capabilities
2. **GitHub CLI** (`gh` version 2.0.0+) - Properly authenticated with `gh auth login`
3. **jq** - Command-line JSON processor required for GitHub API interactions
   ```bash
   # Install jq:
   # macOS:
   brew install jq
   
   # Ubuntu/Debian:
   sudo apt install jq
   
   # Fedora:
   sudo dnf install jq
   ```
4. **SSH Keys for Signing** - Required for secure commit signing
   ```bash
   # Check if you already have SSH keys configured for signing:
   git config --get user.signingkey
   
   # Check for Ed25519 keys (recommended):
   ls -la ~/.ssh/*ed25519*
   
   # If no keys exist, generate a new Ed25519 key:
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
5. **Git Configuration** - User identity and SSH signing setup
   ```bash
   # Configure your identity:
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   
   # The initialization script will configure SSH signing automatically
   ```
6. **GitHub Authentication** - Account with repository creation permissions
7. **Claude Code CLI** - For assisted development and process management

The initialization script will automatically verify and set up these requirements where possible. WORK_STREAM_TASKS.md will guide you through any additional configuration needed.

## Getting Started

To begin bootstrapping your project:

1. Read through this README.md completely
2. Ensure you meet the prerequisites or follow the setup guides
3. Start Claude to begin the bootstrap process. Claude will verify and initialize the repository for you:
   ```bash
   # Start Claude with the bootstrap command
   claude "I'm starting a new project using the Claude Code Bootstrap. Please review CLAUDE.md and then WORK_STREAM_TASKS.md first to understand the proper initialization sequence, then follow those instructions."
   ```
   
   Note: The bootstrap process will:
   - Verify repository status and initialize if needed
   - Set up proper Git configuration with SSH signing
   - Create a specialized inception commit establishing a root of trust
   - Configure GitHub with security best practices
   - Install all necessary bootstrap files and create required branches
   
4. During initialization, Claude will:
   - Review the repository structure and status
   - Verify if the repository needs initialization and run the bootstrap scripts if needed
   - Ask about existing files or code that should be incorporated
   - Guide you through configuring project-specific details
   - Help you update documentation to match your project's needs
   
5. Once initialized, Claude will guide you through the tasks in WORK_STREAM_TASKS.md
6. Claude will help you customize the templates to fit your project's specific needs

## Session Management for Claude Code CLI

When working on larger projects with Claude Code CLI, you'll need to manage your sessions effectively:

### Handling Context Limits

Claude has a context limit that can fill up during longer sessions. When this happens:

1. **Use the `/compact` command:** This condenses the conversation while preserving important context
   ```
   /compact
   ```

2. **Exit and restart when necessary:** For very long sessions or when switching tasks
   ```
   /exit
   ```

   Then restart Claude with the standard continuation command:
   ```bash
   claude "load CLAUDE.md and follow its instructions, identify our current branch, and continue with the next task on that branch"
   ```

### Best Practices

- **Special Features: Inception Commit**

This bootstrap kit creates a specialized "inception commit" that:

1. Establishes a SHA-1 root of trust for your repository
2. Designates your Ed25519 SSH key as the inception authority
3. Sets up the framework for authorizing additional signing keys
4. Creates the proper directory structure for verifiable integrity
5. Sets up initial "Inception Key Trust Model" for main branch, authorized by the Inception Key Holder (i.e. the party that created the Inception Commit). (#TBRW)

This follows the Open Integrity Project standards for creating a verifiable chain of cryptographic signatures throughout the repository's history.

- **Between Claude Sessions:**
  - Switch to the main branch: `git checkout main`
  - Pull updates from collaborators: `git pull origin main`
  - Fetch all remote branches: `git fetch --all`
  - Review new content: `git log --oneline -n 10`
  - Switch to your working branch before starting Claude: `git checkout feature/branch-name`

- Start new sessions for distinctly different tasks
- Use `/compact` when context is becoming large but you want to continue the same task
- Always use the standard restart command to ensure proper context loading
- If switching branches, exit and restart Claude to ensure proper branch context loading

### Benefits of Proper Session Management

- **Cost Efficiency:** Keeping context size reasonable reduces token usage and costs
- **Context Clarity:** Fresh sessions with focused context improve Claude's performance
- **Branch Awareness:** The restart command ensures Claude correctly identifies your current branch
- **Workflow Continuity:** Prevents losing track of tasks when sessions are interrupted
- **Collaboration:** Ensures you're working with the latest updates from team members
