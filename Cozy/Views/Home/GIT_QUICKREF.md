# Git Command Quick Reference

## 🚀 Daily Workflow

```bash
# 1. Check status
git status

# 2. Add changes
git add .

# 3. Commit
git commit -m "Your message"

# 4. Push to GitHub
git push
```

## 📂 Starting a New Project

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/USERNAME/REPO.git
git push -u origin main
```

## 🌿 Branching

```bash
# Create and switch to new branch
git checkout -b feature/new-feature

# Switch branches
git checkout main

# Merge branch into current branch
git merge feature/new-feature

# Delete branch
git branch -d feature/new-feature
```

## 🔄 Syncing

```bash
# Get latest changes
git pull

# Push your changes
git push

# Fetch without merging
git fetch
```

## ↩️ Undoing

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Discard changes to a file
git checkout -- filename.swift

# Unstage file
git reset HEAD filename.swift
```

## 📜 Viewing History

```bash
# Short log
git log --oneline

# Detailed log
git log

# See changes in a file
git diff filename.swift

# See what changed in last commit
git show
```

## 🏷️ Tags

```bash
# Create tag
git tag -a v1.0.0 -m "Version 1.0.0"

# Push tags
git push --tags

# List tags
git tag
```

## 🔍 Helpful Commands

```bash
# See remote URL
git remote -v

# See all branches
git branch -a

# Clean up deleted remote branches
git fetch --prune

# Stash changes temporarily
git stash
git stash pop  # Restore stashed changes
```

## 🆘 Emergency Fixes

```bash
# Forgot to switch branch before changes
git stash
git checkout correct-branch
git stash pop

# Wrong commit message
git commit --amend -m "Correct message"

# Forgot to add file to last commit
git add forgotten-file.swift
git commit --amend --no-edit
```

---

**Remember:** 
- Commit early, commit often
- Write clear commit messages
- Pull before you push
- Use branches for new features
