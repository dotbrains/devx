# CLI Authentication Quick Start

Get started with FOSS CLI authentication in 3 simple steps.

## Step 1: Generate Token

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

Copy the output token (looks like: `x7jK9mN2pQ4rT8vW1yZ3bD5fH6gJ8kL0nM2oP4qR6sT8uV0wX2yZ4aB6cD8eF0g`)

## Step 2: Set Environment Variable

### Bash/Zsh (Linux/Mac)

```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export FOSS_API_TOKEN="your-token-here"' >> ~/.bashrc
source ~/.bashrc
```

### Fish Shell

```bash
# Add to ~/.config/fish/config.fish
echo 'set -gx FOSS_API_TOKEN "your-token-here"' >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

### Windows (PowerShell)

```powershell
$env:FOSS_API_TOKEN="your-token-here"
# Or set permanently
[System.Environment]::SetEnvironmentVariable('FOSS_API_TOKEN', 'your-token-here', 'User')
```

### Temporary (Current Session Only)

```bash
export FOSS_API_TOKEN="your-token-here"
```

## Step 3: Use CLI

### Submit Package (Protected - Requires Token)

```bash
foss-cli submit axios 1.6.2 --type npm --description "HTTP client"
```

### Search/List/Info (Public - No Token Required)

```bash
foss-cli search requests
foss-cli list --type pypi
foss-cli info flask 3.0.0
```

## Alternative: Use --token Flag

Don't want to set environment variable? Use the `--token` flag:

```bash
foss-cli --token "your-token-here" submit package 1.0.0 --type pypi
```

## Verify Setup

Check if your token is configured:

```bash
echo $FOSS_API_TOKEN
```

Should output your token. If empty, go back to Step 2.

## Common Issues

### "Warning: No API token provided"

**Cause**: Token not set or not exported in current shell

**Fix**:
```bash
export FOSS_API_TOKEN="your-token-here"
```

### "401 Unauthorized" or "403 Forbidden"

**Cause**: Token is missing, invalid, or doesn't match server

**Fix**:
1. Verify token is set: `echo $FOSS_API_TOKEN`
2. Contact administrator for valid token
3. Ensure server has matching token in `FOSS_API_TOKENS`

### Token works in one terminal but not another

**Cause**: Environment variable not persisted

**Fix**: Add to shell config file (see Step 2)

## Security Tips

1. **Never commit tokens to git**
   - Add `.env` files to `.gitignore`
   - Don't paste tokens in code

2. **Use different tokens per environment**
   - Development: `FOSS_API_TOKEN_DEV`
   - Production: `FOSS_API_TOKEN_PROD`

3. **Rotate tokens regularly**
   - Generate new token every 90 days
   - Update environment variable

4. **Keep tokens secret**
   - Don't share in chat/email
   - Use password manager or secrets vault

## Quick Reference

| Operation | Auth Required | Example |
|-----------|--------------|---------|
| `search` | No | `foss-cli search flask` |
| `list` | No | `foss-cli list --type pypi` |
| `info` | No | `foss-cli info requests 2.31.0` |
| `security` | No | `foss-cli security flask` |
| `submit` | **Yes** | `foss-cli submit pkg 1.0 --type npm` |
| `approve` | **Yes** | `foss-cli approve pkg 1.0` |
| `reject` | **Yes** | `foss-cli reject pkg 1.0 --reason "CVE"` |

## Need Help?

- Full docs: See [README.md](README.md)
- API docs: See [../api/AUTH_SETUP.md](../api/AUTH_SETUP.md)
- Generate token: `python3 -c "import secrets; print(secrets.token_urlsafe(32))"`
