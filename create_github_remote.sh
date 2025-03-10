#!/usr/bin/env zsh
########################################################################
## Script:        create_github_remote.sh
## Version:       0.1.0 (2025-03-07)
## Origin:        https://github.com/ChristopherA/Claude-Code-Bootstrap/blob/main/scripts/create_github_remote.sh
## Description:   Creates a GitHub repository and configures it as a remote
##                for the local Git repository
## License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
## Copyright:     (c) 2025 @ChristopherA
## Attribution:   Authored by @ChristopherA
## Usage:         create_github_remote.sh <repo-name> [public|private]
## Examples:      create_github_remote.sh my-project      # Uses public (default)
##                create_github_remote.sh my-project public
##                create_github_remote.sh my-project private  # Note: Private repos can't use branch protection
## Dependencies:  git, gh (GitHub CLI), jq
## Requirements:  GitHub CLI must be authenticated with 'gh auth login'
## Note:          This script may show "Warning: N uncommitted changes" despite using
##                GIT_STATUS_SHOW_UNTRACKED=no. This is a known GitHub CLI bug:
##                https://github.com/cli/cli/issues/10572
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
# Function: validate_GitHub_Prerequisites
#----------------------------------------------------------------------#
# Description:
#   Validates that GitHub CLI is installed and authenticated
# Parameters:
#   None
# Returns:
#   Exit_Status_Success on success
#   Various error codes on failure
# Dependencies:
#   Requires gh command
#----------------------------------------------------------------------#
function validate_GitHub_Prerequisites() {
  print_Message "$Term_Blue" "Validating GitHub prerequisites..."

  # Check for git
  if ! command_Exists git; then
    print_Message "$Term_Red" "Error: git is not installed. Please install git and try again."
    return $Exit_Status_Dependency
  fi
  
  # Check for GitHub CLI
  if ! command_Exists gh; then
    print_Message "$Term_Red" "Error: GitHub CLI (gh) is not installed. Please install it and try again."
    print_Message "$Term_Yellow" "See: https://cli.github.com/manual/installation"
    return $Exit_Status_Dependency
  fi
  
  # Check for jq (needed for GitHub API responses)
  if ! command_Exists jq; then
    print_Message "$Term_Red" "Error: jq is not installed. Please install jq and try again."
    print_Message "$Term_Yellow" "You can install it with: brew install jq (macOS) or apt install jq (Linux)"
    return $Exit_Status_Dependency
  fi

  # Check GitHub CLI authentication
  if ! gh auth status >/dev/null 2>&1; then
    print_Message "$Term_Red" "Error: GitHub CLI is not authenticated. Please run 'gh auth login' and try again."
    return $Exit_Status_Config
  fi
  
  print_Message "$Term_Green" "All GitHub prerequisites validated successfully."
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: create_GitHub_Repository
#----------------------------------------------------------------------#
# Description:
#   Creates a GitHub repository and configures it as a remote
# Parameters:
#   $1 - Repository name
#   $2 - Visibility (public or private)
# Returns:
#   Exit_Status_Success on success
#   Various error codes on failure
# Dependencies:
#   Requires gh command
#----------------------------------------------------------------------#
function create_GitHub_Repository() {
  typeset RepoName="$1"
  typeset Visibility="$2"
  
  # We no longer need the trap since our helper function handles unsetting the variable
  
  # Get GitHub username upfront so we have it for the entire function
  typeset GitHubUsername=$(run_GitHub_Command gh api user | jq -r '.login')
  
  print_Message "$Term_Blue" "Creating GitHub repository: $RepoName..."
  
  # Check if the repository already exists before trying to create it
  print_Message "$Term_Blue" "Checking if repository already exists at github.com/$GitHubUsername/$RepoName..."
  typeset RepoExists=false
  
  # Check if repository exists
  if run_GitHub_Command gh repo view "$GitHubUsername/$RepoName" &>/dev/null; then
    RepoExists=true
    print_Message "$Term_Yellow" "Repository already exists at github.com/$GitHubUsername/$RepoName"
    
    # Configure the remote if it doesn't exist
    if ! git remote | grep -q "^origin$"; then
      print_Message "$Term_Blue" "Setting up remote for existing repository..."
      git remote add origin "https://github.com/$GitHubUsername/$RepoName.git"
    else
      print_Message "$Term_Blue" "Remote 'origin' already exists, verifying URL..."
      typeset CurrentUrl=$(git remote get-url origin)
      if [[ "$CurrentUrl" != *"$GitHubUsername/$RepoName"* ]]; then
        print_Message "$Term_Yellow" "Updating remote URL to match GitHub repository..."
        git remote set-url origin "https://github.com/$GitHubUsername/$RepoName.git"
      fi
    fi
    
    # Verify repository has our inception commit
    print_Message "$Term_Blue" "Checking repository state..."
    typeset InceptionCommitId=$(git rev-list --max-parents=0 HEAD)
    
    # Check if our inception commit exists on remote
    # Use GIT_STATUS_SHOW_UNTRACKED=no for gh commands
    if ! run_GitHub_Command gh api "repos/$GitHubUsername/$RepoName/commits/$InceptionCommitId" --silent 2>/dev/null; then
      print_Message "$Term_Red" "Remote repository has different history than local."
      return $Exit_Status_Git_Failure
    else
      print_Message "$Term_Green" "Inception commit already exists on remote."
    fi
  else
    # Create GitHub repository if it doesn't exist
    print_Message "$Term_Blue" "Creating GitHub repository: $RepoName..."
    if ! run_GitHub_Command gh repo create "$RepoName" --"$Visibility" --source=. --remote=origin; then
      print_Message "$Term_Red" "Error: Failed to create GitHub repository."
      return $Exit_Status_Git_Failure
    fi
  fi
  
  # Verify remote configuration
  print_Message "$Term_Blue" "Verifying remote configuration..."
  if ! git remote -v | grep -q "^origin"; then
    print_Message "$Term_Red" "Error: GitHub remote not configured correctly."
    return $Exit_Status_Git_Failure
  fi
  
  # Initial push to main branch - only push the inception commit
  print_Message "$Term_Blue" "Pushing inception commit to GitHub repository..."
  
  # Find the inception commit
  typeset InceptionCommitId=$(git rev-list --max-parents=0 HEAD)
  if [[ -z "$InceptionCommitId" ]]; then
    print_Message "$Term_Red" "Error: Could not find inception commit."
    print_Message "$Term_Yellow" "Please make sure the repository has been properly initialized."
    return $Exit_Status_Git_Failure
  fi
  
  print_Message "$Term_Blue" "Found inception commit: $InceptionCommitId"
  
  # Push only the inception commit to establish root of trust
  # Check whether we need to push or if the commit already exists
  # Check if inception commit exists on remote
  if [[ "$RepoExists" == "true" ]] && run_GitHub_Command gh api "repos/$GitHubUsername/$RepoName/commits/$InceptionCommitId" --silent 2>/dev/null; then
    print_Message "$Term_Green" "Inception commit already exists on remote. Skipping push."
  else
    # Repository is empty or new - use the reliable temp branch method
    print_Message "$Term_Blue" "Creating temporary branch at inception commit..."
    git branch -f _temp_inception "$InceptionCommitId"
    
    print_Message "$Term_Blue" "Pushing temporary branch to GitHub main branch..."
    # Suppress warnings about untracked files during push
    if ! run_GitHub_Command git push -u origin _temp_inception:main; then
      print_Message "$Term_Red" "Error: Failed to push inception commit to GitHub repository."
      git branch -D _temp_inception
      return $Exit_Status_Git_Failure
    fi
    
    print_Message "$Term_Green" "Successfully pushed inception commit to GitHub."
    git branch -D _temp_inception
  fi
  
  # Configure branch protection first, before adding any PR content
  configure_Branch_Protection "$GitHubUsername" "$RepoName"
  
  # Create .gitignore file and push directly to main like we did with inception commit
  print_Message "$Term_Blue" "Creating .gitignore file to test branch protection..."
  
  # Create a temporary branch for adding .gitignore
  git checkout -f -b temp-gitignore
  
  # Create .gitignore file
  print_Message "$Term_Blue" "Creating .gitignore file..."
  cat > .gitignore << EOF
# Compiled output
/dist
/build
/out
/target

# Dependencies
/node_modules
/.pnp
.pnp.js

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE files
/.idea
/.vscode
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Project specific
/untracked
EOF

  # Stage and commit .gitignore
  git add .gitignore
  git commit -S -s -m "Add initial repository structure with .gitignore"
  
  # Get the commit SHA
  typeset GitIgnoreCommitId=$(git rev-parse HEAD)
  
  # Create a temporary branch at the .gitignore commit
  print_Message "$Term_Blue" "Creating temporary branch at .gitignore commit..."
  git branch -f _temp_gitignore "$GitIgnoreCommitId"
  
  # Push the temporary branch directly to main (same approach that worked for inception commit)
  print_Message "$Term_Blue" "Pushing .gitignore to main branch..."
  if ! run_GitHub_Command git push -f origin _temp_gitignore:main; then
    print_Message "$Term_Red" "Error: Failed to push .gitignore to GitHub repository."
    # Switch to main first, then delete the temp branch
    git checkout -f main
    git branch -D _temp_gitignore
    return $Exit_Status_Git_Failure
  fi
  
  print_Message "$Term_Green" "Successfully pushed .gitignore to main branch."
  
  # Return to main branch first before cleaning up branches
  git checkout -f main
  
  # Clean up temporary branches
  git branch -D _temp_gitignore
  
  # Clean up temp-gitignore branch if it exists
  if git show-ref --verify --quiet refs/heads/temp-gitignore; then
    git branch -D temp-gitignore
  fi
  
  # Pull changes from remote
  git pull origin main --ff-only
  
  print_Message "$Term_Green" "GitHub repository created and initialized successfully."
  
  # Verify GitHub setup
  verify_GitHub_Setup "$RepoName" || {
    print_Message "$Term_Yellow" "Warning: Some GitHub verification checks failed but repository was created."
  }
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: configure_Branch_Protection
#----------------------------------------------------------------------#
# Description:
#   Configures branch protection for the GitHub repository
# Parameters:
#   $1 - Repository owner (GitHub username)
#   $2 - Repository name
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_General on failure (non-critical)
# Dependencies:
#   Requires gh command
#----------------------------------------------------------------------#
function run_GitHub_Command() {
  # Helper function to run GitHub CLI commands with GIT_STATUS_SHOW_UNTRACKED=no
  export GIT_STATUS_SHOW_UNTRACKED=no
  "$@"
  typeset Result=$?
  unset GIT_STATUS_SHOW_UNTRACKED
  return $Result
}

function configure_Branch_Protection() {
  typeset RepoOwner="$1"
  typeset RepoName="$2"
  
  print_Message "$Term_Blue" "Configuring branch protection for $RepoOwner/$RepoName..."
  
  # Create a temporary JSON file with correctly formatted protection rules
  # This approach has been tested and works reliably
  typeset TempJsonFile=$(mktemp)
  cat > "$TempJsonFile" << EOF
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1
  },
  "restrictions": null
}
EOF
  
  print_Message "$Term_Blue" "Setting up branch protection rules..."
  
  # Use the JSON input file approach which has been proven to work
  if ! run_GitHub_Command gh api --method PUT "/repos/$RepoOwner/$RepoName/branches/main/protection" \
     -H "Accept: application/vnd.github+json" \
     --input "$TempJsonFile"; then
    print_Message "$Term_Yellow" "Warning: Branch protection could not be applied."
    print_Message "$Term_Yellow" "Branch protection will need to be configured manually."
  else
    print_Message "$Term_Green" "Branch protection applied successfully using JSON input."
  fi
  
  # Clean up the temporary file
  rm -f "$TempJsonFile"
  
  # Enable required signatures - this is a separate API endpoint
  print_Message "$Term_Blue" "Enabling required commit signatures..."
  
  if ! run_GitHub_Command gh api --method POST "/repos/$RepoOwner/$RepoName/branches/main/protection/required_signatures" \
     -H "Accept: application/vnd.github+json"; then
    print_Message "$Term_Yellow" "Warning: Could not enable required signatures."
    print_Message "$Term_Yellow" "This may be due to account limitations or API changes."
  else
    print_Message "$Term_Green" "Required signatures enabled successfully."
  fi
  
  # Verify protection is active
  print_Message "$Term_Blue" "Verifying branch protection status..."
  typeset BranchProtection
  
  BranchProtection=$(run_GitHub_Command gh api "/repos/$RepoOwner/$RepoName/branches/main/protection" \
                    -H "Accept: application/vnd.github+json" 2>/dev/null)
  
  if [[ -n "$BranchProtection" ]]; then
    print_Message "$Term_Green" "Branch protection is active."
  else
    print_Message "$Term_Yellow" "Branch protection may not be fully configured."
  fi
  
  print_Message "$Term_Green" "Branch protection setup complete."
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: verify_GitHub_Setup
#----------------------------------------------------------------------#
# Description:
#   Verifies GitHub repository configuration
# Parameters:
#   $1 - Repository name
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_General on failure (non-critical)
# Dependencies:
#   Requires git and gh commands
#----------------------------------------------------------------------#
function verify_GitHub_Setup() {
  typeset RepoName="$1"
  
  print_Message "$Term_Blue" "Verifying GitHub repository configuration..."
  
  # Check if GitHub remote is properly configured
  if ! git remote -v | grep -q "^origin"; then
    print_Message "$Term_Red" "Error: GitHub remote not configured."
    return $Exit_Status_General
  fi
  
  # Check remote URL
  typeset RemoteUrl=$(git remote get-url origin)
  if [[ ! "$RemoteUrl" =~ github\.com ]]; then
    print_Message "$Term_Yellow" "Warning: Remote URL does not point to GitHub: $RemoteUrl"
  fi
  
  # Check if branches exist on GitHub
  print_Message "$Term_Blue" "Checking GitHub branches..."
  
  # Get GitHub username
  typeset GitHubUsername=$(run_GitHub_Command gh api user | jq -r '.login')
  
  # Check if repository exists
  if ! run_GitHub_Command gh repo view "$GitHubUsername/$RepoName" &>/dev/null; then
    print_Message "$Term_Red" "Error: Repository does not exist on GitHub: $GitHubUsername/$RepoName"
    return $Exit_Status_General
  fi
  
  # Check if main branch exists on GitHub
  if ! run_GitHub_Command gh api "/repos/$GitHubUsername/$RepoName/branches/main" &>/dev/null; then
    print_Message "$Term_Yellow" "Warning: Main branch does not exist on GitHub."
  else
    print_Message "$Term_Green" "Main branch verified on GitHub."
  fi
  
  print_Message "$Term_Green" "GitHub repository verification complete."
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: core_Logic
#----------------------------------------------------------------------#
# Description:
#   Main script workflow to create GitHub repository
# Parameters:
#   $1 - Repository name
#   $2 - Visibility (public or private)
# Returns:
#   Exit_Status_Success on success
#   Various error codes on failure
# Dependencies:
#   Calls validate_GitHub_Prerequisites and create_GitHub_Repository
#----------------------------------------------------------------------#
function core_Logic() {
  typeset RepoName="$1"
  typeset Visibility="$2"
  
  # Validate prerequisite 
  validate_GitHub_Prerequisites || return $?
  
  # Create GitHub repository and configure as remote
  create_GitHub_Repository "$RepoName" "$Visibility" || return $?
  
  # Display success message and next steps
  # Get GitHub username for the final success message
  typeset GitHubUsername=$(run_GitHub_Command gh api user | jq -r '.login')
  print_Message "$Term_Green" "GitHub remote repository setup complete!"
  print_Message "$Term_Blue" "GitHub Repository URL: https://github.com/$GitHubUsername/$RepoName"
  print_Message "$Term_Yellow" "Next steps:"
  
  # Check if we're in the scripts directory or at the root
  if [[ -d "$(dirname "$0")/scripts" ]]; then
    # We're at the root
    print_Message "$Term_Yellow" "Install bootstrap templates with: ./scripts/install_bootstrap_templates.sh $RepoName"
  else
    # We're in the scripts directory or the scripts are at the root
    typeset ScriptDir=$(dirname "$0")
    if [[ "$ScriptDir" == "." ]]; then
      # Scripts are at the root
      print_Message "$Term_Yellow" "Install bootstrap templates with: ./install_bootstrap_templates.sh $RepoName"
    else
      # We're in the scripts directory
      print_Message "$Term_Yellow" "Install bootstrap templates with: $ScriptDir/install_bootstrap_templates.sh $RepoName"
    fi
  fi
  
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
  # Validate input parameters
  if [[ -z "${1:-}" ]]; then
    print_Message "$Term_Red" "Error: Repository name is required."
    print_Message "$Term_Yellow" "Usage: $0 <repo-name> [public|private]"
    return $Exit_Status_Usage
  fi
  
  # Validate visibility parameter
  typeset Visibility="${2:-public}"  # Default to public if not specified (needed for branch protections)
  if [[ "$Visibility" != "public" && "$Visibility" != "private" ]]; then
    print_Message "$Term_Red" "Error: Visibility must be either 'public' or 'private'."
    print_Message "$Term_Yellow" "Usage: $0 <repo-name> [public|private]"
    return $Exit_Status_Usage
  fi
  
  # Return results as array
  print -- "$1 $Visibility"
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
  typeset RepoName Visibility
  
  # Parse command line parameters
  typeset ParseResults
  ParseResults=$(parse_Parameters "$@") || exit $?
  
  # Split results into variables
  RepoName=$(echo $ParseResults | cut -d' ' -f1)
  Visibility=$(echo $ParseResults | cut -d' ' -f2)
  
  # Execute core logic
  core_Logic "$RepoName" "$Visibility" || exit $?
  
  exit $Exit_Status_Success
}

# Execute only if run directly
if [[ "${(%):-%N}" == "$0" ]]; then
  main "$@"
fi