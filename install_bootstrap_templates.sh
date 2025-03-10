#!/usr/bin/env zsh
########################################################################
## Script:        install_bootstrap_templates.sh
## Version:       0.1.0 (2025-03-07)
## Origin:        https://github.com/ChristopherA/Claude-Code-Bootstrap/blob/main/scripts/install_bootstrap_templates.sh
## Description:   Installs bootstrap templates and creates initial branch structure
##                for a Claude Code CLI project
## License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
## Copyright:     (c) 2025 @ChristopherA
## Attribution:   Authored by @ChristopherA
## Usage:         install_bootstrap_templates.sh <repo-name>
## Examples:      install_bootstrap_templates.sh my-project
## Dependencies:  Requires git command
## Requirements:  Must be run from the root of a git repository
########################################################################

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options
setopt errexit nounset pipefail localoptions warncreateglobal

# Script-scoped exit status codes
typeset -r Exit_Status_Success=0            # Successful execution
typeset -r Exit_Status_General=1            # General error (unspecified)
typeset -r Exit_Status_Usage=2              # Invalid usage or arguments
typeset -r Exit_Status_IO=3                 # Input/output error
typeset -r Exit_Status_Git_Failure=5        # Git repository related error
typeset -r Exit_Status_Config=6             # Configuration error
typeset -r Exit_Status_Dependency=127       # Missing executable dependency

# Script-scoped color variables
typeset Term_Black=$(tput setaf 0)          # Base black text
typeset Term_Red=$(tput setaf 1)            # Base red text
typeset Term_Green=$(tput setaf 2)          # Base green text
typeset Term_Yellow=$(tput setaf 3)         # Base yellow text
typeset Term_Blue=$(tput setaf 4)           # Base blue text
typeset Term_Magenta=$(tput setaf 5)        # Base magenta text
typeset Term_Cyan=$(tput setaf 6)           # Base cyan text
typeset Term_White=$(tput setaf 7)          # Base white text
typeset Term_Reset=$(tput sgr0)             # Reset to terminal default

#----------------------------------------------------------------------#
# Function: print_Message
#----------------------------------------------------------------------#
# Description:
#   Prints a formatted colored message to stdout
# Parameters:
#   $1 - Color terminal code
#   $2 - Message to print
# Returns:
#   None
#----------------------------------------------------------------------#
function print_Message() {
  typeset ColorCode="$1"
  typeset MessageText="$2"
  
  print -- "${ColorCode}${MessageText}${Term_Reset}"
}

#----------------------------------------------------------------------#
# Function: command_Exists
#----------------------------------------------------------------------#
# Description:
#   Checks if a command exists in the system
# Parameters:
#   $1 - Command name to check
# Returns:
#   Exit_Status_Success (0) if command exists
#   Exit_Status_Dependency (127) if command does not exist
#----------------------------------------------------------------------#
function command_Exists() {
  typeset CommandName="$1"
  command -v "$CommandName" >/dev/null 2>&1
}

#----------------------------------------------------------------------#
# Function: validate_Prerequisites
#----------------------------------------------------------------------#
# Description:
#   Validates that git is installed and repository is properly set up
# Parameters:
#   None
# Returns:
#   Exit_Status_Success on success
#   Various error codes on failure
# Dependencies:
#   Requires git command
#----------------------------------------------------------------------#
function validate_Prerequisites() {
  print_Message "$Term_Blue" "Validating prerequisites..."

  # Check for git
  if ! command_Exists git; then
    print_Message "$Term_Red" "Error: git is not installed. Please install git and try again."
    return $Exit_Status_Dependency
  fi
  
  # Verify we're in a git repository
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_Message "$Term_Red" "Error: Not a git repository. Run setup_local_git_inception.sh first."
    return $Exit_Status_Git_Failure
  fi
  
  # Check if we have a local 'main' branch
  if ! git rev-parse --verify main > /dev/null 2>&1; then
    print_Message "$Term_Red" "Error: No 'main' branch found. Repository initialization may be incomplete."
    return $Exit_Status_Git_Failure
  fi

  print_Message "$Term_Green" "All prerequisites validated successfully."
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: copy_Template_Files
#----------------------------------------------------------------------#
# Description:
#   Copies template files to the repository
# Parameters:
#   $1 - Repository directory
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_IO on failure
# Dependencies:
#   Requires template files in the bootstrap directory
#----------------------------------------------------------------------#
function copy_Template_Files() {
  typeset RepoDir="$1"
  typeset TemplateDir="$(dirname "$0")/.."
  
  print_Message "$Term_Blue" "Copying template files to repository..."
  
  # Create core directory structure
  mkdir -p "$RepoDir/requirements"
  mkdir -p "$RepoDir/templates"
  mkdir -p "$RepoDir/context"
  mkdir -p "$RepoDir/src/tests"
  # Create untracked directory for source materials
  mkdir -p "$RepoDir/untracked/source-material"
  
  # Remove bootstrap scripts from the root since they've been backed up to untracked/original_bootstrap_files
  if [[ -f "$RepoDir/setup_local_git_inception.sh" ]]; then
    rm "$RepoDir/setup_local_git_inception.sh"
    print_Message "$Term_Green" "Removed setup_local_git_inception.sh from root directory"
  fi
  
  if [[ -f "$RepoDir/create_github_remote.sh" ]]; then
    rm "$RepoDir/create_github_remote.sh"
    print_Message "$Term_Green" "Removed create_github_remote.sh from root directory"
  fi
  
  if [[ -f "$RepoDir/install_bootstrap_templates.sh" ]]; then
    rm "$RepoDir/install_bootstrap_templates.sh"
    print_Message "$Term_Green" "Removed install_bootstrap_templates.sh from root directory"
  fi
  
  # Move context files to context directory if they exist at the root
  if [[ -f "$RepoDir/feature-test-and-update-claude-code-bootstrap-CONTEXT.md" ]]; then
    mv "$RepoDir/feature-test-and-update-claude-code-bootstrap-CONTEXT.md" "$RepoDir/context/"
    chmod 644 "$RepoDir/context/feature-test-and-update-claude-code-bootstrap-CONTEXT.md"
    print_Message "$Term_Green" "Moved feature-test-and-update-claude-code-bootstrap-CONTEXT.md to context directory"
  fi
  
  # Copy CLAUDE.md if it doesn't exist
  if [[ ! -f "$RepoDir/CLAUDE.md" ]]; then
    cp "$TemplateDir/CLAUDE.md" "$RepoDir/"
    chmod 644 "$RepoDir/CLAUDE.md"
    print_Message "$Term_Green" "Created CLAUDE.md"
  else
    print_Message "$Term_Yellow" "CLAUDE.md already exists, skipping"
  fi
  
  # Copy WORK_STREAM_TASKS.md if it doesn't exist
  if [[ ! -f "$RepoDir/WORK_STREAM_TASKS.md" ]]; then
    cp "$TemplateDir/WORK_STREAM_TASKS.md" "$RepoDir/"
    chmod 644 "$RepoDir/WORK_STREAM_TASKS.md"
    print_Message "$Term_Green" "Created WORK_STREAM_TASKS.md"
  else
    print_Message "$Term_Yellow" "WORK_STREAM_TASKS.md already exists, skipping"
  fi
  
  # Create requirements files using heredocs
  # Create branch_management.md if it doesn't exist
  if [[ ! -f "$RepoDir/requirements/branch_management.md" ]]; then
    cat > "$RepoDir/requirements/branch_management.md" << 'EOF'
# Branch Management Requirements

This document defines the requirements for branch management in this project.

## Branch Naming

- Branch names should follow the pattern: `<type>/<descriptive-name>`
- Types include: feature, bugfix, docs, test, refactor, etc.
- Use kebab-case for descriptive names (e.g., feature/add-user-authentication)
- Keep branch names concise but descriptive

## Branch Structure

- `main` - Primary production branch
- Feature branches - Created from main for development
- All substantive changes must be done in feature branches

## Branch Creation

1. Create branches from the latest main: `git checkout -b <branch-name> main`
2. Push branch to remote immediately: `git push -u origin <branch-name>`
3. Create a branch context file in context/ directory

## Branch Lifetime

- Branches should be short-lived when possible
- Complete one focused task per branch
- Clean up branches after merging

## Branch Protection

- Main branch is protected and requires PR review
- Direct pushes to main are prohibited
- Commits must be signed to ensure integrity
- Different protection strategies for personal vs organization repositories:
  - **Personal Repositories:**
    - Required signatures via SSH/GPG
    - Branch protection with admin bypass capability
    - Required PR reviews before merging
    - Status checks required before merging
  - **Organization Repositories:**
    - Required signatures via SSH/GPG
    - Strict branch protection with no admin bypass
    - Multiple required PR reviews before merging
    - Required status checks must pass
    - Code owner approvals required

## Branch Protection Implementation

- Use GitHub API for programmatic protection configuration
- Configure both the basic branch protection rules and required signatures
- For personal repositories, set `enforce_admins=false` to allow admin bypass
- For organization repositories, set `enforce_admins=true` for stricter protection
- Use the `--admin` flag with `gh pr merge` when needed for admin operations

## Branch Context Files

- Each active branch must have a context file: `context/<branch-name>-CONTEXT.md`
- Context files provide Claude with branch-specific information
- Update context files regularly to reflect current status
- Follow the Context Management Protocol when switching branches
- Ensure proper context closure before completing work on a branch
EOF
    chmod 644 "$RepoDir/requirements/branch_management.md"
    print_Message "$Term_Green" "Created branch_management.md"
  else
    print_Message "$Term_Yellow" "branch_management.md already exists, skipping"
  fi

  # Create git_workflow.md if it doesn't exist
  if [[ ! -f "$RepoDir/requirements/git_workflow.md" ]]; then
    cat > "$RepoDir/requirements/git_workflow.md" << 'EOF'
# Git Workflow Requirements

This document defines the Git workflow requirements for this project.

## Repository Setup

- Use SSH keys for authentication
- Configure commit signing with SSH
- Set up proper Git identity

## Commit Process

- Validate changes before commit
- Sign all commits with SSH key
- Use proper commit message format
- Include DCO sign-off in all commits
- **ALWAYS request explicit human confirmation before executing any commit**
- Present the commit message for review before committing
- Never commit automatically or without explicit approval
- Wait for explicit confirmation before executing the commit command

## Testing and Verification

- Verify all changes work before committing
- Run appropriate tests for the type of change
- Follow this test-driven process for all updates:
  1. Identify and thoroughly understand the issue
  2. Formulate a clear approach with options/alternatives 
  3. Implement the solution
  4. Test solution thoroughly in isolation
  5. Validate the fix addresses the targeted issue
  6. Clean up unnecessary code and debugging artifacts
  7. Review for code smells or redundancies 
  8. Document verification tests performed
- For partial fixes, note progress but keep task marked as incomplete
- Add "TESTING:" details with each fix to document validation

## Branch Workflow

- Create feature branches from main
- Keep branches focused on single concerns
- Rebase branch on main before PR
- Clean up branches after merge

## Merge Process

- Create proper PR with description
- Ensure all CI checks pass
- Get required code reviews
- Use proper merge commit message
- Delete branch after merge
- Run post-merge verification to ensure changes work in main

## Conflict Resolution

- Always resolve conflicts at branch level before PR
- Coordinate with other contributors on shared code
- Document complex resolution decisions

## Versioning

- Use semantic versioning
- Tag releases properly
- Document all changes in CHANGELOG.md

## Error Handling

- When encountering errors, document the specific error messages
- Create reproducible test cases for issues
- When fixing errors:
  - Document the root cause
  - Explain the solution approach
  - Provide verification steps
  - Add test cases to prevent regression
- For script errors, include full error output and shell trace information
EOF
    chmod 644 "$RepoDir/requirements/git_workflow.md"
    print_Message "$Term_Green" "Created git_workflow.md"
  else
    print_Message "$Term_Yellow" "git_workflow.md already exists, skipping"
  fi

  # Create pr_process.md if it doesn't exist
  if [[ ! -f "$RepoDir/requirements/pr_process.md" ]]; then
    cat > "$RepoDir/requirements/pr_process.md" << 'EOF'
# Pull Request Process Requirements

This document defines the requirements for creating and reviewing pull requests.

## PR Creation

- Create branch and implement changes
- Test changes locally
- Push branch to GitHub
- Create PR with proper description
- Link PR to relevant issues

## PR Template

- Use PR template for consistency
- Include summary of changes
- List related issues
- Document test process
- Note any special considerations

## PR Review Process

- Assign appropriate reviewers
- Address all reviewer comments
- Make requested changes
- Resolve conversations
- Get final approval

## Merge Requirements

- All CI checks must pass
- Required reviewers must approve
- Conflicts must be resolved
- PR must be up-to-date with main
- All conversations must be resolved

## Post-Merge Process

- Delete branch after merge
- Update related issues
- Notify stakeholders if needed
- Verify changes in main branch
EOF
    chmod 644 "$RepoDir/requirements/pr_process.md"
    print_Message "$Term_Green" "Created pr_process.md"
  else
    print_Message "$Term_Yellow" "pr_process.md already exists, skipping"
  fi

  # Create work_stream_management.md if it doesn't exist
  if [[ ! -f "$RepoDir/requirements/work_stream_management.md" ]]; then
    cat > "$RepoDir/requirements/work_stream_management.md" << 'EOF'
# Work Stream Management Requirements

This document defines how work streams are managed across branches.

## Work Stream Definition

- A work stream is a series of related tasks
- Each work stream has a dedicated branch
- Work streams have clear requirements and deliverables

## Task Tracking

- WORK_STREAM_TASKS.md is the central task document
- Tasks are organized by branch
- Each task has a clear owner and status
- Tasks follow a consistent format

## Status Tracking

- Use checkboxes to indicate completion: [ ] vs [x]
- Include completion dates for finished items
- Use consistent priority labels
- Mark critical path items

## Branch Context

- Each work stream has a context file
- Context files capture current status
- Context files provide guidance for Claude
- Update context when switching branches
- Properly close context when completing work

## Context Management Protocol

The following protocol should be followed to maintain context continuity across Claude sessions:

### Closing a Context Session

When ending a work session or switching branches, properly "close" context by:

1. **Save Current State:**
   - Commit important files to Git if appropriate
   - Document current state in relevant context files
   - Ensure any temporary files are properly backed up

2. **Capture Progress and Learnings:**
   - Update task lists with completed items (mark with [x] and add completion date)
   - Document any bugs encountered and their solutions
   - Note partial progress on in-progress tasks
   - Record key decisions made during the session

3. **Update Planning Documents:**
   - Revise requirements files if new requirements were discovered
   - Update task lists with any new tasks identified
   - Adjust priorities based on session learnings
   - Add clarifications to ambiguous requirements

4. **Improve Documentation:**
   - Update context files with new information
   - Enhance error handling sections with new scenarios
   - Add useful code snippets or commands discovered

5. **Record Technical Details:**
   - Document exact commands that worked (and those that failed)
   - Note environment-specific issues
   - Record version information for relevant tools

6. **Update Development History:**
   - Add a new entry in the Development History section
   - Focus on substantive achievements, not minor details
   - Include date and authorship information
   - Summarize key changes and their implications
   - Note any major problems solved and their solutions
   - Document specific testing results with evidence

7. **Create Context Closure Section by EDITING THE ACTUAL CONTEXT FILE:**
   - IMPORTANT: You MUST use the Edit tool to update the context file itself, not just report in chat
   - Add or update the Context Closure section with current date
   - Include a detailed Completed Work Summary with all achievements
   - Document specific Testing Results with evidence
   - Add detailed Next Steps for Future Sessions
   - Update the context file's last-updated date in the metadata
   - Use actual file editing tools to make these changes to the file

8. **Prepare Restart Instructions:**
   - Create clear instructions for resuming work
   - Document the exact command to restart Claude CLI
   - Note files that should be loaded first
   - Include reminders about the current branch and state

### Session Management

- Use standardized restart command for Claude:
  ```
  claude "load CLAUDE.md and follow its instructions, identify our current branch, and continue with the next task on that branch"
  ```
- Between sessions, perform these Git operations:
  - Switch to main and pull updates: `git checkout main && git pull`
  - Fetch all remote branches: `git fetch --all`
  - Switch back to working branch before restarting Claude: `git checkout <branch-name>`
- When to use `/compact` vs `/exit`:
  - Use `/compact` when conversation is getting long but you need to continue
  - Use `/exit` when completing a work session entirely

## Work Stream Coordination

- Coordinate dependencies between branches
- Manage branch merging sequence
- Use cherry-picking for selective updates
- Keep main branch authoritative
EOF
    chmod 644 "$RepoDir/requirements/work_stream_management.md"
    print_Message "$Term_Green" "Created work_stream_management.md"
  else
    print_Message "$Term_Yellow" "work_stream_management.md already exists, skipping"
  fi
  
  print_Message "$Term_Green" "Created requirements files"
  
  # Copy context files
  # First create a main branch context file adapted for the new repository
  if [[ ! -f "$RepoDir/context/main-CONTEXT.md" ]]; then
    cat > "$RepoDir/context/main-CONTEXT.md" << EOF
# main Branch Context

> _created: $(date +"%Y-%m-%d") by $(git config --get user.name)_  
> _status: ACTIVE_  
> _purpose: Provide context for Claude CLI sessions working on the main branch_  

## Core Branch Documents

**Primary focus documents:** _(Claude should read these first)_
- `WORK_STREAM_TASKS.md` - Master task tracking document for all branches
- `context/main-CONTEXT.md` - This context file
- `README.md` - Project overview and getting started guide

**Reference documents:** _(Read as needed for specific tasks)_
- `requirements/branch_management.md` - Branch strategy requirements
- `requirements/git_workflow.md` - Git process requirements
- `requirements/work_stream_management.md` - Work stream process requirements
- `requirements/pr_process.md` - PR process requirements

## Branch Overview

The \`main\` branch is the primary branch for this project. It contains the stable, production-ready code and documentation that has passed all necessary reviews and tests.

## Current Status

- **Project initialization:** ✓ Project has been initialized with core documents
- **Documentation:** 🔄 Core documentation is being established
- **Development infrastructure:** ✓ Basic development infrastructure is in place
- **Security model:** ✓ Implementation of Open Integrity Project standards
- **Next steps:** 🔄 Implementing tasks defined in WORK_STREAM_TASKS.md

## Additional Branch Documents

**Supporting documentation:**
- \`CONTRIBUTING.md\` - Guidelines for contributors (to be created)
- \`CODE_OF_CONDUCT.md\` - Community code of conduct (to be created)
- \`templates/\` - Template files for project documentation

## Special Notes for Claude

- **Main branch responsibilities:**
  - The main branch should always be stable
  - All merges to main must come through reviewed PRs
  - Documentation in main branch is the single source of truth
  - WORK_STREAM_TASKS.md in main is the authoritative version

- **Development approach:**
  - Work directly on main only for minor documentation fixes
  - Create feature branches for all substantive changes
  - Follow the branch creation process when starting new work

## Useful Commands

\`\`\`bash
# Branch management
git checkout main
git pull origin main
git push origin main

# Check project status
git status
git log --oneline -n 10

# View branches
git branch -a
\`\`\`

## Next Actions

1. Complete initial setup tasks in WORK_STREAM_TASKS.md
2. Create core documentation files
3. Plan first feature branch
EOF
    print_Message "$Term_Green" "Created main-CONTEXT.md"
  else
    print_Message "$Term_Yellow" "main-CONTEXT.md already exists, skipping"
  fi

  # Also copy branch context template to context directory
  if [[ ! -f "$RepoDir/context/branch_context_template.md" ]]; then
    cat > "$RepoDir/context/branch_context_template.md" << EOF
# [branch-name] Branch Context

> _created: [DATE] by [AUTHOR]_  
> _Note: Replace [DATE] with current date and [AUTHOR] with your name when using this template_
> _status: DRAFT (not committed to git)_  
> _purpose: Provide context for Claude CLI sessions working on this branch_  

## Core Branch Documents

**Primary focus documents:** _(Claude should read these first)_
- `WORK_STREAM_TASKS.md` - Main task tracking for this branch
- `context/[branch-name]-CONTEXT.md` - This context file
- `[specific-file-1.ext]` - [Brief description of primary file specific to this branch]
- `[specific-file-2.ext]` - [Brief description of secondary file specific to this branch]

**Reference documents:** _(Read as needed for specific tasks)_
- `requirements/[requirement-doc].md` - [Brief description of relevant requirement]
- `templates/[template-file].md` - [Brief description of relevant template]

## Branch Overview

The \`[branch-name]\` branch is focused on [brief description of branch purpose]. This branch addresses [specific project goals or requirements].

## Current Status

- **Branch creation:** [✓/🔄] [Status of branch creation and setup]
- **Task planning:** [✓/🔄] [Status of task planning in WORK_STREAM_TASKS.md]
- **Initial commit:** [✓/🔄] [Status of first commit to branch]
- **Documentation:** [✓/🔄] [Status of branch documentation]
- **Next steps:** [✓/🔄] [Immediate next actions]

## Additional Branch Documents

**Supporting documentation:**
- [List any documents created specifically for this branch]
- [Include any templates or scripts specific to this branch's work]
- [Note any other relevant files that aren't in core documents]

## Branch Challenges

- **[Challenge Category 1]:** 
  - [Specific challenge or issue]
  - [Another specific challenge or issue]

- **[Challenge Category 2]:**
  - [Specific challenge or issue]
  - [Another specific challenge or issue]

## Task Plan Summary

The branch work is organized into [X] stages:

- **[Stage 1 Name]** [Status]
- **[Stage 2 Name]** [Status]
- **[Stage 3 Name]** [Status]
- **[Stage 4 Name]** [Status]

## Systematic Improvement Approach

For significant changes in this branch, follow this phased approach:

1. **Phase 1: Basic Fixes and Formatting**
   - Fix typos, grammar, and formatting issues
   - Improve file organization and naming
   - Standardize terminology and conventions

2. **Phase 2: Structural Changes**
   - Address architectural issues
   - Refactor problematic code structures
   - Improve organization and modularity

3. **Phase 3: Content Enhancements**
   - Add new features and capabilities
   - Enhance existing functionality
   - Improve user experience

4. **Phase 4: Review and Polish**
   - Comprehensive testing
   - Documentation updates
   - Final code review and optimization

## Error Handling and Troubleshooting

Document any errors encountered and their solutions here:

- **[Error Category 1]:**
  - Error: [Error message or description]
  - Cause: [Root cause analysis]
  - Solution: [Steps taken to resolve]
  - Prevention: [How to prevent this error in future]

- **Environment-specific issues:**
  - [Issue description]
  - [Platform/environment where it occurs]
  - [Workaround or solution]

- **When encountering new errors:**
  - Document exact error messages
  - Note the context and commands that caused the error
  - Record environment variables and system state
  - Document the solution once found

## Special Notes for Claude

- **Branch specific priorities:**
  - [Priority 1]
  - [Priority 2]
  - [Priority 3]

- **Cross-branch considerations:**
  - [Consideration 1]
  - [Consideration 2]
  - [Consideration 3]

- **Development approach:**
  - [Approach guideline 1]
  - [Approach guideline 2]
  - [Approach guideline 3]

## Useful Commands

\`\`\`bash
# Branch management
git checkout [branch-name]
git pull origin main
git push origin [branch-name]

# [Category] commands
[command example 1]
[command example 2]

# [Another category] commands
[command example 1]
[command example 2]
\`\`\`

## Session Management

- Use standardized restart command for session continuity:
  \`\`\`
  claude "load CLAUDE.md and follow its instructions, identify our current branch, and continue with the next task on that branch"
  \`\`\`
- Between sessions, perform these Git operations:
  - Switch to main and pull updates: \`git checkout main && git pull\`
  - Fetch all remote branches: \`git fetch --all\`
  - Switch back to working branch: \`git checkout [branch-name]\`
- For long sessions, use \`/compact\` to maintain context within token limits

## Next Actions

1. [Next specific action to take]
2. [Second next action to take]
3. [Third next action to take]

## Context Closure Checklist

When completing work on this branch, follow this context closure process:

- [ ] EDIT THE ACTUAL CONTEXT FILE (not just report in chat)
- [ ] Use the Edit tool to update the context file with a new Context Closure section
- [ ] Capture all progress and learnings directly in the branch context file
- [ ] Update and expand the "Completed Work Summary" section with all achievements
- [ ] Document specific testing results with evidence
- [ ] Add detailed "Next Steps for Future Sessions" with specific actions
- [ ] Update task status in WORK_STREAM_TASKS.md with completion dates
- [ ] Document any bugs encountered and their solutions
- [ ] Record key technical details, commands, and lessons learned
- [ ] Update the Development History section if applicable
- [ ] Ensure instructions for resuming work are clear and complete
- [ ] Update the context file's last-updated date in the metadata
- [ ] Verify that the context file has actually been updated with the changes

## References

- [Reference 1]
- [Reference 2]
- [Reference 3]
EOF
    print_Message "$Term_Green" "Created branch_context_template.md"
  else
    print_Message "$Term_Yellow" "branch_context_template.md already exists, skipping"
  fi

  # Set proper permissions
  find "$RepoDir/context" -type f -name "*.md" -exec chmod 644 {} \;
  
  # Create template files using heredocs
  print_Message "$Term_Blue" "Creating template files..."
  
  # Create PR_DESCRIPTION_TEMPLATE.md
  if [[ ! -f "$RepoDir/templates/PR_DESCRIPTION_TEMPLATE.md" ]]; then
    cat > "$RepoDir/templates/PR_DESCRIPTION_TEMPLATE.md" << 'EOF'
# Pull Request Description

## Summary

[Provide a brief summary of the changes in this pull request]

## Changes Made

[List the specific changes made]
- Change 1
- Change 2
- Change 3

## Motivation and Context

[Explain why these changes were made and what problem they solve]

## Implementation Approach

[Describe the approach used to implement the changes]
- Phase 1: [Basic fixes/formatting] 
- Phase 2: [Structural changes]
- Phase 3: [Content enhancements]
- Phase 4: [Final review/polish]

## Testing and Verification

[Describe the testing you've done to validate these changes]
- Test environment: [OS, versions, etc.]
- Test cases:
  1. Test case 1: [Expected vs. actual result]
  2. Test case 2: [Expected vs. actual result]
- Commands used for verification:
  ```
  [Add commands used to verify changes]
  ```
- Issues encountered and solutions:
  - Issue 1: [Solution 1]
  - Issue 2: [Solution 2]

## Error Handling

[Describe how errors are handled in the changes]
- Error scenarios considered:
  - [Error scenario 1]
  - [Error scenario 2]
- Recovery processes:
  - [Recovery process 1]
  - [Recovery process 2]

## Screenshots (if appropriate)

[Include screenshots or images if they help clarify the changes]

## Types of Changes

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Performance improvement
- [ ] Process improvement

## Related Issues

[Link any related issues that this PR addresses]

## Checklist

- [ ] My code follows the project's code style
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing tests pass with my changes
- [ ] I have verified my changes in the target environment
- [ ] I have documented any necessary follow-up work
EOF
    chmod 644 "$RepoDir/templates/PR_DESCRIPTION_TEMPLATE.md"
    print_Message "$Term_Green" "Created PR_DESCRIPTION_TEMPLATE.md"
  else
    print_Message "$Term_Yellow" "PR_DESCRIPTION_TEMPLATE.md already exists, skipping"
  fi
  
  # Create IMPORT_MATERIALS_PR_TEMPLATE.md
  if [[ ! -f "$RepoDir/templates/IMPORT_MATERIALS_PR_TEMPLATE.md" ]]; then
    cat > "$RepoDir/templates/IMPORT_MATERIALS_PR_TEMPLATE.md" << 'EOF'
# Source Materials Import Pull Request

## Summary

This PR imports existing project materials and organizes them into the appropriate repository structure.

## Materials Imported

[Provide a summary of the types of materials imported]
- [List major categories of imported files]
- [Note any significant findings]

## Organization Approach

[Explain how materials were organized]
- [Describe directory structure created]
- [Explain any naming conventions applied]
- [Note any file modifications made during import]

## Status Assessment

[Provide assessment of material status]
- [Current/up-to-date materials]
- [Outdated materials needing revision]
- [Missing materials that need to be created]

## Integration Plan

[Describe how these materials will be integrated with future work]
- [Note if materials are ready for use or need further processing]
- [Identify dependencies between imported materials]
- [List any follow-up tasks needed]

## Special Considerations

[Note any special handling or concerns]
- [Security considerations]
- [Licensing issues]
- [Compatibility problems]
- [Technical debt identified]

## Source Material Inventory

A complete inventory of all imported materials is available in the [Source Materials Inventory](../requirements/source_materials_inventory.md) document.
EOF
    chmod 644 "$RepoDir/templates/IMPORT_MATERIALS_PR_TEMPLATE.md"
    print_Message "$Term_Green" "Created IMPORT_MATERIALS_PR_TEMPLATE.md"
  else
    print_Message "$Term_Yellow" "IMPORT_MATERIALS_PR_TEMPLATE.md already exists, skipping"
  fi
  
  # Create SRC_README_TEMPLATE.md
  if [[ ! -f "$RepoDir/templates/SRC_README_TEMPLATE.md" ]]; then
    cat > "$RepoDir/templates/SRC_README_TEMPLATE.md" << 'EOF'
# Source Directory

This directory contains the main source code for the project.

## Directory Structure

- `core/` - Core functionality and shared components
- `modules/` - Feature-specific modules
- `utils/` - Utility functions and helpers
- `tests/` - Tests for the source code

## Development Guidelines

- Follow the project coding standards
- Write tests for all new functionality
- Document public APIs and complex logic
- Keep modules focused and cohesive

## Build Process

[Describe how to build the source code]

## Testing Process

[Describe how to run tests]

## Additional Information

[Any other relevant information for developers]
EOF
    chmod 644 "$RepoDir/templates/SRC_README_TEMPLATE.md"
    print_Message "$Term_Green" "Created SRC_README_TEMPLATE.md"
  else
    print_Message "$Term_Yellow" "SRC_README_TEMPLATE.md already exists, skipping"
  fi
  
  # Create TESTS_README_TEMPLATE.md
  if [[ ! -f "$RepoDir/templates/TESTS_README_TEMPLATE.md" ]]; then
    cat > "$RepoDir/templates/TESTS_README_TEMPLATE.md" << 'EOF'
# Tests Directory

This directory contains tests for the project.

## Directory Structure

- `unit/` - Unit tests for individual components
- `integration/` - Integration tests for component interactions
- `e2e/` - End-to-end tests for complete workflows
- `fixtures/` - Test fixtures and mock data

## Running Tests

[Instructions for running tests]

## Writing Tests

- Follow the project testing standards
- Name tests clearly to describe what they verify
- Maintain test independence
- Minimize test dependencies
- Use appropriate assertions

## Test Coverage

[Describe test coverage goals and how to check coverage]

## Mocking Strategy

[Explain how and when to use mocks in tests]

## CI Integration

[Describe how tests are integrated with CI]
EOF
    chmod 644 "$RepoDir/templates/TESTS_README_TEMPLATE.md"
    print_Message "$Term_Green" "Created TESTS_README_TEMPLATE.md"
  else
    print_Message "$Term_Yellow" "TESTS_README_TEMPLATE.md already exists, skipping"
  fi
  
  # Create COMMIT_MESSAGE_TEMPLATE.md
  if [[ ! -f "$RepoDir/templates/COMMIT_MESSAGE_TEMPLATE.md" ]]; then
    cat > "$RepoDir/templates/COMMIT_MESSAGE_TEMPLATE.md" << 'EOF'
# Type(scope): Short summary of changes

# Longer explanation if needed
# - What was changed
# - Why it was changed
# - Any important implementation details

# Reference any issues fixed
# Fixes #123

# Include co-authors if needed
# Co-authored-by: Name <email>

# All commits must be signed
# Signed-off-by: Your Name <your.email@example.com>
EOF
    chmod 644 "$RepoDir/templates/COMMIT_MESSAGE_TEMPLATE.md"
    print_Message "$Term_Green" "Created COMMIT_MESSAGE_TEMPLATE.md"
  else
    print_Message "$Term_Yellow" "COMMIT_MESSAGE_TEMPLATE.md already exists, skipping"
  fi
  
  # Create directory for branch templates
  mkdir -p "$RepoDir/templates/branch_templates"
  
  # Create FEATURE_BRANCH_TEMPLATE.md
  if [[ ! -f "$RepoDir/templates/branch_templates/FEATURE_BRANCH_TEMPLATE.md" ]]; then
    cat > "$RepoDir/templates/branch_templates/FEATURE_BRANCH_TEMPLATE.md" << 'EOF'
# feature/[feature-name] Branch Template

## Purpose

This branch is for implementing [brief description of feature].

## Requirements

- [List key requirements this feature addresses]
- [Include links to related issues or requirements docs]

## Implementation Plan

1. [Step 1 of implementation]
2. [Step 2 of implementation]
3. [Step 3 of implementation]

## Testing Strategy

- [Describe how this feature will be tested]
- [List specific test cases to be created]

## Documentation Needs

- [List documentation that needs to be created/updated]
- [Note any API changes that need documenting]

## Dependencies

- [List any dependencies this feature has]
- [Note any other branches or PRs this depends on]

## Review Checklist

- [ ] Implementation follows requirements
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Code follows project standards
- [ ] No unnecessary changes included
EOF
    chmod 644 "$RepoDir/templates/branch_templates/FEATURE_BRANCH_TEMPLATE.md"
    print_Message "$Term_Green" "Created branch template: FEATURE_BRANCH_TEMPLATE.md"
  else
    print_Message "$Term_Yellow" "Branch template FEATURE_BRANCH_TEMPLATE.md already exists, skipping"
  fi
  
  # Set permissions for all template files
  find "$RepoDir/templates" -type f -name "*.md" -exec chmod 644 {} \; 2>/dev/null || true
  
  # Create .github directory for GitHub templates if it doesn't exist
  if [[ ! -d "$RepoDir/.github" ]]; then
    mkdir -p "$RepoDir/.github/ISSUE_TEMPLATE"
    mkdir -p "$RepoDir/.github/workflows"
    chmod 755 "$RepoDir/.github"
    chmod 755 "$RepoDir/.github/ISSUE_TEMPLATE"
    chmod 755 "$RepoDir/.github/workflows"
  fi
  
  # Ensure all directories have correct permissions
  find "$RepoDir/requirements" "$RepoDir/templates" "$RepoDir/context" -type d -exec chmod 755 {} \;
  
  # Create initial commit with template files
  cd "$RepoDir"
  git add CLAUDE.md WORK_STREAM_TASKS.md requirements/ context/ templates/
  git commit -S -s -m "Add initial project workflow files

- Add CLAUDE.md for Claude CLI guidance and context management
- Add WORK_STREAM_TASKS.md for structured task tracking
- Add requirements/ directory with process definitions
- Add context/ directory with branch context files
- Add templates/ directory for project documentation

These files establish a requirements-driven development process with
clear documentation, branch management, and context preservation for
AI-assisted development using Claude Code CLI."
  
  # Push all commits to GitHub
  print_Message "$Term_Blue" "Pushing all commits to GitHub..."
  
  # Get current commit SHA
  typeset CurrentCommitId=$(git rev-parse HEAD)
  
  # Create a temporary branch at current commit
  print_Message "$Term_Blue" "Creating temporary branch at current commit..."
  git branch -f _temp_push_branch "$CurrentCommitId"
  
  # Push temporary branch to GitHub main branch
  print_Message "$Term_Blue" "Pushing temporary branch to GitHub main branch..."
  # Suppress warnings about untracked files during push
  export GIT_STATUS_SHOW_UNTRACKED=no
  if ! git push -f -u origin _temp_push_branch:main; then
    unset GIT_STATUS_SHOW_UNTRACKED
    print_Message "$Term_Red" "Error: Failed to push to GitHub main branch."
    git branch -D _temp_push_branch
    return $Exit_Status_Git_Failure
  fi
  
  print_Message "$Term_Green" "Successfully pushed commits to GitHub main branch."
  unset GIT_STATUS_SHOW_UNTRACKED
  git branch -D _temp_push_branch
  
  print_Message "$Term_Green" "Template files copied successfully."
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: copy_Additional_Templates
#----------------------------------------------------------------------#
# Description:
#   Copies additional templates for PR creation and directory READMEs
# Parameters:
#   $1 - Repository directory
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_IO on failure
# Dependencies:
#   Requires template files in the bootstrap directory
#----------------------------------------------------------------------#
function copy_Additional_Templates() {
  typeset RepoDir="$1"
  
  print_Message "$Term_Blue" "Creating README files in src and tests directories..."
  
  # Create directories
  mkdir -p "$RepoDir/src"
  mkdir -p "$RepoDir/src/tests"
  
  # Create src/README.md using the SRC_README_TEMPLATE.md content
  if [[ ! -f "$RepoDir/src/README.md" ]]; then
    cat > "$RepoDir/src/README.md" << 'EOF'
# Source Directory

This directory contains the main source code for the project.

## Directory Structure

- `core/` - Core functionality and shared components
- `modules/` - Feature-specific modules
- `utils/` - Utility functions and helpers
- `tests/` - Tests for the source code

## Development Guidelines

- Follow the project coding standards
- Write tests for all new functionality
- Document public APIs and complex logic
- Keep modules focused and cohesive

## Build Process

[Describe how to build the source code]

## Testing Process

[Describe how to run tests]

## Additional Information

[Any other relevant information for developers]
EOF
    chmod 644 "$RepoDir/src/README.md"
    print_Message "$Term_Green" "Created src/README.md"
  else
    print_Message "$Term_Yellow" "src/README.md already exists, skipping"
  fi
  
  # Create src/tests/README.md using the TESTS_README_TEMPLATE.md content
  if [[ ! -f "$RepoDir/src/tests/README.md" ]]; then
    cat > "$RepoDir/src/tests/README.md" << 'EOF'
# Tests Directory

This directory contains tests for the project.

## Directory Structure

- `unit/` - Unit tests for individual components
- `integration/` - Integration tests for component interactions
- `e2e/` - End-to-end tests for complete workflows
- `fixtures/` - Test fixtures and mock data

## Running Tests

[Instructions for running tests]

## Writing Tests

- Follow the project testing standards
- Name tests clearly to describe what they verify
- Maintain test independence
- Minimize test dependencies
- Use appropriate assertions

## Test Coverage

[Describe test coverage goals and how to check coverage]

## Mocking Strategy

[Explain how and when to use mocks in tests]

## CI Integration

[Describe how tests are integrated with CI]
EOF
    chmod 644 "$RepoDir/src/tests/README.md"
    print_Message "$Term_Green" "Created src/tests/README.md"
  else
    print_Message "$Term_Yellow" "src/tests/README.md already exists, skipping"
  fi
  
  # Create .github/ISSUE_TEMPLATE/bug_report.md if it doesn't exist
  mkdir -p "$RepoDir/.github/ISSUE_TEMPLATE"
  if [[ ! -f "$RepoDir/.github/ISSUE_TEMPLATE/bug_report.md" ]]; then
    cat > "$RepoDir/.github/ISSUE_TEMPLATE/bug_report.md" << 'EOF'
---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description
A clear and concise description of what the bug is.

## Steps To Reproduce
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## Expected Behavior
A clear and concise description of what you expected to happen.

## Actual Behavior
What actually happened.

## Screenshots
If applicable, add screenshots to help explain your problem.

## Environment
- OS: [e.g. Windows 10, macOS Big Sur, Ubuntu 20.04]
- Browser (if applicable): [e.g. Chrome 90, Firefox 88]
- Version: [e.g. 1.0.2]

## Additional Context
Add any other context about the problem here.
EOF
    chmod 644 "$RepoDir/.github/ISSUE_TEMPLATE/bug_report.md"
    print_Message "$Term_Green" "Created bug_report.md template"
  else
    print_Message "$Term_Yellow" "bug_report.md template already exists, skipping"
  fi
  
  # Create .github/ISSUE_TEMPLATE/feature_request.md if it doesn't exist
  if [[ ! -f "$RepoDir/.github/ISSUE_TEMPLATE/feature_request.md" ]]; then
    cat > "$RepoDir/.github/ISSUE_TEMPLATE/feature_request.md" << 'EOF'
---
name: Feature request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

## Problem Statement
A clear and concise description of what problem this feature would solve. Ex. I'm always frustrated when [...]

## Proposed Solution
A clear and concise description of what you want to happen.

## Alternative Solutions
A clear and concise description of any alternative solutions or features you've considered.

## User Benefits
How would this feature benefit users of the project?

## Implementation Ideas
If you have ideas about how this could be implemented, describe them here.

## Additional Context
Add any other context or screenshots about the feature request here.
EOF
    chmod 644 "$RepoDir/.github/ISSUE_TEMPLATE/feature_request.md"
    print_Message "$Term_Green" "Created feature_request.md template"
  else
    print_Message "$Term_Yellow" "feature_request.md template already exists, skipping"
  fi
  
  print_Message "$Term_Green" "Additional templates created successfully."
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: create_Source_Material_Branch
#----------------------------------------------------------------------#
# Description:
#   Creates a branch for source material import
# Parameters:
#   $1 - Repository directory
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_Git_Failure on failure
# Dependencies:
#   Requires git command
#----------------------------------------------------------------------#
function create_Source_Material_Branch() {
  typeset RepoDir="$1"
  
  print_Message "$Term_Blue" "Creating branch for source material import..."
  
  cd "$RepoDir"
  
  # Create a branch for importing existing materials
  typeset BranchName="docs/import-existing-materials"
  git checkout -b "$BranchName"
  
  # Create a source material inventory file template
  typeset InventoryFile="requirements/source_materials_inventory.md"
  cat > "$InventoryFile" << EOF
# Source Materials Inventory

This document tracks the status of source materials imported into the project.

## Requirements Documents

| Filename | Status | Notes |
|----------|--------|-------|
| [Example-doc.md] | [Current/Draft/Outdated] | [Brief notes about the file] |

## Source Files

| Filename | Status | Conformance | Notes |
|----------|--------|-------------|-------|
| [Example-file.ext] | [Current/Draft/Outdated] | [Conformance status] | [Brief notes about the file] |

## Test Files

| Filename | Status | Conformance | Notes |
|----------|--------|-------------|-------|
| [Example-test.ext] | [Current/Draft/Outdated] | [Conformance status] | [Brief notes about the file] |

## Integration Plan

1. [Step 1 of integration plan]
2. [Step 2 of integration plan]
3. [Step 3 of integration plan]

## Function Inventory

The following functions have been identified in the source materials:

| Function Name | Source File | Status | Notes |
|---------------|-------------|--------|-------|
| [function_name] | [source_file.ext] | [Current/Draft/Outdated] | [Brief notes about the function] |

## Next Steps

1. [Next step 1]
2. [Next step 2]
3. [Next step 3]
EOF

  # Create branch context file
  typeset ContextFilename="context/$(echo "$BranchName" | tr '/' '-')-CONTEXT.md"
  
  cat > "$ContextFilename" << EOF
# $BranchName Branch Context

> _created: $(date +"%Y-%m-%d") by $(git config --get user.name)_  
> _status: ACTIVE_  
> _purpose: Provide context for importing and organizing existing materials_  

## Core Branch Documents

**Primary focus documents:** _(Claude should read these first)_
- `WORK_STREAM_TASKS.md` - Tasks for this branch in the "Branch: [$BranchName]" section
- `context/$(echo "$BranchName" | tr '/' '-')-CONTEXT.md` - This context file
- `requirements/source_materials_inventory.md` - Tracks status of imported materials
- `templates/IMPORT_MATERIALS_PR_TEMPLATE.md` - Template for PR creation at completion

**Reference documents:** _(Read as needed for specific tasks)_
- `untracked/source-material/` - Directory for initial file uploads
- `README.md` - Project overview and documentation

## Branch Overview

The \`$BranchName\` branch is for importing and organizing existing project materials before integrating them into the main structure.

## Current Status

- **Branch creation:** ✓ Branch created on $(date +"%Y-%m-%d")
- **Task planning:** ✓ Initial tasks defined for importing and organizing materials
- **Initial commit:** ✓ Branch context and inventory file created
- **Next steps:** 🔄 Upload existing materials to untracked/source-material directory

## Additional Branch Documents

**Supporting documentation:**
- `src/` - Will contain organized source files after review
- `src/tests/` - Will contain test files after review
- `requirements/` - Will contain requirement documents after review

## Branch Challenges

1. **Source Material Organization:** 
   - Determining the best structure for organizing imported materials
   - Balancing existing organization with project standards

2. **Status Assessment:**
   - Evaluating currency and quality of existing materials
   - Identifying which files need updates vs. which can be used as-is

## Task Plan Summary

The branch work is organized into 3 stages:

- **Import Process** 🔄 - Import existing materials to untracked/source-material
- **Review Process** ⏳ - Review and document status of all materials
- **Organization Process** ⏳ - Organize files into proper structure

## Special Notes for Claude

- **Branch specific priorities:**
  - First focus on uploading all materials before organizing
  - Document file status in source_materials_inventory.md
  - Create appropriate directory structure based on material types

- **Process flow:**
  - Ask user to upload files to untracked/source-material
  - Confirm all uploads are complete before organizing
  - Review files to understand their purpose and status
  - Document in inventory before moving to final locations

## Useful Commands

\`\`\`bash
# Branch management
git checkout $BranchName
git pull origin main
git push origin $BranchName

# File operations
ls -la untracked/source-material/
find untracked/source-material/ -type f | sort
\`\`\`

## Next Actions

1. Ask user to upload existing materials to untracked/source-material directory
2. After uploads, review each file to understand purpose and status
3. Document all files in requirements/source_materials_inventory.md
4. Create appropriate directory structure for organizing files
5. Move files to proper locations preserving permissions
6. Use templates/IMPORT_MATERIALS_PR_TEMPLATE.md when creating PR
EOF

  # Update WORK_STREAM_TASKS.md to include tasks for the branch
  # First, find the line where we should insert the new branch section
  typeset LineNum=$(grep -n "^## Unassigned Tasks" WORK_STREAM_TASKS.md | cut -d: -f1)
  
  if [[ -n "$LineNum" ]]; then
    # Create a temporary file with the new branch section
    typeset TempFile=$(mktemp)
    
    cat > "$TempFile" << EOF

## Branch: [$BranchName]

This branch is for importing and organizing existing project materials before integrating them into the main structure.

**Related Requirements:**
- Context file: [context/$(echo "$BranchName" | tr '/' '-')-CONTEXT.md](context/$(echo "$BranchName" | tr '/' '-')-CONTEXT.md)
- PR Template: [templates/IMPORT_MATERIALS_PR_TEMPLATE.md](templates/IMPORT_MATERIALS_PR_TEMPLATE.md)

### Stage 1: Import Process

- [ ] **Setup for imports** [$BranchName] (High Priority)
  - [ ] Create untracked/source-material directory for existing files
  - [ ] Have user upload existing code, documentation, and requirements
  - [ ] Confirm all materials are uploaded before organizing

- [ ] **Review and organize** [$BranchName] (High Priority)
  - [ ] Review uploaded materials to understand structure and content
  - [ ] Create appropriate directories based on content types
  - [ ] Organize files into proper structure
  - [ ] Update documentation to reflect imported content

### Stage 2: Branch Completion Process

- [ ] **Create local PR** [$BranchName] (High Priority)
  - [ ] Ensure all changes are committed
  - [ ] Create detailed PR description
  - [ ] Highlight major changes and improvements
  - [ ] Request review

- [ ] **Push to GitHub** [$BranchName] (High Priority)
  - [ ] Push branch to GitHub
  - [ ] Create PR on GitHub
  - [ ] Verify branch and PR appear on GitHub

EOF
    
    # Insert the branch section before the Unassigned Tasks section
    sed -i '' "${LineNum}r ${TempFile}" WORK_STREAM_TASKS.md
    
    # Clean up
    rm "$TempFile"
  fi

  # Update main branch work items to include reviewing the PR from this branch
  # First, find the section for branch management in main
  LineNum=$(grep -n "^### Stage 3: Branch Management and PR Process" WORK_STREAM_TASKS.md | cut -d: -f1)
  
  if [[ -n "$LineNum" ]]; then
    # Find the first Review task line
    typeset ReviewLine=$(grep -n "Review" WORK_STREAM_TASKS.md | awk -v ln=$LineNum '$1 > ln {print $1; exit}' | cut -d: -f1)
    
    if [[ -n "$ReviewLine" ]]; then
      # Update the task to include reviewing this specific branch's PR
      sed -i '' "${ReviewLine}s/- \[ \] Review.*$/- [ ] Review $BranchName PR/" WORK_STREAM_TASKS.md
    fi
  fi

  # Add the "initial-materials" task as completed
  sed -i '' 's/- \[ \] Create untracked\/source-material directory for existing files/- [x] Create untracked\/source-material directory for existing files ('"$(date +"%Y-%m-%d")"')/' WORK_STREAM_TASKS.md
  
  # Stage and commit the changes
  git add WORK_STREAM_TASKS.md "$ContextFilename" "$InventoryFile"
  git commit -S -s -m "Set up branch for importing existing materials

- Create branch context file with import process guidance
- Add source materials inventory template
- Update work stream tasks with import process steps
- Create directory structure for organizing imported files"

  # Push the branch to GitHub
  print_Message "$Term_Blue" "Pushing import branch to GitHub..."
  if ! git push -u origin "$BranchName"; then
    print_Message "$Term_Yellow" "Warning: Could not push import branch to GitHub. This might be due to network issues."
    print_Message "$Term_Yellow" "You can push manually later with: git push -u origin $BranchName"
    print_Message "$Term_Yellow" "Continuing with script execution..."
  else
    print_Message "$Term_Green" "Successfully pushed import branch to GitHub."
  fi
  
  # Switch back to main branch for final setup
  git checkout main
  
  print_Message "$Term_Green" "Source material import branch created successfully."
  print_Message "$Term_Yellow" "To begin working with it, run: git checkout $BranchName"
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: core_Logic
#----------------------------------------------------------------------#
# Description:
#   Main script workflow to install bootstrap templates
# Parameters:
#   $1 - Repository name
# Returns:
#   Exit_Status_Success on success
#   Various error codes on failure
# Dependencies:
#   Calls validate_Prerequisites, copy_Template_Files, copy_Additional_Templates, and create_Source_Material_Branch
#----------------------------------------------------------------------#
function core_Logic() {
  typeset RepoName="$1"
  typeset ClearBackup="${2:-false}"
  
  # Determine repository directory path
  typeset RepoDir
  if [[ "$RepoName" == "." || "$RepoName" == "$(basename "$PWD")" ]]; then
    # Use the current directory
    RepoDir="$PWD"
    RepoName=$(basename "$PWD")
  elif [[ "$RepoName" == /* ]]; then
    # If an absolute path is provided, use it directly
    RepoDir="$RepoName"
  else
    # If a relative path or just a name, use it as a subdirectory of current dir
    RepoDir="$PWD/$RepoName"
  fi
  
  # Verify we're on main branch before starting
  if [[ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]]; then
    print_Message "$Term_Yellow" "Warning: Not on main branch. Switching to main branch..."
    if ! git checkout main; then
      print_Message "$Term_Red" "Error: Failed to switch to main branch. Aborting."
      return $Exit_Status_Git_Failure
    fi
  fi
  
  # Make sure any temp-gitignore branch is deleted
  if git show-ref --verify --quiet refs/heads/temp-gitignore; then
    print_Message "$Term_Yellow" "Found temp-gitignore branch. Deleting..."
    if ! git branch -D temp-gitignore; then
      print_Message "$Term_Yellow" "Warning: Could not delete temp-gitignore branch. Will try again later."
    fi
  fi
  
  # Validate prerequisites 
  validate_Prerequisites || return $?

  # Create backup directory structure for bootstrap files FIRST, before any modifications
  print_Message "$Term_Blue" "Creating backup structure for bootstrap files..."
  
  # Create untracked directory if it doesn't exist
  if [[ ! -d "$RepoDir/untracked" ]]; then
    mkdir -p "$RepoDir/untracked"
    print_Message "$Term_Green" "Created untracked directory"
  else
    print_Message "$Term_Yellow" "untracked directory already exists, skipping creation"
  fi
  
  # Always clear the backup directory to ensure clean backups
  if [[ -d "$RepoDir/untracked/original_bootstrap_files" ]]; then
    if [[ "$ClearBackup" == "true" ]]; then
      print_Message "$Term_Blue" "Clearing existing backup in untracked/original_bootstrap_files..."
      rm -rf "$RepoDir/untracked/original_bootstrap_files"
    else
      print_Message "$Term_Yellow" "Using existing backup directory. Use --clear-backup to create a clean backup."
    fi
  fi
  
  # Create the backup directory if it doesn't exist or was cleared
  if [[ ! -d "$RepoDir/untracked/original_bootstrap_files" ]]; then
    mkdir -p "$RepoDir/untracked/original_bootstrap_files"
    
    # Only backup the original bootstrap files (pre-script state)
    # These are the files that should exist BEFORE any scripts are run
    typeset original_files=(
      "README.md"
      "CLAUDE.md"
      "WORK_STREAM_TASKS.md"
      "setup_local_git_inception.sh"
      "create_github_remote.sh"
      "install_bootstrap_templates.sh"
      "feature-test-and-update-claude-code-bootstrap-CONTEXT.md"
    )
    
    for file in "${original_files[@]}"; do
      if [[ -f "$RepoDir/$file" ]]; then
        cp -f "$RepoDir/$file" "$RepoDir/untracked/original_bootstrap_files/" 2>/dev/null
        print_Message "$Term_Green" "Backed up $file"
      fi
    done
    
    print_Message "$Term_Green" "Original bootstrap files backed up to untracked/original_bootstrap_files/"
  fi
  
  # Create updated_bootstrap_files directory for future updates
  if [[ ! -d "$RepoDir/untracked/updated_bootstrap_files" ]]; then
    mkdir -p "$RepoDir/untracked/updated_bootstrap_files/templates"
    mkdir -p "$RepoDir/untracked/updated_bootstrap_files/context"
    mkdir -p "$RepoDir/untracked/updated_bootstrap_files/requirements"
    print_Message "$Term_Green" "Created untracked/updated_bootstrap_files/ directory structure"
  else
    print_Message "$Term_Yellow" "updated_bootstrap_files directory already exists, skipping creation"
  fi
  
  # Copy template files to repository
  copy_Template_Files "$RepoDir" || return $?
  
  # Copy additional templates
  copy_Additional_Templates "$RepoDir" || return $?
  
  # Create source material import branch
  create_Source_Material_Branch "$RepoDir" || return $?
  
  # Display success message
  print_Message "$Term_Green" "Bootstrap templates installed successfully!"
  print_Message "$Term_Blue" "Repository Directory: $RepoDir"
  print_Message "$Term_Yellow" "Next steps:"
  print_Message "$Term_Yellow" "1. Start Claude CLI in the repository directory:"
  print_Message "$Term_Yellow" "   cd \"$RepoDir\" && claude"
  print_Message "$Term_Yellow" "2. Claude will guide you through the repository setup and tasks"
  
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: parse_Parameters
#----------------------------------------------------------------------#
# Description:
#   Processes and validates command line arguments
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_Usage for invalid arguments
#----------------------------------------------------------------------#
function parse_Parameters() {
  # Process options
  local clear_backup=false
  
  # Parse options
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --clear-backup)
        clear_backup=true
        shift
        ;;
      -*)
        print_Message "$Term_Red" "Error: Unknown option: $1"
        print_Message "$Term_Yellow" "Usage: $0 [--clear-backup] <repo-name>"
        return $Exit_Status_Usage
        ;;
      *)
        break
        ;;
    esac
  done
  
  # Validate input parameters
  if [[ -z "${1:-}" ]]; then
    print_Message "$Term_Red" "Error: Repository name is required."
    print_Message "$Term_Yellow" "Usage: $0 [--clear-backup] <repo-name>"
    return $Exit_Status_Usage
  fi
  
  # Output parameters as JSON
  printf '{"repo_name":"%s","clear_backup":%s}' "$1" "$clear_backup"
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: main
#----------------------------------------------------------------------#
# Description:
#   Main script entry point
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Various exit status codes
#----------------------------------------------------------------------#
function main() {
  typeset RepoName
  typeset ClearBackup
  
  # Parse command line parameters
  local params_json
  params_json=$(parse_Parameters "$@") || exit $?
  
  # Extract parameters from JSON
  RepoName=$(print -- "$params_json" | grep -o '"repo_name":"[^"]*"' | cut -d'"' -f4)
  ClearBackup=$(print -- "$params_json" | grep -o '"clear_backup":[a-z]*' | cut -d':' -f2)
  
  # Execute core logic
  core_Logic "$RepoName" "$ClearBackup" || exit $?
  
  exit $Exit_Status_Success
}

# Execute only if run directly
if [[ "${(%):-%N}" == "$0" ]]; then
  main "$@"
fi