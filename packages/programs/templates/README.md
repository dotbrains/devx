# Program Templates

Templates for quickly creating new program-specific environments.

## Available Templates

### basic
Minimal program setup with common configuration structure.

```bash
cp -r basic ../my-new-project
cd ../my-new-project
# Edit configuration files
vagrant up
```

### web-app
Full-stack web application template with database and caching.

Includes:
- Node.js/Python runtime
- PostgreSQL database
- Redis cache
- Nginx reverse proxy

### microservice
Microservice development template with container orchestration.

Includes:
- Docker/Podman
- Kubernetes tools
- Service mesh utilities
- API gateway

### data-pipeline
Data engineering template with big data tools.

Includes:
- Python with data science libraries
- Apache Spark
- Database connectors
- Jupyter notebooks

## Creating a New Template

1. Create directory structure:
```bash
mkdir -p my-template/ansible/{playbooks,group_vars,tasks,templates}
```

2. Create required files:
- `Vagrantfile`
- `ansible/playbooks/program-setup.yml`
- `ansible/group_vars/all.yml`
- `README.md`

3. Test the template:
```bash
cd my-template
vagrant up
vagrant ssh
# Verify configuration
```

4. Document usage in README.md
