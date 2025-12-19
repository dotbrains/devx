# Program Layer (Tier 3)

Program/project-specific customizations that extend organization spins with additional configurations, tools, and workflows.

## Purpose

This layer provides:
- **Program-Specific Configurations**: Custom settings for individual projects
- **Project Toolchains**: Specific versions and tools required by the program
- **Custom Integrations**: CI/CD pipelines, deployment scripts, etc.
- **Team Standards**: Project-specific coding standards and workflows

## Directory Structure

```
programs/
├── example-project/
│   ├── Vagrantfile           # Program-specific Vagrant config
│   ├── ansible/
│   │   ├── playbooks/        # Program playbooks
│   │   └── group_vars/       # Program variables (overrides)
│   ├── scripts/              # Project scripts
│   └── README.md             # Project documentation
├── another-project/
└── templates/                # Templates for new projects
```

## Creating a New Program Environment

### Option 1: Use Template

```bash
cp -r templates/basic programs/my-project
cd programs/my-project
# Edit configuration files
vagrant up
```

### Option 2: From Scratch

```bash
mkdir -p programs/my-project/ansible/{playbooks,group_vars}
cd programs/my-project
# Create Vagrantfile and Ansible configs
```

## Configuration Override Hierarchy

Values are resolved in this order (later overrides earlier):

1. Base defaults (`packages/base/ansible/group_vars/all.yml`)
2. Organization defaults (`packages/organization/ansible/group_vars/all.yml`)
3. Organization app configs (`packages/organization/ansible/group_vars/apps.yml`)
4. **Program overrides** (`packages/programs/<program>/ansible/group_vars/all.yml`)

## Example Program Structure

```yaml
# programs/my-project/ansible/group_vars/all.yml
---
# Override organization settings
app_docker_version: "23.0.6"  # Pin specific version for project

# Add program-specific apps
program_apps_to_install:
  - name: terraform
    role: app-terraform
    enabled: true
    config:
      version: "1.6.0"
      providers:
        - aws
        - kubernetes

  - name: ansible
    role: app-ansible
    enabled: true
    config:
      version: "2.14"
      collections:
        - community.general
        - ansible.posix

# Program-specific variables
program_name: "my-project"
program_environment: "development"
program_repo_url: "https://github.com/org/my-project.git"
program_clone_on_provision: true

# Custom integrations
program_ci_integration: "jenkins"
program_artifact_registry: "artifactory.example.com"
```

## Common Use Cases

### Web Application Development

```yaml
# Includes: Node.js, PostgreSQL, Redis, Nginx
spin_base: "standard"
program_stack:
  - nodejs
  - postgresql
  - redis
  - nginx
```

### Machine Learning Project

```yaml
# Includes: Python, Jupyter, GPU drivers, ML libraries
spin_base: "datascience"
program_stack:
  - python
  - jupyter
  - tensorflow
  - pytorch
```

### DevOps/SRE Project

```yaml
# Includes: Kubernetes tools, Terraform, cloud CLIs
spin_base: "devsecops"
program_stack:
  - kubectl
  - helm
  - terraform
  - aws-cli
  - gcloud
```

## Testing Program Configuration

```bash
cd programs/my-project
vagrant up
vagrant ssh

# Verify configuration
cat /etc/dev-env/program-config.json
app-store list
```

## Best Practices

1. **Pin versions** for production-critical tools
2. **Document** custom configurations in project README
3. **Test** configurations in isolation before team rollout
4. **Version control** all configuration files
5. **Minimize** overrides - use organization defaults when possible
