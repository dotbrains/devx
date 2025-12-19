# Frequently Asked Questions

Common questions about the Developer Environment Framework.

## General

**Q: What is this framework?**  
A: A modular, layered system for building secure, reproducible developer environments using Vagrant and Ansible.

**Q: Who is this for?**  
A: Organizations, teams, and individuals needing consistent, secure development environments.

**Q: What are the prerequisites?**  
A: Vagrant 2.3+, VirtualBox 6.1+, Ansible 2.14+, 8GB+ RAM, 60GB+ disk.

## Configuration

**Q: How do I override organization settings?**  
A: Define the same variable in your program's `group_vars/all.yml`.

**Q: Where do secrets go?**  
A: Use Ansible Vault. Never commit unencrypted secrets.

**Q: Can I disable apps?**  
A: Yes, set `enabled: false` in your configuration.

## Usage

**Q: How long does initial setup take?**  
A: Base image: ~15-20 min, Organization spin: ~10-15 min, Program: ~5-10 min.

**Q: Can I run multiple programs simultaneously?**  
A: Yes! Each program is independent.

**Q: How do I access services in the VM?**  
A: Use port forwarding in Vagrantfile.

## Troubleshooting

**Q: VM won't start?**  
A: Check VirtualBox, verify virtualization enabled, try `vagrant destroy -f && vagrant up`.

**Q: Provisioning fails?**  
A: Check Ansible syntax, run with `--debug`, verify Python installed.

**Q: VM is slow?**  
A: Increase RAM/CPU, enable VT-x, use SSD, disable GUI.

See [Troubleshooting Guide](troubleshooting.md) for detailed solutions.

## More Help

- 📚 [Documentation](https://dotbrains.github.io/devx)
- 🐛 [Issues](https://github.com/dotbrains/devx/issues)
- 💬 [Discussions](https://github.com/dotbrains/devx/discussions)
