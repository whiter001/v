# Fork Synchronization Guide

## 如何保持Fork的master分支与上游仓库同步

If you have forked the V repository, you'll want to keep your fork's `master` branch synchronized with the upstream V repository to get the latest updates and fixes.

## Quick Setup

### 1. Add Upstream Remote

First, add the original V repository as an upstream remote:

```bash
git remote add upstream https://github.com/vlang/v.git
```

Verify your remotes:
```bash
git remote -v
```

You should see:
```
origin    https://github.com/YOUR_USERNAME/v.git (fetch)
origin    https://github.com/YOUR_USERNAME/v.git (push)
upstream  https://github.com/vlang/v.git (fetch)
upstream  https://github.com/vlang/v.git (push)
```

### 2. Sync Your Fork

To sync your fork's master branch with upstream:

```bash
# Switch to master branch
git checkout master

# Fetch latest changes from upstream
git fetch upstream

# Merge upstream changes into your master
git merge upstream/master

# Push the updated master to your fork
git push origin master
```

### 3. Alternative: Rebase Method

For a cleaner history, you can use rebase instead of merge:

```bash
# Switch to master branch
git checkout master

# Fetch and rebase
git pull --rebase upstream master

# Push to your fork
git push origin master
```

## Automated Synchronization

### Using the V Up Tool

The existing `v up` command automatically pulls from the upstream V repository, but it pulls directly from `vlang/v`. This is suitable for most users who want to update their V installation.

### Creating a Sync Script

For convenience, you can create a script to automate the sync process:

```bash
#!/bin/bash
# save as sync_fork.sh

echo "Syncing fork with upstream..."

# Ensure we're in the right directory
if [ ! -d ".git" ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Check if upstream remote exists
if ! git remote | grep -q "upstream"; then
    echo "Adding upstream remote..."
    git remote add upstream https://github.com/vlang/v.git
fi

# Switch to master
git checkout master

# Fetch from upstream
echo "Fetching from upstream..."
git fetch upstream

# Check if there are any uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Warning: You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

# Merge upstream changes
echo "Merging upstream changes..."
git merge upstream/master

# Push to origin
echo "Pushing to your fork..."
git push origin master

echo "Fork synchronization complete!"
```

Make it executable:
```bash
chmod +x sync_fork.sh
```

## Best Practices

### 1. Regular Synchronization

Sync your fork regularly to avoid large merge conflicts:
- Daily if you're actively developing
- Before starting new features
- Before creating pull requests

### 2. Working with Feature Branches

Never work directly on the master branch. Always create feature branches:

```bash
# After syncing master
git checkout master
git pull --rebase upstream master

# Create feature branch
git checkout -b feature/my-new-feature

# Work on your feature...
# When ready to contribute:
git push origin feature/my-new-feature
```

### 3. Handling Merge Conflicts

If you encounter merge conflicts during sync:

```bash
# Fix conflicts in the affected files
# Then:
git add .
git commit -m "Resolve merge conflicts with upstream"
git push origin master
```

## Troubleshooting

### Permission Denied

If you get permission errors when pushing:
- Make sure you have write access to your fork
- Check your SSH keys or GitHub token

### Diverged Branches

If your master has diverged significantly from upstream:

```bash
# Force sync (WARNING: This will lose any commits on master that aren't upstream)
git checkout master
git fetch upstream
git reset --hard upstream/master
git push --force-with-lease origin master
```

### Behind Upstream

If your master is behind upstream:

```bash
git checkout master
git pull upstream master
git push origin master
```

## Related Commands

- `v up` - Updates V installation from upstream
- `git status` - Check repository status
- `git log --oneline upstream/master..master` - See commits in your master not in upstream
- `git log --oneline master..upstream/master` - See commits in upstream not in your master

## See Also

- [CONTRIBUTING.md](CONTRIBUTING.md) - General contribution guidelines
- [GitHub Fork Documentation](https://docs.github.com/en/get-started/quickstart/fork-a-repo)