# CI/CD Pipeline Quick Start

This guide will help you set up the Vagrant box build pipeline in under 10 minutes.

## Overview

The pipelines automatically:

### Build Pipeline
1. ✅ Builds all Rocky Linux base boxes (8, 9, 10)
2. ✅ Tests that `vagrant up` works correctly
3. ✅ Validates SSH and system configuration
4. ✅ Generates checksums for integrity
5. ✅ Uploads boxes as GitHub Actions artifacts
6. ✅ Publishes to GitHub Releases

### Ansible Lint Pipeline
1. ✅ Validates all Ansible playbooks and roles
2. ✅ Checks for syntax errors and best practices
3. ✅ Enforces code quality standards
4. ✅ Runs automatically on Ansible file changes

## Prerequisites

- GitHub repository with this codebase
- That's it! No external accounts needed.

## Step 2: Test the Workflow (Without Publishing)

The easiest way to test is to trigger a manual workflow run:

1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **Build and Publish Vagrant Boxes** workflow
4. Click **Run workflow** dropdown
5. Select:
   - Rocky Linux version: `10` (fastest to test)
   - Publish to GitHub Releases: `false`
6. Click **Run workflow**

This will build Rocky Linux 10 without publishing. Takes ~35-45 minutes.

## Step 3: Download and Test Built Box

Once the workflow completes:

1. Go to the workflow run page
2. Scroll to **Artifacts** section
3. Download `vagrant-box-rocky10`
4. Extract and test locally:

```bash
# Extract the downloaded artifact
unzip vagrant-box-rocky10.zip

# Add to Vagrant
vagrant box add test-box base-rocky10.box

# Test it
vagrant init test-box
vagrant up
vagrant ssh -c "cat /etc/os-release"
vagrant destroy -f

# Cleanup
vagrant box remove test-box
```

## Step 4: Test Publishing to GitHub Releases

Now test the complete pipeline with publishing:

1. Go to **Actions** → **Build and Publish Vagrant Boxes**
2. Click **Run workflow**
3. Select:
   - Rocky Linux version: `10`
   - Publish to GitHub Releases: `true`
4. Click **Run workflow**

After successful completion:
- Box will be available in GitHub Actions artifacts
- Box will be published to **GitHub Releases**
- Go to your repository's **Releases** page to see it

## Step 5: Enable Automatic Builds

The workflow is already configured to run automatically on:
- Pushes to `master` branch that change base images
- Pull requests that modify base images

To trigger an automatic build:

```bash
# Make a small change to trigger the pipeline
cd packages/base/images/rocky10
echo "# Updated $(date)" >> Vagrantfile

# Commit and push
git add Vagrantfile
git commit -m "Test CI/CD pipeline trigger"
git push origin master
```

The workflow will:
- Build and test all Rocky Linux versions in parallel
- Publish to GitHub Releases (if on master branch)

## Verification Checklist

### Build Pipeline
- [ ] Workflow runs successfully
- [ ] All three Rocky Linux versions build (8, 9, 10)
- [ ] Artifacts are uploaded
- [ ] Checksums are generated
- [ ] Tests pass (SSH, system validation)
- [ ] Boxes are published to GitHub Releases (if configured)
- [ ] Boxes can be downloaded from Releases page

### Ansible Lint Pipeline
- [ ] Ansible lint workflow runs automatically on Ansible file changes
- [ ] All playbooks pass linting checks
- [ ] No syntax errors or warnings
- [ ] Local linting (`make lint`) passes before pushing

## Common Issues

### VirtualBox Installation Fails
The workflow uses macOS runners which have better virtualization support. This should rarely fail.

### Ansible Provisioning Fails
Check that these files exist:
- `packages/base/ansible/playbooks/base-setup.yml`
- `packages/base/ansible/ansible.cfg`
- `packages/base/ansible/inventory/base.ini`

### Publishing Fails
- Ensure repository has Actions enabled
- Check that workflow has `contents: write` permission (already configured)
- Verify no conflicting tag names exist

### Build Times Out
Default timeout is 45 minutes. If needed, increase in workflow:
```yaml
timeout-minutes: 60  # Increase from 45
```

## Next Steps

- **Customize**: Edit workflow to match your needs
- **Monitor**: Set up notifications for workflow failures
- **Optimize**: Adjust caching strategy for faster builds
- **Document**: Add your organization's specific instructions

## Support

- **Workflow Documentation**: [.github/workflows/README.md](.github/workflows/README.md)
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **GitHub Releases Docs**: https://docs.github.com/en/repositories/releasing-projects-on-github
- **Report Issues**: Use the CI/CD Pipeline Issue template

## Estimated Costs

### GitHub Actions Minutes
- Free tier: 2,000 minutes/month (Linux), 3x multiplier for macOS
- Each complete build: ~35-45 minutes × 3 runners = ~105-135 minutes
- Cost per build on free tier: ~315-405 macOS minutes
- Builds per month on free tier: ~4-6 complete builds

### GitHub Releases
- **Free** for public repositories
- Release assets don't count against repository size

## Security Notes

- Uses GitHub's built-in `GITHUB_TOKEN` (no external secrets needed)
- Workflow uses official GitHub Actions only
- VirtualBox installed from official Homebrew cask
- Checksums generated for all boxes
- Release assets are immutable once published

---

**Time to complete**: ~10 minutes setup + 35-45 minutes first build

**Need help?** Check the detailed documentation in `.github/workflows/README.md`
