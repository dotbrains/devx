# Base Layer (Tier 1)

Foundation layer providing hardened base images and core system configurations.

## Base Box Selection

We use [Bento](https://app.vagrantup.com/bento) boxes (`bento/rockylinux-*`) instead of the official Rocky Linux boxes (`rockylinux/*`) for the following reasons:

- **Multi-provider support**: Bento boxes support VirtualBox, VMware, libvirt/QEMU, and Parallels
- **Apple Silicon compatibility**: Parallels provider enables native ARM64 support on Apple Silicon Macs
- **Maintained by Chef/Progress**: Regularly updated with security patches and provider improvements
- **Consistent quality**: Standardized build process across all OS variants

The official `rockylinux/*` boxes only support VirtualBox, libvirt, and VMware Desktop, lacking Parallels support needed for optimal performance on Apple Silicon.

**See [docs/BENTO_BOXES.md](docs/BENTO_BOXES.md) for detailed information about the migration and provider support.**

## Contents

### Images
Base OS images with security hardening for various platforms:
- Rocky Linux 10 (recommended)
- Rocky Linux 9
- Rocky Linux 8 ⚠️ **Not supported on Apple Silicon Macs** - No ARM64 box available
- Ubuntu 22.04 LTS
- Debian 12

### Security Features
- Airgapped deployment ready
- CIS benchmark compliance
- Minimal attack surface
- SELinux/AppArmor enabled
- Automated security updates

### Directory Structure

```
base/
├── images/
│   ├── rocky10/             # Rocky Linux 10 base
│   ├── rocky9/              # Rocky Linux 9 base
│   ├── ubuntu/              # Ubuntu base
│   └── debian/              # Debian base
├── ansible/
│   ├── roles/               # Base Ansible roles
│   ├── playbooks/           # Core playbooks
│   └── group_vars/          # Default variables
├── tests/                   # Validation tests
└── docs/                    # Base layer documentation
```

## Building a Base Image

```bash
cd images/rocky10
vagrant up
vagrant package --output ../../artifacts/base-rocky10.box
```

## Configuration

Base configuration is defined in `ansible/group_vars/all.yml`:

```yaml
base_os_hardening: true
base_minimal_packages: true
base_security_level: high
base_airgapped: false
```

## Testing

```bash
cd tests
ansible-playbook verify-base.yml
```
