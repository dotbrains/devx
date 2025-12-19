# Troubleshooting

Solutions to common issues with the Developer Environment Framework.

## Vagrant Issues

### VM Won't Start

**Symptoms**: `vagrant up` fails or hangs

**Solutions**:

1. Check VirtualBox is running:
   ```bash
   VBoxManage list vms
   ```

2. Try with debug output:
   ```bash
   vagrant up --debug
   ```

3. Check for port conflicts:
   ```bash
   vagrant port
   ```

4. Verify VT-x/AMD-V is enabled in BIOS

5. Destroy and recreate:
   ```bash
   vagrant destroy -f
   vagrant up
   ```

### Vagrant Stuck on "Waiting for machine to boot"

**Solutions**:

1. Increase boot timeout in Vagrantfile:
   ```ruby
   config.vm.boot_timeout = 600
   ```

2. Check VM console in VirtualBox GUI for errors

3. Try SSH manually:
   ```bash
   vagrant ssh-config
   ssh -F ssh-config default
   ```

### "The guest machine entered an invalid state"

**Solutions**:

1. Check VirtualBox logs:
   ```bash
   VBoxManage showvminfo <vm-name> --log 0
   ```

2. Try different provider:
   ```bash
   vagrant up --provider=vmware_desktop
   ```

3. Reinstall VirtualBox guest additions:
   ```bash
   vagrant plugin install vagrant-vbguest
   vagrant vbguest --do install
   ```

### Shared Folder Errors

**Symptoms**: `/vagrant` not accessible or sync errors

**Solutions**:

1. Install vbguest plugin:
   ```bash
   vagrant plugin install vagrant-vbguest
   ```

2. Manually mount:
   ```bash
   vagrant ssh
   sudo mount -t vboxsf -o uid=1000,gid=1000 vagrant /vagrant
   ```

3. Use alternative sync method in Vagrantfile:
   ```ruby
   config.vm.synced_folder ".", "/vagrant", type: "rsync"
   ```

## Ansible Issues

### Provisioning Fails

**Symptoms**: `vagrant provision` or `vagrant up` fails during Ansible run

**Solutions**:

1. Check Ansible syntax:
   ```bash
   ansible-playbook --syntax-check playbooks/program-setup.yml
   ```

2. Run with verbose output:
   ```bash
   vagrant provision --debug
   ```

3. Test playbook directly:
   ```bash
   ansible-playbook -i inventory playbooks/program-setup.yml -vvv
   ```

4. Check Python version on guest:
   ```bash
   vagrant ssh -c "python3 --version"
   ```

### "Module not found" Errors

**Solutions**:

1. Install required Ansible collections:
   ```bash
   ansible-galaxy collection install ansible.posix
   ansible-galaxy collection install community.general
   ```

2. Use fully qualified collection names:
   ```yaml
   - name: Install package
     ansible.builtin.package:
       name: nginx
   ```

### Variables Not Working

**Solutions**:

1. Check variable precedence:
   ```bash
   ansible-inventory -i inventory --host <hostname> --vars
   ```

2. Verify group_vars path structure

3. Use debug module:
   ```yaml
   - name: Debug variable
     ansible.builtin.debug:
       var: apps.docker
   ```

## Network Issues

### Can't Access Forwarded Ports

**Solutions**:

1. Check port forwarding:
   ```bash
   vagrant port
   ```

2. Verify service is listening:
   ```bash
   vagrant ssh -c "sudo netstat -tulpn | grep :8000"
   ```

3. Check firewall rules:
   ```bash
   vagrant ssh -c "sudo firewall-cmd --list-all"
   ```

4. Bind service to 0.0.0.0 instead of localhost

### SSH Connection Refused

**Solutions**:

1. Check SSH service:
   ```bash
   vagrant ssh -c "sudo systemctl status sshd"
   ```

2. Reset SSH config:
   ```bash
   vagrant ssh-config > /dev/null 2>&1
   vagrant reload
   ```

3. Try with password authentication:
   ```bash
   ssh -o PreferredAuthentications=password vagrant@127.0.0.1 -p 2222
   ```

### DNS Resolution Fails

**Solutions**:

1. Check resolv.conf:
   ```bash
   vagrant ssh -c "cat /etc/resolv.conf"
   ```

2. Set explicit DNS in Vagrantfile:
   ```ruby
   config.vm.provision "shell", inline: <<-SHELL
     echo "nameserver 8.8.8.8" > /etc/resolv.conf
   SHELL
   ```

## Application Issues

### Docker Not Working

**Solutions**:

1. Check Docker service:
   ```bash
   vagrant ssh -c "sudo systemctl status docker"
   ```

2. Add user to docker group:
   ```bash
   vagrant ssh -c "sudo usermod -aG docker vagrant"
   vagrant reload
   ```

3. Verify Docker socket permissions:
   ```bash
   vagrant ssh -c "ls -l /var/run/docker.sock"
   ```

### Kubernetes Tools Not Working

**Solutions**:

1. Check kubectl configuration:
   ```bash
   vagrant ssh -c "kubectl version --client"
   ```

2. Verify k3s installation:
   ```bash
   vagrant ssh -c "sudo systemctl status k3s"
   ```

3. Set KUBECONFIG:
   ```bash
   export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
   ```

### Python Packages Won't Install

**Solutions**:

1. Upgrade pip:
   ```bash
   vagrant ssh -c "pip install --upgrade pip"
   ```

2. Use virtual environment:
   ```bash
   vagrant ssh
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. Check for conflicting packages:
   ```bash
   pip list --outdated
   ```

## Performance Issues

### VM Running Slowly

**Solutions**:

1. Increase RAM/CPU in Vagrantfile:
   ```ruby
   vb.memory = "8192"
   vb.cpus = 4
   ```

2. Disable GUI:
   ```ruby
   vb.gui = false
   ```

3. Use paravirtualization:
   ```ruby
   vb.customize ["modifyvm", :id, "--paravirtprovider", "kvm"]
   ```

4. Enable VT-x/AMD-V in BIOS

### Disk Space Issues

**Solutions**:

1. Check disk usage:
   ```bash
   vagrant ssh -c "df -h"
   ```

2. Clean Docker:
   ```bash
   vagrant ssh -c "docker system prune -af"
   ```

3. Increase disk size in Vagrantfile:
   ```ruby
   config.vm.disk :disk, size: "100GB", primary: true
   ```

### Slow File Sync

**Solutions**:

1. Use rsync instead of vboxsf:
   ```ruby
   config.vm.synced_folder ".", "/vagrant", type: "rsync"
   ```

2. Exclude unnecessary files:
   ```ruby
   config.vm.synced_folder ".", "/vagrant",
     rsync__exclude: [".git/", "node_modules/"]
   ```

3. Use NFS (Unix/macOS only):
   ```ruby
   config.vm.synced_folder ".", "/vagrant", type: "nfs"
   ```

## Build Issues

### Base Image Build Fails

**Solutions**:

1. Verify ISO download:
   ```bash
   ls -lh packages/base/images/rocky9/*.iso
   ```

2. Check disk space:
   ```bash
   df -h
   ```

3. Increase timeout values

4. Try with different mirror

### Organization Spin Build Fails

**Solutions**:

1. Ensure base image exists:
   ```bash
   vagrant box list | grep base-rocky9
   ```

2. Re-add base box:
   ```bash
   vagrant box add base-rocky9 packages/base/artifacts/base-rocky9.box --force
   ```

3. Check app configurations in apps.yml

## Testing Issues

### Tests Failing

**Solutions**:

1. Run tests individually:
   ```bash
   ./tests/unit/test-base-layer.sh
   ```

2. Check test dependencies:
   ```bash
   # Ansible required for some tests
   pip install ansible
   
   # PyYAML for config validation
   pip install pyyaml
   ```

3. Review test output for specific errors

### Ansible Syntax Tests Fail

**Solutions**:

1. Lint playbooks:
   ```bash
   ansible-lint packages/base/ansible/playbooks/*.yml
   ```

2. Check YAML syntax:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('config.yml'))"
   ```

## Documentation Issues

### MkDocs Won't Build

**Solutions**:

1. Install dependencies:
   ```bash
   cd docs
   pip install -r requirements.txt
   ```

2. Check for syntax errors:
   ```bash
   mkdocs build --strict
   ```

3. Use virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

### MkDocs Serve Not Working

**Solutions**:

1. Use different port:
   ```bash
   mkdocs serve --dev-addr=127.0.0.1:8001
   ```

2. Check if port is in use:
   ```bash
   lsof -i :8000
   ```

## Getting More Help

### Diagnostic Information

When reporting issues, include:

```bash
# System information
uname -a
vagrant --version
ansible --version
VBoxManage --version

# VM status
vagrant status
vagrant global-status

# Recent logs
vagrant up --debug > vagrant-debug.log 2>&1
```

### Where to Get Help

- 🐛 [Report Issues](https://github.com/dotbrains/devx/issues)
- 💬 [Discussions](https://github.com/dotbrains/devx/discussions)
- 📚 [Documentation](https://dotbrains.github.io/devx)
- 🤝 [Contributing](contributing.md)

### Before Reporting Issues

1. Check this troubleshooting guide
2. Search existing issues
3. Try with latest version
4. Test with minimal configuration
5. Gather diagnostic information
