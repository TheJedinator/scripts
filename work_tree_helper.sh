#!/bin/sh

# worktree_helper.sh - Create a Git worktree and copy/symlink important files

set -e # Exit on error

# Default values
COPY_MODE="copy" # Options: "copy" or "symlink"
BRANCH_NAME=""
DEFAULT_ITEMS=".venv .claude .cursor .vscode CLAUDE.md claude.local.json node_modules"

# Help function
show_help() {
  echo "Usage: $0 [options] <worktree-path>"
  echo "Options:"
  echo "  -b, --branch <branch-name>   Create worktree for specific branch (default: current branch)"
  echo "  -c, --copy                   Copy files instead of creating symlinks"
  echo "  -s, --symlink                Create symlinks (default)"
  echo "  -i, --items <file1,file2>    Comma-separated list of files/folders to transfer"
  echo "  -h, --help                   Show this help message"
  echo ""
  echo "Default items: $DEFAULT_ITEMS"
  exit 0
}

# Parse arguments
while [ $# -gt 0 ]; do
  case $1 in
  -b | --branch)
    BRANCH_NAME="$2"
    shift 2
    ;;
  -c | --copy)
    COPY_MODE="copy"
    shift
    ;;
  -s | --symlink)
    COPY_MODE="symlink"
    shift
    ;;
  -i | --items)
    ITEMS_TO_TRANSFER=$(echo "$2" | tr ',' ' ')
    shift 2
    ;;
  -h | --help)
    show_help
    ;;
  *)
    WORKTREE_PATH="$1"
    shift
    ;;
  esac
done

# Use default items if none specified
if [ -z "$ITEMS_TO_TRANSFER" ]; then
  ITEMS_TO_TRANSFER="$DEFAULT_ITEMS"
fi

# Check if worktree path is provided
if [ -z "$WORKTREE_PATH" ]; then

  echo "Error: Worktree path is required"
  show_help
fi

# Get the absolute path of the current directory
PARENT_DIR="$(pwd)"

# Get the git repository root directory
GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$GIT_ROOT" ]; then
  echo "Error: Not in a git repository"
  exit 1
fi

# Resolve the worktree path to absolute path
# Handle both relative and absolute paths
case "$WORKTREE_PATH" in
  /*)
    # Already absolute path
    WORKTREE_RESOLVED="$WORKTREE_PATH"
    ;;
  *)
    # Relative path - resolve it relative to current directory
    WORKTREE_RESOLVED="$PARENT_DIR/$WORKTREE_PATH"
    ;;
esac

# Normalize paths by removing trailing slashes for comparison
GIT_ROOT_NORMALIZED="${GIT_ROOT%/}"
WORKTREE_RESOLVED_NORMALIZED="${WORKTREE_RESOLVED%/}"

# Check if worktree path would be inside the git repository
# This checks if the worktree path starts with the git root path
case "$WORKTREE_RESOLVED_NORMALIZED" in
  "$GIT_ROOT_NORMALIZED" | "$GIT_ROOT_NORMALIZED"/*)
    echo "Error: Cannot create worktree inside the git repository"
    echo "  Git repository root: $GIT_ROOT"
    echo "  Worktree path: $WORKTREE_PATH (resolves to $WORKTREE_RESOLVED)"
    echo ""
    echo "Worktrees should be created outside the main repository."
    echo "For example: ../$WORKTREE_PATH or /tmp/$WORKTREE_PATH"
    exit 1
    ;;
esac

# Also check if it's just "." or empty which means current directory
if [ "$WORKTREE_PATH" = "." ] || [ "$WORKTREE_PATH" = "./" ] || [ -z "$WORKTREE_PATH" ]; then
  echo "Error: Cannot create worktree in the current directory"
  echo "Please specify a different path for the worktree"
  exit 1
fi

# Create the worktree
if [ -z "$BRANCH_NAME" ]; then
  echo "Creating worktree at $WORKTREE_PATH (using current branch)..."
  git worktree add "$WORKTREE_PATH"
else
  echo "Creating worktree at $WORKTREE_PATH for branch $BRANCH_NAME..."
  git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH"
fi

# Get the absolute path of the new worktree
WORKTREE_ABSOLUTE_PATH="$(cd "$WORKTREE_PATH" && pwd)"

echo "Worktree created successfully at $WORKTREE_ABSOLUTE_PATH"

# Transfer files/folders
if [ -z "$ITEMS_TO_TRANSFER" ]; then
  echo "No files/folders specified for transfer."
else
  echo "Transferring files/folders to worktree..."

  for item in $ITEMS_TO_TRANSFER; do
    if [ -e "$PARENT_DIR/$item" ]; then
      if [ "$COPY_MODE" = "copy" ]; then
        echo "Copying $item..."
        if [ -d "$PARENT_DIR/$item" ]; then
          cp -r "$PARENT_DIR/$item" "$WORKTREE_ABSOLUTE_PATH/"
        else
          cp "$PARENT_DIR/$item" "$WORKTREE_ABSOLUTE_PATH/"
        fi
      else
        echo "Creating symlink for $item..."
        if [ -d "$WORKTREE_ABSOLUTE_PATH/$item" ]; then
          # Remove the directory if it already exists
          rm -rf "$WORKTREE_ABSOLUTE_PATH/$item"
        fi
        ln -s "$PARENT_DIR/$item" "$WORKTREE_ABSOLUTE_PATH/$item"
      fi
    else
      echo "Warning: $PARENT_DIR/$item not found in parent directory, skipping"
    fi
  done
fi

echo "Done! Your worktree is ready at $WORKTREE_ABSOLUTE_PATH"

# Add your custom post-worktree commands here
# For example:
# cd "$WORKTREE_ABSOLUTE_PATH" && npm install

exit 0
