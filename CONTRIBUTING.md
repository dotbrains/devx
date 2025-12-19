# Contributing to Developer Environment Framework

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/dev-environment-framework.git`
3. Create a feature branch: `git checkout -b feature/my-new-feature`
4. Make your changes
5. Test your changes
6. Submit a pull request

## Development Setup

### Prerequisites

- Vagrant >= 2.3.0
- Ansible >= 2.14
- VirtualBox or VMware
- Git

### Testing Changes

```bash
# Test base layer changes
cd packages/base/images/rocky9
vagrant up
vagrant ssh
# Verify changes

# Test organization layer changes
cd packages/organization/spins/standard
vagrant up
vagrant ssh
# Verify app store functionality

# Test program layer changes
cd packages/programs/example-project
vagrant up
vagrant ssh
# Verify program-specific configs
```

## Contribution Guidelines

### Code Style

- **Ansible**: Follow [Ansible best practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- **YAML**: 2-space indentation, quotes for strings
- **Shell Scripts**: Use shellcheck for validation
- **Documentation**: Use clear, concise language

### Commit Messages

Follow conventional commits format:

```
type(scope): subject

body

footer
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

Example:
```
feat(app-store): add terraform app role

Add Ansible role for installing and configuring Terraform
with support for multiple provider configurations.

Closes #123
```

### Pull Request Process

1. Update documentation for any changed functionality
2. Add tests for new features
3. Ensure all tests pass
4. Update CHANGELOG.md
5. Request review from maintainers

### Adding a New App to the App Store

1. Create the app role:
```bash
mkdir -p packages/organization/app-store/apps/my-app/tasks
```

2. Define the app in `catalog.yml`:
```yaml
my-app:
  name: "My App"
  category: "development"
  description: "Description of my app"
  role: "app-my-app"
  configurable:
    - version
    - config_options
  security_level: "vetted"
```

3. Implement the Ansible role:
```yaml
# packages/organization/app-store/apps/my-app/tasks/main.yml
---
- name: Install my-app
  ansible.builtin.package:
    name: my-app
    state: present
```

4. Add tests
5. Document usage
6. Submit PR

### Creating a New Organization Spin

1. Copy the template:
```bash
cp -r packages/organization/spins/standard packages/organization/spins/my-spin
```

2. Customize Vagrantfile and Ansible configs
3. Test the spin:
```bash
cd packages/organization/spins/my-spin
vagrant up
```

4. Document the spin's purpose and usage
5. Submit PR

## Testing

### Unit Tests

```bash
# Test Ansible syntax
ansible-playbook --syntax-check playbook.yml

# Test Ansible roles
ansible-playbook tests/test-playbook.yml
```

### Integration Tests

```bash
# Full integration test
cd tests/integration
./run-tests.sh
```

### Security Testing

```bash
# Run security scans
cd tests/security
./security-scan.sh
```

## Documentation

### What to Document

- New features and functionality
- Configuration options
- Architecture changes
- Breaking changes
- Migration guides

### Documentation Structure

- User-facing docs: `docs/`
- Architecture docs: `docs/architecture.md`
- API reference: `docs/api-reference.md`
- Admin guides: `docs/admin/`
- Developer guides: `docs/dev/`

## Questions?

- Open an issue for bugs or feature requests
- Start a discussion for questions or ideas
- Check existing documentation

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
