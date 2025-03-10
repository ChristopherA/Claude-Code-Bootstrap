# Claude Code Bootstrap
> - _did-original-source_: `did:repo:4a603bb686e1aa84f6793b1a0d5a2e0aad195893/blob/main/README.md`
> - _github-original-source_: `https://github.com/ChristopherA/Claude-Code-Bootstrap/blob/main/README.md`
> - _purpose: Provide documentation and instructions for the Claude Code Bootstrap toolkit_
> - _copyright: ©2025 by @ChristopherA, licensed under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html)_
> - _status: ACTIVE_ 
> - _created: 2025-03-10 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>_
> - _last-updated: 2025-03-10 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>_
      
This document provides essential guidance for the Claude CLI agent when working with this project. It references detailed requirements documents for specific processes.

## Initial Startup Process

When Claude is first started:

1. **Check WORK_STREAM_TASKS.md first** - Review the "Initial Bootstrap Tasks" section at the top
2. **Follow the bootstrap checklist** - Complete each step in order
3. **DO NOT skip the repository verification step** - Never assume repository initialization
4. **Use the bootstrap scripts when needed** - Run the scripts in proper sequence to initialize the repository

Only after confirming bootstrap completion should you proceed to branch-specific tasks.

## Project Overview

This project uses a structured development approach with parallel work streams managed through branches. Each work stream follows a requirements-driven process where tasks are defined based on specific requirements documents.

## Initialization Process

When first starting with a new project using this bootstrap:

1. **Branch identification and source material import:**
   - First check the current branch with `git branch --show-current`
   - If on the `docs/import-existing-materials` branch, you're in source material import mode
   - For this branch, focus on the import process before any other tasks
   - Reference `context/docs-import-existing-materials-CONTEXT.md` for detailed guidance

2. **Source material import process:**
   - Ask the user if they have existing files, code, or resources to import
   - Direct them to upload materials to the `untracked/source-material` directory
   - Explicitly confirm all materials have been uploaded before proceeding
   - Document the status and quality of each file in `requirements/source_materials_inventory.md`
   - Create READMEs for each directory to document the files
   - Only after thorough review, organize files into the proper directories

3. **GitHub verification:**
   - Verify GitHub remote is properly configured
   - Ensure both main and feature branches have been pushed to GitHub
   - Check if PRs are properly configured

4. **Project customization:**
   - Help the user customize project-specific documentation (README.md, etc.)
   - Guide the user through branch-specific tasks in WORK_STREAM_TASKS.md
   - Suggest repository structure improvements based on the project's specific needs

## Core Files to Reference

Claude should always reference the following files to understand the project context:

1. `WORK_STREAM_TASKS.md` - The primary task tracking document for all branches
2. `requirements/*.md` - All requirement documents for complete process understanding
3. `context/[branch-name]-CONTEXT.md` - Branch-specific context files 
4. `templates/*` - Template files for project documentation (when implementing tasks)

Note: Branch context files in the `context/` directory may contain detailed information about the branch's development history, current status, and planned work. These files are essential for maintaining continuity across Claude sessions.

## Essential Git Workflow Principles

1. **Check repository state before making changes:**
   - Run `git status` to understand current branch and file state
   - Verify you're on the correct branch for the current task

2. **Handle files safely:**
   - Check if files/directories exist before creating them using `test -f` or `test -d`
   - Use `git ls-files <path>` to check if a file is tracked before removal
   - Use `git rm` for tracked files instead of `rm`

3. **Commit approval process (CRITICAL):**
   - ALWAYS request explicit human confirmation before executing any commit
   - Present the commit message for review before committing
   - Never commit automatically or without explicit approval
   - Wait for explicit confirmation before executing the commit command

4. **Commit process:**
   - Review specific commit message requirements in `requirements/commit_standards.md`
   - Always sign commits with SSH/GPG key and add DCO sign-off as required
   - Stage files individually, not in batches
   - Human author must personally review all changes before staging

## Branch Context Management

When starting work on a repository:

1. **First, identify the current branch:**
   ```bash
   git branch --show-current
   ```

2. **Then load the appropriate context file:**
   - For main branch: `context/main-CONTEXT.md` or `config/main-CONTEXT.md`
   - For feature branches: `context/[branch-name]-CONTEXT.md`
   - Convention: Branch context files use hyphenated names (e.g., `feature-name-CONTEXT.md`)

3. **If no context file exists for the current branch:**
   - Suggest creating one based on `config/branch_context_template.md`
   - Example: `cp config/branch_context_template.md context/[branch-name]-CONTEXT.md`

4. **Reference corresponding section in WORK_STREAM_TASKS.md:**
   - Find the branch's section (e.g., `## Branch: [branch-name]`)
   - Focus on uncompleted tasks for that branch
   - Recommend next actions based on task priorities

5. **Update WORK_STREAM_TASKS.md as tasks are completed:**
   - Mark completed tasks with [x] and add completion dates (YYYY-MM-DD)
   - Ensure task updates are committed properly

## Requirements Documents

The actual processes, standards, and workflows are defined in dedicated requirements files. Claude should load and follow these files based on the current task:

- `requirements/git_workflow.md` - Git process requirements
- `requirements/commit_standards.md` - Commit formatting and signing requirements
- `requirements/branch_management.md` - Branch strategy and process
- `requirements/github_issues.md` or `requirements/repository_issues.md` - Issue tracking requirements (as selected by user)
- `requirements/pr_process.md` - Pull request process requirements

## Guidelines for Claude When Working on Tasks

1. **Start with context:**
   - Load ALL requirements documents for complete understanding
   - Check branch context file if available
   - Review WORK_STREAM_TASKS.md for current task status

2. **Follow a methodical approach:**
   - First assess what files need to be modified and their current state
   - Create a plan before making any changes
   - Follow processes defined in the appropriate requirements docs

3. **When in doubt, ask for clarification:**
   - Reference specific requirements or documentation when asking questions
   - Provide options with pros and cons when multiple approaches exist

## Error Handling and Troubleshooting

If unexpected errors occur during any part of the process, follow these steps:

1. **For bootstrap script errors:**
   - IMMEDIATELY load the context `feature-test-and-update-claude-code-bootstrap-CONTEXT.md`
   - This file contains detailed history and development notes about the bootstrap process
   - Use its information to diagnose and suggest fixes for the bootstrap scripts
   - Consult the "Next Actions" and "Development History" sections for relevant insights

   **Common Bootstrap Script Issues and Fixes:**
   
   **create_github_remote.sh Issues:**
   - **Error pushing inception commit:** If you see error messages about "refspec" not matching, the script is having trouble pushing the inception commit. The recommended fix is to:
     1. Delete the GitHub repository with `gh repo delete <username>/<repo-name> --yes`
     2. Fix the create_github_remote.sh script to use the temp branch approach
     3. Re-run the script
   
   - **Branch protection API errors:** If you see HTTP 422 errors or messages about invalid JSON formats for branch protection, this indicates GitHub API compatibility issues. The solution is to:
     1. Accept that branch protection will need to be set up manually
     2. Follow the manual instructions provided by the script
     3. Proceed with the next script in the bootstrap sequence
   
   - **Repository already exists errors:** If the repo exists but something failed in previous steps:
     1. Delete the GitHub repository with `gh repo delete <username>/<repo-name> --yes`
     2. Re-run the script from the beginning

2. **For work stream task process errors:**
   - First try to resolve using the appropriate requirements document
   - If the requirements don't address the issue, load `feature-test-and-update-claude-code-bootstrap-CONTEXT.md`
   - The context file may contain information about recent improvements or known issues

3. **For template issues:**
   - Check if there's a more recent version in `untracked/updated_bootstrap_files/templates/`
   - Reference `feature-test-and-update-claude-code-bootstrap-CONTEXT.md` for template development history

4. **After resolving issues:**
   - Suggest updates to the bootstrap files or templates to prevent similar errors
   - Document the error and solution in the context file's "Development History" section
   - Update this error handling section with any new information about common issues

5. **When to bypass a failed script:**
   - If script errors persist after multiple attempts at fixing, document the issues and proceed with the next script
   - Note that some failures may be non-critical (like branch protection API failures)
   - Critical failures (like inability to push to GitHub) must be resolved before proceeding

IMPORTANT: The `feature-test-and-update-claude-code-bootstrap-CONTEXT.md` file should be your primary reference for troubleshooting bootstrap-related issues. It contains the complete development history and documentation for the bootstrap process. Always check the "Development History" section first, as it likely contains information about recent fixes for common issues.
