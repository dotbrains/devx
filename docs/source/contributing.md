# Contributing

We welcome contributions to the Developer Environment Framework! This guide will help you get started.

## Ways to Contribute

- 🐛 Report bugs and issues
- 💡 Suggest new features or improvements
- 📝 Improve documentation
- 🔧 Submit bug fixes or new features
- 🧪 Add or improve tests
- 🎨 Enhance user experience

## Getting Started

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/devx.git
cd devx
```

### 2. Create a Branch

```bash
git checkout -b feature/my-new-feature
# or
git checkout -b fix/bug-description
```

### 3. Make Changes

Follow the guidelines in the relevant section below.

### 4. Test Your Changes

```bash
# Run all tests
make test

# Test specific components
make test-base
make test-org

# Validate configurations
make validate
```

### 5. Commit Changes

```bash
git add .
git commit -m "Add feature: description"
```

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `test:` Test additions or changes
- `refactor:` Code refactoring
- `chore:` Maintenance tasks

### 6. Push and Create PR

```bash
git push origin feature/my-new-feature
```

Then create a Pull Request on GitHub.

## Contribution Guidelines

### Code Style

#### Ansible

- Use 2 spaces for indentation
- Follow [Ansible best practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- Use fully qualified collection names (e.g., `ansible.builtin.copy`)
- Add comments for complex tasks

```yaml
# Good
- name: Install Docker
  ansible.builtin.package:
    name: docker-ce
    state: present
  when: apps.docker.enabled | default(false)
```

#### Shell Scripts

- Use `#!/usr/bin/env bash`
- Use `set -euo pipefail`
- Add comments for non-obvious code
- Make scripts executable: `chmod +x script.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# Good: Clear variable names and comments
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Check prerequisites
if ! command -v tool &> /dev/null; then
    echo "ERROR: tool not found"
    exit 1
fi
```

#### Python

- Follow [PEP 8](https://pep8.org/)
- Use type hints where appropriate
- Add docstrings for functions and classes

```python
def search_packages(query: str, ecosystem: Optional[str] = None) -> List[Package]:
    """Search for packages matching query.
    
    Args:
        query: Search term
        ecosystem: Optional ecosystem filter (e.g., 'pypi', 'npm')
    
    Returns:
        List of matching packages
    """
    pass
```

### Documentation

#### Markdown

- Use clear, concise language
- Include code examples where helpful
- Follow existing documentation structure
- Add links to related pages

#### MkDocs

When adding new documentation pages:

1. Create the `.md` file in appropriate directory
2. Add entry to `docs/mkdocs.yml` nav section
3. Test locally: `make serve-docs`

### Testing

#### Required Tests

All changes must include appropriate tests:

- **New features**: Unit and integration tests
- **Bug fixes**: Test that reproduces the bug
- **Configuration changes**: Validation tests

#### Writing Tests

Shell script test template:

```bash
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Testing feature X..."

# Test logic
if [ condition ]; then
    echo "ERROR: Test failed"
    exit 1
fi

echo "Feature X tests passed"
exit 0
```

#### Running Tests

```bash
# All tests
make test

# Specific test
./tests/unit/test-my-feature.sh
```

### Adding New Features

#### App Store Applications

1. Create role in `shared/ansible/roles/app-{name}/`
2. Add entry to `packages/organization/app-store/catalog.yml`
3. Add configuration to `packages/organization/ansible/group_vars/apps.yml`
4. Add tests
5. Update documentation

Example role structure:

```
shared/ansible/roles/app-myapp/
├── tasks/
│   └── main.yml
├── defaults/
│   └── main.yml
├── templates/
└── README.md
```

#### FOSS Packages

1. Add package to registry: `packages/organization/foss-packages/registry/packages.yml`
2. Run security scan: `./scripts/security-scan.sh package-name`
3. Add to approved list if security passes
4. Update mirrors if needed

#### Documentation Pages

1. Create markdown file in `docs/`
2. Add to `docs/mkdocs.yml` navigation
3. Follow existing documentation style
4. Include practical examples

## Project Structure

Understanding the structure helps you contribute effectively:

```
devx/
├── packages/
│   ├── base/              # Base layer (OS images)
│   ├── organization/      # Organization layer (apps, FOSS)
│   └── programs/          # Program layer (projects)
├── shared/
│   └── ansible/
│       └── roles/         # Reusable Ansible roles
├── tests/                 # Test suite
├── docs/                  # MkDocs documentation
├── Makefile              # Build automation
└── README.md
```

## Pull Request Process

1. **Ensure Tests Pass**: All tests must pass
2. **Update Documentation**: Document new features
3. **Follow Commit Conventions**: Use conventional commit messages
4. **Keep PRs Focused**: One feature/fix per PR
5. **Respond to Feedback**: Address review comments promptly

### PR Checklist

- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Commit messages follow conventions
- [ ] All tests pass locally
- [ ] Code follows style guidelines
- [ ] PR description is clear and complete

## Development Setup

### Install Development Dependencies

```bash
# Python tools
pip install -r docs/requirements.txt
pip install ansible ansible-lint

# Optional: Pre-commit hooks
pip install pre-commit
pre-commit install
```

### Local Development

```bash
# Build and test locally
make build-all
make test

# Serve documentation
make serve-docs

# Lint and validate
make lint
make validate
```

## Code Review

We review all contributions. Expect:

- Constructive feedback
- Requests for changes or clarification
- Discussion of implementation approaches

## Reporting Issues

### Bug Reports

Include:

- Description of the bug
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Vagrant/Ansible versions)
- Relevant logs or error messages

### Feature Requests

Include:

- Clear description of the feature
- Use cases and benefits
- Potential implementation approach
- Examples from other projects (if applicable)

## Community

- Be respectful and inclusive
- Help others learn and grow
- Give constructive feedback
- Celebrate contributions

## Questions?

- Open an issue for questions
- Check existing issues and discussions
- Review documentation

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing! 🎉
