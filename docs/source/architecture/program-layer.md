# Program Layer

The program layer provides project-specific configurations and customizations.

## Purpose

Enables:

- Project-specific tool versions
- Custom application stacks
- Team workflows
- CI/CD integration
- Environment-specific settings

## Key Features

### Configuration Override

Programs can override organization settings:

```yaml
# Override Docker version
apps:
  docker:
    version: "23.0.6"  # Different from org default
```

### Custom Variables

Add project-specific configuration:

```yaml
project:
  name: "myapp"
  environment: "development"

database:
  host: "localhost"
  name: "myapp_dev"
```

### Custom Playbooks

Project setup automation:

```yaml
- name: Setup My Project
  tasks:
    - name: Clone repository
    - name: Install dependencies
    - name: Setup database
```

## Directory Structure

```
packages/programs/my-project/
├── Vagrantfile          # VM configuration
├── ansible/
│   ├── group_vars/
│   │   └── all.yml     # Program variables
│   ├── playbooks/
│   │   └── program-setup.yml
│   └── roles/          # Custom roles
├── tests/              # Program tests
└── README.md          # Documentation
```

## Common Patterns

### Web Application
```yaml
apps:
  docker: { enabled: true }
  python: { enabled: true }
  nodejs: { enabled: true }
  postgresql: { enabled: true }
```

### Data Science
```yaml
apps:
  python:
    packages:
      - numpy
      - pandas
      - jupyter
```

### Microservices
```yaml
apps:
  docker: { enabled: true }
  kubernetes: { enabled: true }
  helm: { enabled: true }
```

## Usage

```bash
cd packages/programs/my-project
vagrant up
vagrant ssh
```

## See Also

- [Architecture Overview](../architecture.md)
- [Organization Layer](org-layer.md)
- [Creating Programs](../creating-programs.md)
- [Program Configuration](../dev/program-config.md)
