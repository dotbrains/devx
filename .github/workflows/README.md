# Vagrant Box Build Pipeline

This workflow builds, tests, and publishes Vagrant boxes to **GitHub Releases**.

## Why GitHub Releases?

- ✅ **No external authentication** - Uses GitHub's built-in tokens
- ✅ **Simple setup** - Works out of the box with no configuration
- ✅ **Free storage** - No additional costs
- ✅ **Integrated** - Releases appear directly in your repository
- ✅ **Reliable** - Uses GitHub's infrastructure

## Workflows

### `build-vagrant-boxes.yml`

Automated pipeline that builds all Rocky Linux base boxes (8, 9, 10), tests them, and publishes to GitHub Releases.

### `docs.yml`

Automated documentation deployment workflow that builds and publishes MkDocs documentation to GitHub Pages.

#### Triggers

- **Push to master**: Automatically builds and deploys documentation when docs change
- **Manual Dispatch**: Allows on-demand documentation deployment
- **Path Filters**: Only runs when documentation files change
  - `docs/**`
  - `.github/workflows/docs.yml`

#### Features

- ✅ Builds MkDocs documentation with Material theme
- ✅ Validates documentation in strict mode
- ✅ Deploys to GitHub Pages automatically
- ✅ Caches Python dependencies for faster builds
- ✅ Uses official GitHub Pages deployment action

#### Setup

1. **Enable GitHub Pages in Repository Settings**:
   - Go to: **Settings** → **Pages**
   - Source: **GitHub Actions**
   - Save changes

2. **No additional configuration needed!** The workflow will automatically deploy on the next push to `docs/`.

#### Access Documentation

Once deployed, documentation will be available at:
- **URL**: `https://dotbrains.github.io/devx/`

#### Local Development

Before pushing, preview documentation locally:

```bash
# Build documentation
make docs

# Serve locally at http://localhost:8000
make serve-docs
```

#### Build Times

Typical documentation build and deploy: **1-3 minutes**

---

### `ansible-lint.yml`

Automated linting workflow that validates all Ansible playbooks, roles, and tasks for code quality and best practices.

#### Triggers

- **Push to master/main/develop**: Automatically lints all Ansible files
- **Pull Requests**: Validates Ansible changes before merge
- **Manual Dispatch**: Allows on-demand linting
- **Path Filters**: Only runs when Ansible files change
  - `packages/**/ansible/**/*.yml`
  - `packages/**/ansible/**/*.yaml`
  - `shared/ansible/**/*.yml`
  - `shared/ansible/**/*.yaml`
  - `requirements.yml`
  - `.ansible-lint`

#### Features

- ✅ Validates playbook syntax and structure
- ✅ Checks for best practices and anti-patterns
- ✅ Enforces consistent code style
- ✅ Verifies role dependencies and collections
- ✅ Tests against production profile standards
- ✅ Provides inline annotations on failures
- ✅ Caches Python dependencies for faster runs

#### What It Checks

- Playbook and task syntax
- YAML formatting (trailing spaces, indentation)
- Use of fully qualified collection names (FQCN)
- Proper use of `failed_when` instead of `ignore_errors`
- Variable naming conventions
- Security best practices
- Relative vs absolute paths
- Missing or misconfigured roles

#### Setup

No additional setup required! The workflow uses:
- Python 3.11
- Latest versions of `ansible` and `ansible-lint`
- Ansible collections from `requirements.yml`

#### Usage

The workflow runs automatically on qualifying commits and PRs. For manual runs:

1. Go to: **Actions** tab → **Ansible Lint**
2. Click **Run workflow**
3. Select branch
4. Click **Run workflow**

#### Local Development

Before pushing, run linting locally:

```bash
# Using virtual environment (recommended)
python3 -m venv .venv
source .venv/bin/activate
pip install ansible ansible-lint
ansible-galaxy collection install -r requirements.yml
make lint
```

Or with Homebrew:

```bash
brew install ansible ansible-lint
ansible-galaxy collection install -r requirements.yml
make lint
```

#### Build Times

Typical lint run: **2-5 minutes**

#### Troubleshooting

##### Lint Fails Locally But Passes in CI

- Ensure you have the same collections installed:
  ```bash
  ansible-galaxy collection install -r requirements.yml --force
  ```

##### Unknown Module Errors

- Check that required collections are in `requirements.yml`
- Verify collection paths in `ansible.cfg`

##### Path-Related Errors

- The workflow runs from package-specific directories
- Ensure `ansible.cfg` files exist in each package's ansible directory
- Use absolute paths or role-relative paths

##### Trailing Spaces or Formatting

- Configure your editor to remove trailing whitespace
- Use consistent indentation (2 spaces for YAML)

---

### `build-vagrant-boxes.yml` (Detailed)

#### Triggers
- **Pull Requests**: Builds and tests (does not publish)
- **Manual Dispatch**: Allows on-demand builds with custom options

#### Features

- ✅ Builds all Rocky Linux versions (8, 9, 10) in parallel
- ✅ Tests `vagrant up` functionality
- ✅ Validates SSH connectivity and system checks
- ✅ Generates SHA256 checksums
- ✅ Uploads artifacts for 30 days
- ✅ **Publishes to GitHub Releases automatically**
- ✅ Caches base boxes for faster builds

## Setup

### Prerequisites

**That's it!** No external accounts or tokens needed. The workflow uses GitHub's built-in `GITHUB_TOKEN`.

## Usage

### Automatic Builds

The workflow automatically runs when you:
- Push changes to `packages/base/images/**` or `packages/base/ansible/**`
- Create a pull request with those changes

When pushed to `master`, it automatically creates a GitHub Release with all boxes.

### Manual Builds

1. Go to: **Actions** tab → **Build and Publish Vagrant Boxes**
2. Click **Run workflow**
3. Select options:
   - **Rocky Linux version**: Choose specific version or "all"
   - **Publish to GitHub Releases**: Enable to create a release
4. Click **Run workflow**

### Downloading from GitHub Releases

#### Via Web Interface

1. Go to your repository's **Releases** page
2. Click on the latest release
3. Download the `.box` file you need
4. Add to Vagrant:

```bash
vagrant box add dotbrains/devx-base-rocky10 /path/to/base-rocky10.box
```

#### Via Command Line

```bash
# Download latest Rocky 10 box
wget https://github.com/dotbrains/devx/releases/latest/download/base-rocky10.box

# Download checksum
wget https://github.com/dotbrains/devx/releases/latest/download/base-rocky10.box.sha256

# Verify checksum
shasum -a 256 -c base-rocky10.box.sha256

# Add to Vagrant
vagrant box add dotbrains/devx-base-rocky10 base-rocky10.box

# Use in a Vagrantfile
vagrant init dotbrains/devx-base-rocky10
vagrant up
```

#### Specific Version

```bash
# Replace VERSION with actual version (e.g., v1-a1b2c3d)
VERSION="v1-a1b2c3d"
wget https://github.com/dotbrains/devx/releases/download/${VERSION}/base-rocky10.box
```

### Downloading Artifacts (Before Release)

If you want boxes before they're released:

1. Go to the workflow run page
2. Scroll to **Artifacts** section
3. Download:
   - `vagrant-box-rocky8`
   - `vagrant-box-rocky9`
   - `vagrant-box-rocky10`

## Build Process

### 1. Matrix Setup
- Determines which Rocky Linux versions to build

### 2. Build and Test (parallel)
- Checks out repository
- Caches base boxes
- Installs dependencies (Vagrant, VirtualBox, Ansible)
- Runs `vagrant up` with provisioning
- Tests SSH and system configuration
- Packages boxes
- Generates checksums
- Uploads artifacts

### 3. Publish to GitHub Releases (conditional)
- Downloads all built artifacts
- Creates comprehensive release notes
- Creates GitHub Release with tag
- Attaches all `.box` and `.sha256` files

### 4. Summary
- Reports build status

## Release Information

### Version Format

`v<run-number>-<short-sha>`

Example: `v42-a1b2c3d`

- `run-number`: Incremental GitHub Actions run number
- `short-sha`: First 7 characters of git commit SHA

### Release Notes

Each release includes:
- Download instructions for each box
- SHA256 checksums
- Quick start guide
- Feature list
- Links to documentation
- Build information (date, commit, branch)

## Build Times

Approximate build times on GitHub Actions macOS runners:
- Rocky Linux 8: ~25-35 minutes
- Rocky Linux 9: ~25-35 minutes
- Rocky Linux 10: ~25-35 minutes

**Total parallel build time**: ~35-45 minutes

## Troubleshooting

### Release Creation Fails

Check:
- Repository has **Actions** enabled
- Workflow has `contents: write` permission (already configured)
- No conflicting tag names

### Box Files Too Large

GitHub has a 2GB limit per release asset. If boxes exceed this:
- Consider compressing boxes further
- Split into multiple releases
- Use external storage (see alternatives below)

### Old Releases Taking Up Space

GitHub doesn't count release assets against repository size, but you can:
- Delete old releases manually
- Set up automated cleanup (create separate workflow)

## Advanced Configuration

### Customizing Release Notes

Edit the `Create release notes` step in the workflow to modify the release description.

### Changing Version Format

Edit this line in the workflow:

```yaml
VERSION="v${GITHUB_RUN_NUMBER}-${GITHUB_SHA::7}"
```

Options:
```yaml
# Semantic versioning
VERSION="1.0.${GITHUB_RUN_NUMBER}"

# Date-based
VERSION="$(date +%Y.%m.%d)-${GITHUB_RUN_NUMBER}"

# Use git tags (when workflow triggered by tag)
VERSION="${GITHUB_REF_NAME}"
```

### Private Releases

By default, releases are public. To make them private, edit:

```yaml
prerelease: true  # Marks as pre-release (less prominent)
# or
draft: true       # Creates as draft (not visible until published)
```

## Integration with Existing Makefile

```bash
# Local development
make build-base-rocky10

# CI/CD (automated)
git push origin master  # Triggers workflow and creates release
```

## Alternative Registries

If you prefer a different registry later:

### Self-Hosted Options
- **Artifactory** - Enterprise artifact repository
- **Nexus Repository** - Free and pro versions
- **GitLab Package Registry** - If using GitLab
- **AWS S3** - Simple storage with bucket hosting

### Public Options
- **Docker Hub** - Can host Vagrant boxes as generic artifacts
- **GitHub Packages** - Alternative GitHub artifact storage

The workflow can be modified to publish to any of these.

## Security Notes

- Uses official GitHub Actions (`actions/*`, `softprops/action-gh-release`)
- `GITHUB_TOKEN` is automatically provided (encrypted)
- Checksums generated for integrity verification
- Release assets are immutable once published
- Boxes built in isolated CI runners

## Costs

### GitHub Actions Minutes
- Free tier: 2,000 minutes/month for Linux
- macOS runners: 10x multiplier (each minute counts as 10)
- Each complete build: ~105-135 actual minutes = ~1,050-1,350 billed minutes
- Builds per month on free tier: ~1-2 complete builds

### Storage
- Release assets: **Free** (unlimited for public repos)
- Artifacts: Included in free tier (500MB storage, 1GB transfer/month)

### Recommendations
- Use manual dispatch for testing
- Enable auto-publish only on master branch
- Consider self-hosted runners for unlimited builds

## Contributing

When modifying the workflow:
1. Test with manual dispatch first
2. Use a single Rocky version for faster testing
3. Check release notes formatting
4. Update this documentation

## Support

- **Workflow Documentation**: This file
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **GitHub Releases API**: https://docs.github.com/en/rest/releases
- **Report Issues**: Use the CI/CD Pipeline Issue template
