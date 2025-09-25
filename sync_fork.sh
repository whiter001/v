#!/bin/bash
# sync_fork.sh - Synchronize fork with upstream V repository
# Usage: ./sync_fork.sh

set -e

echo "🔄 Syncing fork with upstream V repository..."

# Ensure we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check if upstream remote exists, if not add it
if ! git remote | grep -q "upstream"; then
    echo "➕ Adding upstream remote..."
    git remote add upstream https://github.com/vlang/v.git
    echo "✅ Added upstream remote"
fi

# Get current branch
current_branch=$(git branch --show-current)

# Stash any uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "💾 Stashing uncommitted changes..."
    git stash push -m "sync_fork.sh auto-stash $(date)"
    stashed=true
else
    stashed=false
fi

# Switch to master
echo "🔀 Switching to master branch..."
git checkout master

# Fetch from upstream
echo "📥 Fetching from upstream..."
git fetch upstream

# Check if master has diverged from upstream
ahead_count=$(git rev-list --count upstream/master..master)
behind_count=$(git rev-list --count master..upstream/master)

if [ "$ahead_count" -gt 0 ] && [ "$behind_count" -gt 0 ]; then
    echo "⚠️  Warning: Your master branch has diverged from upstream"
    echo "   Your master: $ahead_count commits ahead"
    echo "   Upstream: $behind_count commits ahead"
    echo "   Consider creating a backup branch before proceeding"
    read -p "Continue with merge? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Sync cancelled"
        exit 1
    fi
fi

# Merge upstream changes
echo "🔀 Merging upstream changes..."
if git merge upstream/master --no-edit; then
    echo "✅ Successfully merged upstream changes"
else
    echo "❌ Merge conflicts detected. Please resolve them manually:"
    echo "   1. Fix conflicts in the affected files"
    echo "   2. Run: git add ."
    echo "   3. Run: git commit"
    echo "   4. Run: git push origin master"
    exit 1
fi

# Push to origin
echo "📤 Pushing to your fork..."
if git push origin master; then
    echo "✅ Successfully pushed to fork"
else
    echo "❌ Failed to push to fork. You may need to force push if your master has diverged:"
    echo "   git push --force-with-lease origin master"
    exit 1
fi

# Switch back to original branch if it wasn't master
if [ "$current_branch" != "master" ]; then
    echo "🔀 Switching back to $current_branch branch..."
    git checkout "$current_branch"
fi

# Restore stashed changes
if [ "$stashed" = true ]; then
    echo "📂 Restoring stashed changes..."
    git stash pop
fi

echo "🎉 Fork synchronization complete!"
echo "📊 Summary:"
echo "   - Fetched latest changes from upstream"
echo "   - Merged $behind_count commits from upstream"
echo "   - Pushed updates to your fork"