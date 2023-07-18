# Git commands

## F.A.Q.s

### Squash all new commits of local branch before merge to main branch

Undo all commits of local branch (so as to commit as one) relative to another branch

```bash
git reset --soft `git rev-parse origin/<target-branch>`
```

Example:

```bash
git reset --soft `git rev-parse origin/dev`
```
