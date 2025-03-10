#!/usr/bin/env zsh
########################################################################
## Script:        setup_local_git_inception.sh
## Version:       0.1.0 (2025-03-07)
## Origin:        https://github.com/ChristopherA/Claude-Code-Bootstrap/blob/main/scripts/setup_local_git_inception.sh
## Description:   Sets up a local Git repository with proper SSH signing configuration
##                and creates an empty inception commit to establish a SHA-1 root of trust.
## License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
## Copyright:     (c) 2025 @ChristopherA
## Attribution:   Authored by @ChristopherA
## Usage:         setup_local_git_inception.sh <repo-name>
## Examples:      setup_local_git_inception.sh my-project
##                setup_local_git_inception.sh ~/path/to/my-project
## Dependencies:  git, ssh-keygen
## Requirements:  Git 2.34.0+ for SSH signing, Ed25519 SSH key for secure signing
##                SSH key must be configured in git with user.signingkey
##                SSH key must be authorized in allowed_signers file for signing
## Security:      Creates a secure inception commit using Ed25519 SSH signing key.
##                This establishes a cryptographic root of trust for the repository.
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
#   Validates that all required tools and configurations are available
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
  
  # Check git version (needs 2.34.0+ for SSH signing)
  typeset GitVersion=$(git --version | awk '{print $3}')
  if ! [[ $(echo "$GitVersion 2.34.0" | awk '{print ($1 >= $2)}') -eq 1 ]]; then
    print_Message "$Term_Red" "Error: git version $GitVersion is too old. Version 2.34.0 or newer is required for SSH signing."
    return $Exit_Status_Config
  fi
  
  # Check git user configuration
  if [[ -z "$(git config --get user.name)" ]]; then
    print_Message "$Term_Red" "Error: git user.name is not configured."
    print_Message "$Term_Yellow" "Please set it with: git config --global user.name \"Your Name\""
    return $Exit_Status_Config
  fi
  
  if [[ -z "$(git config --get user.email)" ]]; then
    print_Message "$Term_Red" "Error: git user.email is not configured."
    print_Message "$Term_Yellow" "Please set it with: git config --global user.email \"your.email@example.com\""
    return $Exit_Status_Config
  fi

  # Check for existing SSH signing key configuration
  typeset ExistingSigningKey=$(git config --get user.signingkey)
  
  if [[ -n "$ExistingSigningKey" && -f "$ExistingSigningKey" ]]; then
    print_Message "$Term_Green" "Found existing SSH signing key: $ExistingSigningKey"
  # Fall back to checking for standard Ed25519 key
  elif [[ -f ~/.ssh/id_ed25519 ]]; then
    print_Message "$Term_Green" "Found standard Ed25519 key at ~/.ssh/id_ed25519"
  else
    print_Message "$Term_Red" "Error: No SSH signing key found"
    print_Message "$Term_Yellow" "Either:"
    print_Message "$Term_Yellow" "1. Configure git with an existing SSH key: git config --global user.signingkey /path/to/your/key"
    print_Message "$Term_Yellow" "2. Generate a new Ed25519 key: ssh-keygen -t ed25519 -C \"your_email@example.com\""
    print_Message "$Term_Yellow" "For security best practices, we strongly recommend using Ed25519 keys."
    return $Exit_Status_Config
  fi
  
  # Check SSH signing configuration
  if [[ "$(git config --get --global gpg.format)" != "ssh" ]]; then
    print_Message "$Term_Yellow" "Warning: Git is not configured to use SSH for signing."
    print_Message "$Term_Yellow" "Will configure git for SSH signing during setup."
  fi
  
  # Check specifically for Ed25519 key in git config
  typeset SigningKey=$(git config --get --global user.signingkey)
  if [[ -z "$SigningKey" || "$SigningKey" != *"id_ed25519"* ]]; then
    print_Message "$Term_Yellow" "Warning: Git signing key is not set to your Ed25519 key."
    print_Message "$Term_Yellow" "Will configure signing key during setup."
  fi
  
  if [[ -z "$(git config --get --global gpg.ssh.allowedSignersFile)" ]]; then
    print_Message "$Term_Yellow" "Warning: Git allowed signers file is not configured."
    print_Message "$Term_Yellow" "Will configure allowed signers file during setup."
  fi
  
  if [[ "$(git config --get --global commit.gpgsign)" != "true" ]]; then
    print_Message "$Term_Yellow" "Warning: Git is not configured to sign commits by default."
    print_Message "$Term_Yellow" "Will enable commit signing during setup."
  fi

  print_Message "$Term_Green" "All prerequisites validated successfully."
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: configure_Git_Signing
#----------------------------------------------------------------------#
# Description:
#   Configures Git for SSH signing with proper key configuration
# Parameters:
#   None
# Returns:
#   Exit_Status_Success on success
#   Various error codes on failure
# Dependencies:
#   None
#----------------------------------------------------------------------#
function configure_Git_Signing() {
  print_Message "$Term_Blue" "Configuring git for SSH signing..."

  # Check for existing SSH signing key configuration
  typeset SshKeyPath=$(git config --get user.signingkey)
  
  # If no existing key is configured, try to find an Ed25519 key
  if [[ -z "$SshKeyPath" || ! -f "$SshKeyPath" ]]; then
    if [[ -f ~/.ssh/id_ed25519 ]]; then
      # Use standard Ed25519 key location
      SshKeyPath=~/.ssh/id_ed25519
    else
      # Search for any Ed25519 key in the ~/.ssh directory
      typeset PotentialKey=$(find ~/.ssh -type f -name "*ed25519*" | grep -v "\.pub$" | head -1)
      if [[ -n "$PotentialKey" ]]; then
        SshKeyPath="$PotentialKey"
      else
        print_Message "$Term_Red" "Error: No SSH signing key found"
        print_Message "$Term_Yellow" "Please generate a key with: ssh-keygen -t ed25519 -C \"your.email@example.com\""
        return $Exit_Status_Config
      fi
    fi
  fi
  
  print_Message "$Term_Green" "Using SSH key for signing: $SshKeyPath"

  # Configure git for SSH signing
  git config --global gpg.format ssh
  git config --global user.signingkey "$SshKeyPath"
  git config --global commit.gpgsign true

  # Create allowed signers file if it doesn't exist
  typeset AllowedSignersDir=~/.config/git
  typeset AllowedSignersFile="$AllowedSignersDir/allowed_signers"
  
  if [[ ! -d "$AllowedSignersDir" ]]; then
    mkdir -p "$AllowedSignersDir"
    chmod 700 "$AllowedSignersDir"
  fi
  
  # Get user email from git config
  typeset UserEmail=$(git config --global user.email)
  typeset UserName=$(git config --global user.name)
  
  if [[ -z "$UserEmail" || -z "$UserName" ]]; then
    print_Message "$Term_Red" "Error: git user.email or user.name not configured."
    print_Message "$Term_Yellow" "Please set them with:"
    print_Message "$Term_Yellow" "  git config --global user.email \"your.email@example.com\""
    print_Message "$Term_Yellow" "  git config --global user.name \"Your Name\""
    return $Exit_Status_Config
  fi
  
  # Create or update allowed signers file
  print_Message "$Term_Blue" "Setting up allowed signers file at $AllowedSignersFile..."
  
  # Write to allowed signers file with proper format (email followed by key)
  # Get the corresponding public key path
  typeset PubKeyPath=""
  if [[ "$SshKeyPath" == *".pub" ]]; then
    # If somehow the signing key was set to the public key, use it
    PubKeyPath="$SshKeyPath"
  elif [[ -f "${SshKeyPath}.pub" ]]; then
    # Standard format: private key + .pub
    PubKeyPath="${SshKeyPath}.pub"
  else
    # Try to find the corresponding public key
    PubKeyPath=$(echo "$SshKeyPath" | sed 's/\.[^.]*$/.pub/')
    if [[ ! -f "$PubKeyPath" ]]; then
      # Last resort: search for public keys matching the pattern
      typeset BaseName=$(basename "$SshKeyPath")
      typeset DirName=$(dirname "$SshKeyPath")
      PubKeyPath=$(find "$DirName" -type f -name "${BaseName}*.pub" | head -1)
    fi
  fi
  
  if [[ -z "$PubKeyPath" || ! -f "$PubKeyPath" ]]; then
    print_Message "$Term_Yellow" "Warning: Could not find public key for $SshKeyPath"
    print_Message "$Term_Yellow" "Will try to use existing allowed_signers file if available"
    
    if [[ -f "$AllowedSignersFile" ]]; then
      print_Message "$Term_Green" "Using existing allowed_signers file: $AllowedSignersFile"
    else
      print_Message "$Term_Red" "Error: No allowed_signers file exists and could not create one"
      print_Message "$Term_Yellow" "Please manually create $AllowedSignersFile with format: \"$UserEmail ssh-ed25519 AAAA...\""
      return $Exit_Status_Config
    fi
  else
    print_Message "$Term_Green" "Using public key for allowed signers: $PubKeyPath"
    echo -n "$UserEmail " > "$AllowedSignersFile"
    cat "$PubKeyPath" >> "$AllowedSignersFile"
    chmod 600 "$AllowedSignersFile"
  fi
  
  # Configure git to use the allowed signers file
  git config --global gpg.ssh.allowedSignersFile "$AllowedSignersFile"

  # Verify configuration
  print_Message "$Term_Blue" "Verifying SSH signing configuration..."
  if [[ "$(git config --get --global gpg.format)" == "ssh" && \
        "$(git config --get --global user.signingkey)" == "$SshKeyPath" && \
        "$(git config --get --global commit.gpgsign)" == "true" && \
        "$(git config --get --global gpg.ssh.allowedSignersFile)" == "$AllowedSignersFile" ]]; then
    print_Message "$Term_Green" "Git configured successfully for SSH signing."
  else
    print_Message "$Term_Yellow" "Warning: Some git configuration settings may not have been applied correctly."
    print_Message "$Term_Yellow" "Please verify your git configuration with 'git config --global --list | grep gpg'"
  fi
  
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: create_Local_Repo
#----------------------------------------------------------------------#
# Description:
#   Creates and initializes a local Git repository with proper structure
# Parameters:
#   $1 - Repository name
#   $2 - Repository directory path
# Returns:
#   Exit_Status_Success on success
#   Various error codes on failure
# Dependencies:
#   Requires git command
#----------------------------------------------------------------------#
function create_Local_Repo() {
  typeset RepoName="$1"
  typeset RepoDir="$2"
  
  print_Message "$Term_Blue" "Creating local repository: $RepoName..."
  
  # Create directory if it doesn't exist
  if [[ ! -d "$RepoDir" ]]; then
    mkdir -p "$RepoDir"
  fi
  
  # Initialize git repository
  cd "$RepoDir"
  git init --initial-branch=main
  
  # Get signing key and author information
  typeset SigningKey=$(git config --get user.signingkey)
  typeset GitAuthorName=$(git config --get user.name)
  typeset GitAuthorEmail=$(git config --get user.email)
  typeset GitAuthorDate=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  # Get key fingerprint for committer name
  typeset GitCommitterName=$(ssh-keygen -E sha256 -lf "$SigningKey" | awk '{print $2}')
  typeset GitCommitterEmail="$GitAuthorEmail"
  typeset GitCommitterDate="$GitAuthorDate"
  
  # Create EMPTY inception commit with specialized format (no files)
  print_Message "$Term_Blue" "Creating empty inception commit with SHA-1 root of trust..."
  env GIT_AUTHOR_NAME="$GitAuthorName" GIT_AUTHOR_EMAIL="$GitAuthorEmail" \
      GIT_COMMITTER_NAME="$GitCommitterName" GIT_COMMITTER_EMAIL="$GitCommitterEmail" \
      GIT_AUTHOR_DATE="$GitAuthorDate" GIT_COMMITTER_DATE="$GitCommitterDate" \
      git -c gpg.format=ssh -c user.signingkey="$SigningKey" \
        commit --allow-empty --no-edit --gpg-sign \
        -m "Initialize repository and establish a SHA-1 root of trust" \
        -m "This key also certifies future commits' integrity and origin. Other keys can be authorized to add additional commits via the creation of a ./.repo/config/verification/allowed_commit_signers file. This file must initially be signed by this repo's inception key, granting these keys the authority to add future commits to this repo, including the potential to remove the authority of this inception key for future commits. Once established, any changes to ./.repo/config/verification/allowed_commit_signers must be authorized by one of the previously approved signers." --signoff
  
  # Verify the inception commit succeeded
  if [[ $? -eq 0 ]]; then
    print_Message "$Term_Green" "Empty inception commit created successfully."
    # Create the .repo/config/verification directory
    mkdir -p ./.repo/config/verification
    chmod -R 755 ./.repo
  else
    print_Message "$Term_Red" "Error: Failed to create empty inception commit. Check Git configuration."
    return $Exit_Status_Git_Failure
  fi
  
  # Verify the inception commit
  verify_Inception_Commit || {
    print_Message "$Term_Yellow" "Warning: Inception commit verification failed. Continuing anyway..."
  }

  print_Message "$Term_Green" "Local repository created successfully."
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: verify_Inception_Commit
#----------------------------------------------------------------------#
# Description:
#   Performs a quick verification of the inception commit to ensure
#   it meets basic Open Integrity requirements
# Parameters:
#   None - Checks the current repository
# Returns:
#   Exit_Status_Success if the commit is valid
#   Exit_Status_Git_Failure if any checks fail
# Dependencies:
#   Requires git command
#----------------------------------------------------------------------#
function verify_Inception_Commit() {
  typeset -i VerificationStatus=1  # 1 = true, 0 = false
  
  print_Message "$Term_Blue" "Verifying inception commit..."
  
  # Find the inception commit (first commit)
  typeset InceptionCommitId
  InceptionCommitId=$(git rev-list --max-parents=0 HEAD 2>/dev/null) || {
    print_Message "$Term_Red" "❌ No inception commit found"
    return $Exit_Status_Git_Failure
  }
  
  print_Message "$Term_Green" "✅ Found inception commit: $InceptionCommitId"
  
  # Step 1: Check if the commit is empty (has no files)
  typeset TreeHash
  TreeHash=$(git cat-file -p "$InceptionCommitId" | awk '/^tree / {print $2}')
  
  typeset EmptyTreeHash
  EmptyTreeHash=$(git hash-object -t tree /dev/null)
  
  if [[ "$TreeHash" != "$EmptyTreeHash" ]]; then
    print_Message "$Term_Red" "❌ Inception commit is not empty"
    VerificationStatus=0
  else
    print_Message "$Term_Green" "✅ Inception commit is properly empty"
  fi
  
  # Step 2: Check if the commit message has the required text
  typeset CommitMessage
  CommitMessage=$(git log "$InceptionCommitId" -1 --pretty=%B)
  
  if ! echo "$CommitMessage" | grep -q "Initialize repository and establish a SHA-1 root of trust"; then
    print_Message "$Term_Red" "❌ Inception commit missing required initialization message"
    VerificationStatus=0
  else
    print_Message "$Term_Green" "✅ Inception commit has proper message format"
  fi
  
  # Step 3: Check if the commit is signed with SSH
  if ! git verify-commit "$InceptionCommitId" &>/dev/null; then
    print_Message "$Term_Red" "❌ Inception commit signature verification failed"
    VerificationStatus=0
  else
    print_Message "$Term_Green" "✅ Inception commit has valid signature"
  fi
  
  # Step 4: Check committer name format (should be the key fingerprint)
  typeset CommitterName
  CommitterName=$(git log "$InceptionCommitId" -1 --pretty=%cn)
  
  if [[ ! "$CommitterName" =~ ^SHA256: ]]; then
    print_Message "$Term_Yellow" "⚠️ Committer name is not in fingerprint format: $CommitterName"
    # This is only a warning, not a failure
  else
    print_Message "$Term_Green" "✅ Committer name is in fingerprint format"
  fi
  
  # Step 5: Check for signoff
  if ! echo "$CommitMessage" | grep -q "^Signed-off-by:"; then
    print_Message "$Term_Red" "❌ Inception commit missing sign-off"
    VerificationStatus=0
  else
    print_Message "$Term_Green" "✅ Inception commit has proper sign-off"
  fi
  
  # Generate repository DID
  typeset RepoDID="did:repo:$InceptionCommitId"
  print_Message "$Term_Blue" "Repository DID: $RepoDID"
  
  # Overall verification status
  if [[ $VerificationStatus -eq 1 ]]; then
    print_Message "$Term_Green" "✅ Inception commit verification passed"
    return $Exit_Status_Success
  else
    print_Message "$Term_Red" "❌ Inception commit verification failed"
    return $Exit_Status_Git_Failure
  fi
}

#----------------------------------------------------------------------#
# Function: core_Logic
#----------------------------------------------------------------------#
# Description:
#   Main script workflow to set up the Git repository with proper signing
# Parameters:
#   $1 - Repository name
# Returns:
#   Exit_Status_Success on success
#   Various error codes on failure
# Dependencies:
#   Calls validate_Prerequisites, configure_Git_Signing, and create_Local_Repo
#----------------------------------------------------------------------#
function core_Logic() {
  typeset RepoName="$1"
  
  # Determine repository directory path
  typeset RepoDir
  typeset CurrentBasename=$(basename "$PWD")
  
  if [[ "$RepoName" == "." || "$RepoName" == "$PWD" || "$RepoName" == "$CurrentBasename" ]]; then
    # Special case: initialize the current directory
    RepoDir="$PWD"
    RepoName="$CurrentBasename"
  elif [[ "$RepoName" == /* ]]; then
    # If an absolute path is provided, use it directly
    RepoDir="$RepoName"
  else
    # If a relative path or just a name, use it as a subdirectory of current dir
    RepoDir="$PWD/$RepoName"
  fi
  
  # Validate prerequisites 
  validate_Prerequisites || return $?
  
  # Configure git for SSH signing
  configure_Git_Signing || return $?
  
  # Create local repository
  create_Local_Repo "$RepoName" "$RepoDir" || return $?
  
  # Display success message
  print_Message "$Term_Green" "Local repository setup complete!"
  print_Message "$Term_Blue" "Repository Directory: $RepoDir"
  print_Message "$Term_Yellow" "Next steps:"
  # Check if we're in the scripts directory or at the root
  if [[ -d "$(dirname "$0")/scripts" ]]; then
    # We're at the root
    print_Message "$Term_Yellow" "1. Create GitHub repository with: ./scripts/create_github_remote.sh $RepoName"
    print_Message "$Term_Yellow" "2. Push local repository to GitHub"
    print_Message "$Term_Yellow" "3. Add bootstrap files with: ./scripts/install_bootstrap_templates.sh $RepoName"
  else
    # We're in the scripts directory or the scripts are at the root
    typeset ScriptDir=$(dirname "$0")
    if [[ "$ScriptDir" == "." ]]; then
      # Scripts are at the root
      print_Message "$Term_Yellow" "1. Create GitHub repository with: ./create_github_remote.sh $RepoName"
      print_Message "$Term_Yellow" "2. Push local repository to GitHub"
      print_Message "$Term_Yellow" "3. Add bootstrap files with: ./install_bootstrap_templates.sh $RepoName"
    else
      # We're in the scripts directory
      print_Message "$Term_Yellow" "1. Create GitHub repository with: $ScriptDir/create_github_remote.sh $RepoName"
      print_Message "$Term_Yellow" "2. Push local repository to GitHub"
      print_Message "$Term_Yellow" "3. Add bootstrap files with: $ScriptDir/install_bootstrap_templates.sh $RepoName"
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
    print_Message "$Term_Yellow" "Usage: $0 <repo-name>"
    return $Exit_Status_Usage
  fi
  
  # Return the repository name (validation is done in core_Logic)
  print -- "$1"
  return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: main
#----------------------------------------------------------------------#
# Description:
#   Main script entry point that processes arguments and executes core logic
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Various exit status codes
# Dependencies:
#   Calls parse_Parameters and core_Logic
#----------------------------------------------------------------------#
function main() {
  typeset RepoName
  
  # Parse command line parameters
  RepoName=$(parse_Parameters "$@") || exit $?
  
  # Execute core logic
  core_Logic "$RepoName" || exit $?
  
  exit $Exit_Status_Success
}

# Execute only if run directly
if [[ "${(%):-%N}" == "$0" ]]; then
  main "$@"
fi