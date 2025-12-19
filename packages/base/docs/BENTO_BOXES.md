# Bento Boxes for Rocky Linux

## Overview

This project uses [Bento](https://app.vagrantup.com/bento) boxes (`bento/rockylinux-*`) as the foundation for all Rocky Linux base images instead of the official Rocky Linux boxes (`rockylinux/*`).

## Why Bento?

### Multi-Provider Support

The official Rocky Linux boxes support only a limited set of providers:
- ✅ VirtualBox
- ✅ libvirt/QEMU
- ✅ VMware Desktop
- ❌ Parallels (not supported)

Bento boxes support all major virtualization providers:
- ✅ VirtualBox
- ✅ libvirt/QEMU
- ✅ VMware Desktop
- ✅ Parallels Desktop

### Apple Silicon Compatibility

This is the primary driver for the migration. Apple Silicon Macs (M1, M2, M3) require ARM64 virtualization:

- **VirtualBox**: Does not support ARM64 on macOS
- **libvirt/QEMU**: Works but has performance limitations
- **VMware Fusion**: Supports ARM64 but requires a paid license
- **Parallels Desktop**: Best performance and user experience on Apple Silicon

Parallels is the recommended provider for Apple Silicon Macs, and only Bento boxes provide Parallels support for Rocky Linux.

### Maintained by Chef/Progress

Bento boxes are maintained by Chef Software (now part of Progress Software) and follow a rigorous build process:

- Regular security updates
- Consistent build pipeline across all OS variants
- Well-tested and widely used in production environments
- Active community support

### Architecture Support

Bento boxes provide both AMD64 and ARM64 variants:

```
bento/rockylinux-8
├── amd64
│   ├── virtualbox
│   ├── vmware_desktop
│   ├── libvirt
│   └── parallels
└── arm64
    ├── virtualbox (where supported)
    ├── vmware_desktop
    ├── libvirt
    └── parallels
```

## Verified Compatibility

We've verified that Bento boxes work correctly with:

| Box | VirtualBox | VMware | libvirt | Parallels |
|-----|-----------|--------|---------|-----------|
| `bento/rockylinux-8` | ✅ | ✅ | ✅ | ✅ |
| `bento/rockylinux-9` | ✅ | ✅ | ✅ | ✅ |
| `bento/rockylinux-10` | ✅ | ✅ | ✅ | ✅ |

## What Changed

### Before (Official Boxes)

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "rockylinux/10"
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end
end
```

### After (Bento Boxes)

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "bento/rockylinux-10"
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end
  
  config.vm.provider "libvirt" do |lv|
    lv.memory = "2048"
    lv.cpus = 2
    lv.driver = "qemu"
  end
  
  config.vm.provider "parallels" do |prl|
    prl.memory = "2048"
    prl.cpus = 2
    prl.update_guest_tools = true
  end
end
```

## Usage

### Intel Macs

```bash
# VirtualBox (default)
vagrant up

# Or explicitly
vagrant up --provider=virtualbox
vagrant up --provider=vmware_desktop
vagrant up --provider=parallels
```

### Apple Silicon Macs

```bash
# Parallels (recommended)
vagrant up --provider=parallels

# Or libvirt/QEMU
vagrant up --provider=libvirt
```

### Using the Makefile

The project Makefile supports provider selection:

```bash
# Default (VirtualBox on Intel, auto-detect on ARM)
make build-base

# Parallels
make build-base VAGRANT_DEFAULT_PROVIDER=parallels

# libvirt
make build-base VAGRANT_DEFAULT_PROVIDER=libvirt
```

## Migration Checklist

If you were using the official Rocky Linux boxes:

- [x] Update `config.vm.box` from `rockylinux/*` to `bento/rockylinux-*`
- [x] Add provider-specific configurations for libvirt and Parallels
- [x] Update documentation to reference Bento boxes
- [ ] Test with your preferred provider
- [ ] Remove old boxes: `vagrant box remove rockylinux/10`

## Resources

- [Bento Project on Vagrant Cloud](https://app.vagrantup.com/bento)
- [Bento GitHub Repository](https://github.com/chef/bento)
- [Rocky Linux Official Boxes](https://app.vagrantup.com/rockylinux)
- [Vagrant Parallels Provider](https://parallels.github.io/vagrant-parallels/)

## Support

If you encounter issues with Bento boxes:

1. Check the [Bento Issues](https://github.com/chef/bento/issues)
2. Verify your provider is properly installed
3. Ensure you have the latest provider plugin: `vagrant plugin update`
4. Fall back to official boxes if needed (with provider limitations)
