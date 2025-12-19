# Ansible Roles

Guide for developing custom Ansible roles for the framework.

## Overview

Ansible roles provide reusable, modular components for:

- Installing applications
- Configuring services
- Managing settings
- Enforcing standards

## Role Structure

### Standard Layout

```
shared/ansible/roles/app-myapp/
├── tasks/
│   ├── main.yml          # Main task list
│   ├── install.yml       # Installation tasks
│   └── configure.yml     # Configuration tasks
├── handlers/
│   └── main.yml          # Service handlers
├── templates/
│   ├── config.j2         # Config templates
│   └── service.j2        # Service files
├── files/
│   └── script.sh         # Static files
├── vars/
│   └── main.yml          # Role variables
├── defaults/
│   └── main.yml          # Default variables
├── meta/
│   └── main.yml          # Role metadata
└── README.md             # Documentation
```

## Creating a New Role

### Initialize Role

```bash
mkdir -p shared/ansible/roles/app-myapp/{tasks,handlers,templates,files,vars,defaults,meta}
cd shared/ansible/roles/app-myapp
```

### Define Tasks

`tasks/main.yml`:

```yaml
---
# Main task file for app-myapp

- name: Include installation tasks
  ansible.builtin.include_tasks: install.yml
  when: apps.myapp.enabled | default(false)

- name: Include configuration tasks
  ansible.builtin.include_tasks: configure.yml
  when: apps.myapp.enabled | default(false)
```

`tasks/install.yml`:

```yaml
---

- name: Add MyApp repository
  ansible.builtin.yum_repository:
    name: myapp
    description: MyApp Repository
    baseurl: "https://repo.example.com/myapp"
    gpgcheck: true
    gpgkey: "https://repo.example.com/myapp/RPM-GPG-KEY"

- name: Install MyApp
  ansible.builtin.package:
    name: "myapp-{{ apps.myapp.version | default(myapp_default_version) }}"
    state: present
  notify: restart myapp

- name: Ensure MyApp is enabled and started
  ansible.builtin.systemd:
    name: myapp
    state: started
    enabled: true
```

`tasks/configure.yml`:

```yaml
---

- name: Create configuration directory
  ansible.builtin.file:
    path: /etc/myapp
    state: directory
    owner: myapp
    group: myapp
    mode: '0755'

- name: Deploy configuration file
  ansible.builtin.template:
    src: config.j2
    dest: /etc/myapp/config.yml
    owner: myapp
    group: myapp
    mode: '0644'
  notify: restart myapp

- name: Create data directory
  ansible.builtin.file:
    path: "{{ apps.myapp.data_dir | default('/var/lib/myapp') }}"
    state: directory
    owner: myapp
    group: myapp
    mode: '0750'
```

### Define Handlers

`handlers/main.yml`:

```yaml
---

- name: restart myapp
  ansible.builtin.systemd:
    name: myapp
    state: restarted

- name: reload myapp
  ansible.builtin.systemd:
    name: myapp
    state: reloaded
```

### Create Templates

`templates/config.j2`:

```jinja2
# MyApp Configuration
# Managed by Ansible - DO NOT EDIT MANUALLY

server:
  host: {{ apps.myapp.host | default('0.0.0.0') }}
  port: {{ apps.myapp.port | default(8080) }}

logging:
  level: {{ apps.myapp.log_level | default('info') }}
  file: /var/log/myapp/app.log

database:
  host: {{ apps.myapp.db_host | default('localhost') }}
  port: {{ apps.myapp.db_port | default(5432) }}
  name: {{ apps.myapp.db_name }}

{% if apps.myapp.features is defined %}
features:
{% for feature in apps.myapp.features %}
  - {{ feature }}
{% endfor %}
{% endif %}
```

### Set Defaults

`defaults/main.yml`:

```yaml
---
# Default variables for app-myapp

myapp_default_version: "1.0.0"

myapp_defaults:
  host: "0.0.0.0"
  port: 8080
  log_level: "info"
  data_dir: "/var/lib/myapp"
  db_host: "localhost"
  db_port: 5432
```

### Add Metadata

`meta/main.yml`:

```yaml
---
galaxy_info:
  role_name: app_myapp
  author: DevX Team
  description: Install and configure MyApp
  license: MIT
  min_ansible_version: "2.14"
  
  platforms:
    - name: EL
      versions:
        - "9"
  
  galaxy_tags:
    - myapp
    - application
    - development

dependencies: []
```

### Document the Role

`README.md`:

```markdown
# Ansible Role: app-myapp

Installs and configures MyApp.

## Requirements

- Rocky Linux 9
- Ansible 2.14+

## Role Variables

```yaml
apps:
  myapp:
    enabled: true
    version: "1.0.0"
    host: "0.0.0.0"
    port: 8080
    log_level: "info"
    data_dir: "/var/lib/myapp"
    db_host: "localhost"
    db_port: 5432
    db_name: "myapp"
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: app-myapp
      when: apps.myapp.enabled | default(false)
```

## License

MIT
```

## Best Practices

### Use Fully Qualified Collection Names

```yaml
# Good
- name: Install package
  ansible.builtin.package:
    name: myapp

# Bad
- name: Install package
  package:
    name: myapp
```

### Implement Idempotency

```yaml
- name: Create directory (idempotent)
  ansible.builtin.file:
    path: /etc/myapp
    state: directory
  # Running multiple times has same result
```

### Use Conditionals Wisely

```yaml
- name: Install MyApp
  ansible.builtin.package:
    name: myapp
  when:
    - apps.myapp.enabled | default(false)
    - ansible_os_family == "RedHat"
```

### Organize with Tags

```yaml
- name: Install MyApp
  ansible.builtin.package:
    name: myapp
  tags:
    - myapp
    - install
    - packages
```

### Handle Errors Gracefully

```yaml
- name: Start MyApp service
  ansible.builtin.systemd:
    name: myapp
    state: started
  register: service_result
  failed_when: false

- name: Check service status
  ansible.builtin.debug:
    msg: "Warning: MyApp service failed to start"
  when: service_result.failed
```

## Testing Roles

### Syntax Check

```bash
ansible-playbook --syntax-check playbooks/test-role.yml
```

### Lint

```bash
ansible-lint roles/app-myapp
```

### Test Playbook

Create `tests/test.yml`:

```yaml
---

- name: Test app-myapp role
  hosts: localhost
  become: true
  
  vars:
    apps:
      myapp:
        enabled: true
        version: "1.0.0"
  
  roles:
    - app-myapp
  
  post_tasks:
    - name: Verify MyApp is running
      ansible.builtin.systemd:
        name: myapp
      register: service_status
    
    - name: Assert service is active
      ansible.builtin.assert:
        that:
          - service_status.status.ActiveState == "active"
```

## Common Patterns

### Application Role Pattern

For installing applications:

```yaml
---

- name: Add repository
  # Add package repository

- name: Install application
  # Install package

- name: Configure application
  # Deploy configuration

- name: Enable and start service
  # Start service
```

### Configuration Role Pattern

For managing configuration:

```yaml
---

- name: Create directories
  # Ensure directories exist

- name: Deploy configuration files
  # Template configs

- name: Set permissions
  # Fix ownership/permissions

- name: Validate configuration
  # Test config syntax
```

## See Also

- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Custom Spins](custom-spins.md)
- [Creating Programs](../creating-programs.md)
