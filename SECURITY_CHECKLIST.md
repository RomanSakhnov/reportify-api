# Security Checklist

## Files That Should NEVER Be Committed

These files contain sensitive information and are protected by `.gitignore`:

### Environment Files

- ❌ `.env` - Local development secrets
- ❌ `.env.production` - Production secrets
- ❌ `.env.local`, `.env.development`, `.env.test` - Environment-specific configs
- ✅ `.env.example` - Template (safe to commit)
- ✅ `.env.production.example` - Template (safe to commit)

### Kamal Deployment Files

- ❌ `.kamal/secrets` - Actual deployment secrets
- ✅ `.kamal/secrets.example` - Template (safe to commit)

### Rails Secret Files

- ❌ `config/master.key` - Rails master key
- ❌ `config/credentials/*.key` - Credential keys

### Database Files

- ❌ `*.dump` - Database dumps
- ❌ `*.sql` - SQL files with data
- ❌ `*.sqlite3` - SQLite databases

### Other Sensitive Files

- ❌ SSH private keys (\*.pem, id_rsa, etc.)
- ❌ SSL certificates and private keys
- ❌ Docker registry passwords

## Verify Your Protection

Check what's being tracked:

```bash
git ls-files | grep -E "\.env$|secrets$|master\.key|\.pem$"
```

If this returns anything, you have sensitive files tracked in git!

Check what's untracked:

```bash
git status --short
```

Files starting with `??` are untracked. Make sure sensitive files show here.

## If You Accidentally Committed Secrets

### Remove from latest commit (not pushed yet):

```bash
# Remove the file
git rm --cached .env.production

# Amend the commit
git commit --amend --no-edit
```

### Remove from history (already pushed):

```bash
# Use git filter-branch or BFG Repo-Cleaner
# This rewrites history - coordinate with your team!

# Example with filter-branch:
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch .env.production' \
  --prune-empty --tag-name-filter cat -- --all

# Force push (dangerous!)
git push --force --all
```

**Better**: Rotate all compromised secrets immediately!

## Setting Up Secrets

### 1. Create `.env.production`

```bash
cp .env.production.example .env.production
# Edit with your actual values
```

### 2. Create `.kamal/secrets`

```bash
cp .kamal/secrets.example .kamal/secrets
chmod +x .kamal/secrets
# Edit if needed (usually reads from .env.production)
```

### 3. Create Rails master key

```bash
# If you don't have one yet:
EDITOR=nano rails credentials:edit

# This creates config/master.key
```

## Current Protection Status

Your `.gitignore` currently protects:

- ✅ All `.env*` files (except examples)
- ✅ `.kamal/secrets` files
- ✅ `config/master.key`
- ✅ `config/credentials/*.key`
- ✅ Database dumps (_.dump, _.sql, \*.sqlite3)
- ✅ IDE files (.idea, .vscode)
- ✅ OS files (.DS_Store)

## Quick Security Check

Run this before committing:

```bash
# Check for exposed secrets
git diff --cached | grep -iE "password|secret|key|token" || echo "No obvious secrets found"

# Verify .gitignore is working
git status --ignored | grep -E "\.env|secrets|master\.key"
```

## Generate Secure Secrets

### JWT Secret

```bash
openssl rand -hex 64
```

### Database Password

```bash
openssl rand -base64 32
```

### Rails Master Key

```bash
rails credentials:edit
# Or manually: openssl rand -hex 32
```

## Best Practices

1. **Never hardcode secrets** in code
2. **Use environment variables** for all sensitive data
3. **Rotate secrets regularly** (every 90 days recommended)
4. **Different secrets per environment** (dev, staging, production)
5. **Limit access** to production secrets (only ops team)
6. **Use secret managers** for production (AWS Secrets Manager, Vault, etc.)
7. **Enable 2FA** on all services (GitHub, Docker Hub, etc.)
8. **Audit access logs** regularly

## Emergency Response

If secrets are exposed:

1. **Immediately rotate** all exposed credentials
2. **Check access logs** for unauthorized use
3. **Notify team** of the breach
4. **Update deployed services** with new credentials
5. **Remove secrets from git history**
6. **Document the incident**

## Need Help?

- Rails credentials: https://guides.rubyonrails.org/security.html#custom-credentials
- Kamal secrets: https://kamal-deploy.org/docs/commands/secrets/
- Git filter-branch: https://git-scm.com/docs/git-filter-branch
- BFG Repo-Cleaner: https://rtyley.github.io/bfg-repo-cleaner/
