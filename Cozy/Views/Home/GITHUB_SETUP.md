# GitHub Setup Guide for Cozy Chores

## 🎯 Quick Start (5 Minutes)

### Step 1: Create a GitHub Repository

1. Go to [github.com](https://github.com) and sign in
2. Click the **+** button (top right) → **New repository**
3. Fill in:
   - **Repository name**: `cozy-chores`
   - **Description**: "A warm, empathy-first chore management app for iOS"
   - **Visibility**: Choose Public or Private
   - **DO NOT** check "Add a README" (we already have one)
   - **DO NOT** add .gitignore (we already have one)
4. Click **Create repository**

### Step 2: Initialize Git in Your Xcode Project

Open **Terminal** and navigate to your project folder:

```bash
cd /path/to/your/CozyChores
```

Then run these commands:

```bash
# Initialize git repository
git init

# Add all files
git add .

# Create your first commit
git commit -m "Initial commit: Cozy Chores app with mood-based UI and preset library"

# Set main branch
git branch -M main

# Connect to GitHub (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/cozy-chores.git

# Push to GitHub
git push -u origin main
```

### Step 3: Verify Upload

1. Go back to your GitHub repository page
2. Refresh the page
3. You should see all your files uploaded!

---

## 🔐 Using SSH (Recommended for Security)

If you want to use SSH instead of HTTPS:

### 1. Generate SSH Key (if you don't have one)

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Press Enter to accept default file location, then enter a passphrase.

### 2. Add SSH Key to GitHub

```bash
# Copy your public key to clipboard (macOS)
pbcopy < ~/.ssh/id_ed25519.pub
```

Then:
1. Go to GitHub → Settings → SSH and GPG keys
2. Click "New SSH key"
3. Paste your key and save

### 3. Change Remote to SSH

```bash
git remote set-url origin git@github.com:YOUR_USERNAME/cozy-chores.git
```

---

## 📦 Useful Git Commands for Daily Work

### Making Changes

```bash
# See what files changed
git status

# Add specific files
git add DashboardView.swift ChoresView.swift

# Or add all changes
git add .

# Commit with a descriptive message
git commit -m "Add Browse Chore Library feature"

# Push to GitHub
git push
```

### Viewing History

```bash
# See commit history
git log --oneline

# See what changed in a file
git diff DashboardView.swift
```

### Branching (for new features)

```bash
# Create a new branch
git checkout -b feature/calendar-improvements

# Work on your feature, commit changes
git add .
git commit -m "Improve calendar UI"

# Push branch to GitHub
git push -u origin feature/calendar-improvements

# Switch back to main
git checkout main

# Merge feature into main
git merge feature/calendar-improvements
```

### Undoing Mistakes

```bash
# Undo last commit (keeps changes)
git reset --soft HEAD~1

# Discard uncommitted changes
git checkout -- DashboardView.swift

# Unstage files
git reset HEAD DashboardView.swift
```

---

## 🏷️ Tagging Releases

When you're ready to mark a version:

```bash
# Create a tag
git tag -a v1.0.0 -m "First release: Mood-based dashboard and preset library"

# Push tags to GitHub
git push --tags
```

---

## 📝 Commit Message Best Practices

Use clear, descriptive messages:

**Good:**
```bash
git commit -m "Add mood-based filtering to dashboard"
git commit -m "Fix: Chore library showing wrong room count"
git commit -m "Refactor: Extract mood logic into separate enum"
```

**Bad:**
```bash
git commit -m "Updates"
git commit -m "Fix stuff"
git commit -m "asdf"
```

### Conventional Commits Format

```bash
feat: Add new feature
fix: Fix a bug
docs: Update documentation
style: Format code (no logic change)
refactor: Restructure code without changing behavior
test: Add or update tests
chore: Update build process, dependencies, etc.
```

**Examples:**
```bash
git commit -m "feat: Add Browse Chore Library screen"
git commit -m "fix: Dashboard crash when no chores exist"
git commit -m "docs: Update README with setup instructions"
```

---

## 🔄 Keeping Your Repo Updated

### Pulling Changes (if working from multiple computers)

```bash
# Get latest changes from GitHub
git pull origin main
```

### Resolving Merge Conflicts

If you see a merge conflict:

1. Open the conflicted file in Xcode
2. Look for conflict markers:
```
<<<<<<< HEAD
Your code
=======
Incoming code
>>>>>>> branch-name
```
3. Edit to keep what you want
4. Remove the conflict markers
5. Save and commit:
```bash
git add .
git commit -m "Resolve merge conflict in DashboardView"
git push
```

---

## 🚀 GitHub Features to Use

### 1. **Issues** - Track bugs and features
- Go to your repo → Issues → New Issue
- Use labels: bug, enhancement, question, etc.

### 2. **Projects** - Organize work
- Go to Projects → New Project
- Create a Kanban board for your tasks

### 3. **Releases** - Package versions
- Go to Releases → Draft a new release
- Tag version, add release notes

### 4. **Actions** - CI/CD (Advanced)
- Automate builds and tests
- We can set this up later if needed

---

## 🛡️ Protecting Your Main Branch

To prevent accidental pushes to main:

1. Go to your repo on GitHub
2. Settings → Branches
3. Add rule: `main`
4. Check "Require pull request before merging"
5. Check "Require approvals: 1" (if working with others)

Then work in branches:
```bash
git checkout -b feature/my-feature
# Make changes, commit
git push -u origin feature/my-feature
# Go to GitHub and create Pull Request
```

---

## 📊 `.gitignore` Explained

Our `.gitignore` file prevents these from being uploaded:

- ✅ **Ignored**: Build files, user settings, dependencies
- ✅ **Tracked**: Source code, assets, project files
- ✅ **Protected**: API keys, secrets (add to .gitignore!)

**Important:** If you add API keys or secrets later:

1. Create `Secrets.swift` for sensitive data
2. Add to `.gitignore`
3. Use environment variables or Config files

---

## 🆘 Common Issues & Solutions

### "Remote origin already exists"
```bash
git remote remove origin
git remote add origin YOUR_REPO_URL
```

### "Updates were rejected"
```bash
# Pull first, then push
git pull origin main --rebase
git push
```

### "Large files causing issues"
```bash
# Remove large files from Git history
git filter-branch --tree-filter 'rm -f path/to/large/file' HEAD
```

### "Accidentally committed secrets"
```bash
# Remove from history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch Secrets.swift' \
  --prune-empty --tag-name-filter cat -- --all

# Force push (CAREFUL!)
git push --force
```

---

## ✅ Checklist

- [ ] Created GitHub repository
- [ ] Initialized Git in project folder
- [ ] Added `.gitignore`
- [ ] Made initial commit
- [ ] Pushed to GitHub
- [ ] Verified files are uploaded
- [ ] Set up SSH (optional but recommended)
- [ ] Added README with project info
- [ ] Created first release/tag (optional)

---

## 🎓 Learning Resources

- [GitHub Docs](https://docs.github.com)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials)
- [Oh Shit, Git!?!](https://ohshitgit.com/) - Fix common mistakes

---

**Questions?** Open an issue in your repo or search [Stack Overflow](https://stackoverflow.com/questions/tagged/git).

**Happy coding! 🚀**
