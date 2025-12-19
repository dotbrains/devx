.PHONY: help build-base build-org-standard test clean setup-ansible-inventory setup-venv lint validate

# Project root directory
PROJECT_ROOT := $(shell pwd)

# Detect architecture
ARCH := $(shell uname -m)

# Auto-detect provider based on architecture and available plugins
ifeq ($(VAGRANT_DEFAULT_PROVIDER),)
  ifeq ($(ARCH),arm64)
    # Apple Silicon - prefer Parallels, fallback to VMware
    ifneq ($(shell vagrant plugin list 2>/dev/null | grep vagrant-parallels),)
      VAGRANT_DEFAULT_PROVIDER := parallels
    else ifneq ($(shell vagrant plugin list 2>/dev/null | grep vagrant-vmware-desktop),)
      VAGRANT_DEFAULT_PROVIDER := vmware_desktop
    else
      VAGRANT_DEFAULT_PROVIDER := virtualbox
    endif
  else
    # Intel - prefer VirtualBox
    VAGRANT_DEFAULT_PROVIDER := virtualbox
  endif
  export VAGRANT_DEFAULT_PROVIDER
endif

PROVIDER_FLAG := --provider=$(VAGRANT_DEFAULT_PROVIDER)

# Architecture compatibility map
ROCKY8_ARM_COMPATIBLE := false
ROCKY9_ARM_COMPATIBLE := true
ROCKY10_ARM_COMPATIBLE := true

help:
	@echo "═══════════════════════════════════════════════════════════════════════════════"
	@echo "  Developer Environment Framework - Make Commands"
	@echo "═══════════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "╭─ System Info ─────────────────────────────────────────────────────────────╮"
	@echo "│  Architecture:       $(ARCH)"
	@echo "│  Detected Provider:  $(VAGRANT_DEFAULT_PROVIDER)"
	@echo "╰───────────────────────────────────────────────────────────────────────────╯"
	@echo ""
	@echo "╭─ Building ────────────────────────────────────────────────────────────────╮"
	@echo "│  make build-base           Build base Rocky 10 image (default)"
	@echo "│  make build-base-rocky8    Build base Rocky 8 image (x86_64 only)"
	@echo "│  make build-base-rocky9    Build base Rocky 9 image"
	@echo "│  make build-base-rocky10   Build base Rocky 10 image"
	@echo "│  make build-org-standard   Build standard organization spin"
	@echo "│  make build-all            Build compatible base images and layers"
	@echo "╰───────────────────────────────────────────────────────────────────────────╯"
	@echo ""
	@echo "╭─ Setup ───────────────────────────────────────────────────────────────────╮"
	@echo "│  make setup-venv                Setup Python virtual environment"
	@echo "│  make setup-ansible-inventory   Create required Ansible inventory files"
	@echo "│  make init-program              Create new program environment from template"
	@echo "╰───────────────────────────────────────────────────────────────────────────╯"
	@echo ""
	@echo "╭─ Testing ─────────────────────────────────────────────────────────────────╮"
	@echo "│  make test           Run all tests"
	@echo "│  make test-base      Test base layer"
	@echo "│  make test-org       Test organization layer"
	@echo "╰───────────────────────────────────────────────────────────────────────────╯"
	@echo ""
	@echo "╭─ Cleanup ─────────────────────────────────────────────────────────────────╮"
	@echo "│  make clean              Clean all Vagrant environments"
	@echo "│  make clean-artifacts    Remove built artifacts"
	@echo "╰───────────────────────────────────────────────────────────────────────────╯"
	@echo ""
	@echo "╭─ Development ─────────────────────────────────────────────────────────────╮"
	@echo "│  make lint        Lint Ansible playbooks (auto-setup venv)"
	@echo "│  make validate    Validate configurations (auto-setup venv)"
	@echo "╰───────────────────────────────────────────────────────────────────────────╯"
	@echo ""
	@echo "╭─ Documentation ───────────────────────────────────────────────────────────╮"
	@echo "│  make setup-docs    Setup documentation environment"
	@echo "│  make docs          Build documentation"
	@echo "│  make serve-docs    Serve docs at http://localhost:8000"
	@echo "╰───────────────────────────────────────────────────────────────────────────╯"
	@echo ""
	@echo "💡 Tip: Override provider with VAGRANT_DEFAULT_PROVIDER=<provider>"
	@echo "   Example: make build-base VAGRANT_DEFAULT_PROVIDER=vmware_desktop"
	@echo ""

# Setup Ansible inventory files
setup-ansible-inventory:
	@echo "Setting up Ansible inventory files..."
	@mkdir -p packages/base/ansible/inventory
	@mkdir -p packages/organization/ansible/inventory
	@if [ ! -f packages/base/ansible/inventory/base.ini ]; then \
		echo "[all]" > packages/base/ansible/inventory/base.ini; \
		echo "default ansible_connection=local" >> packages/base/ansible/inventory/base.ini; \
		echo "" >> packages/base/ansible/inventory/base.ini; \
		echo "[base:children]" >> packages/base/ansible/inventory/base.ini; \
		echo "all" >> packages/base/ansible/inventory/base.ini; \
		echo "" >> packages/base/ansible/inventory/base.ini; \
		echo "[base:vars]" >> packages/base/ansible/inventory/base.ini; \
		echo "ansible_python_interpreter=/usr/bin/python3" >> packages/base/ansible/inventory/base.ini; \
		echo "Created packages/base/ansible/inventory/base.ini"; \
	fi
	@if [ ! -f packages/organization/ansible/inventory/organization.ini ]; then \
		echo "[all]" > packages/organization/ansible/inventory/organization.ini; \
		echo "default ansible_connection=local" >> packages/organization/ansible/inventory/organization.ini; \
		echo "" >> packages/organization/ansible/inventory/organization.ini; \
		echo "[organization:children]" >> packages/organization/ansible/inventory/organization.ini; \
		echo "all" >> packages/organization/ansible/inventory/organization.ini; \
		echo "" >> packages/organization/ansible/inventory/organization.ini; \
		echo "[organization:vars]" >> packages/organization/ansible/inventory/organization.ini; \
		echo "ansible_python_interpreter=/usr/bin/python3" >> packages/organization/ansible/inventory/organization.ini; \
		echo "Created packages/organization/ansible/inventory/organization.ini"; \
	fi
	@echo "Ansible inventory setup complete"

build-base: build-base-rocky10
	@echo "Default base image (Rocky 10) built successfully"

build-base-rocky8: setup-ansible-inventory
	@echo "Building base Rocky 8 image..."
	@if [ "$(ARCH)" = "arm64" ] && [ "$(ROCKY8_ARM_COMPATIBLE)" = "false" ]; then \
		echo "ERROR: Rocky 8 is not compatible with ARM64 (Apple Silicon) architecture."; \
		echo "Please use Rocky 9 or Rocky 10 instead:"; \
		echo "  make build-base-rocky9"; \
		echo "  make build-base-rocky10"; \
		exit 1; \
	fi
	@mkdir -p packages/base/artifacts
	@rm -f packages/base/artifacts/base-rocky8.box
	cd packages/base/images/rocky8 && vagrant up $(PROVIDER_FLAG)
	cd packages/base/images/rocky8 && vagrant package --output ../../artifacts/base-rocky8.box
	@echo "Base image built: packages/base/artifacts/base-rocky8.box"

build-base-rocky9: setup-ansible-inventory
	@echo "Building base Rocky 9 image..."
	@mkdir -p packages/base/artifacts
	@rm -f packages/base/artifacts/base-rocky9.box
	cd packages/base/images/rocky9 && vagrant up $(PROVIDER_FLAG)
	cd packages/base/images/rocky9 && vagrant package --output ../../artifacts/base-rocky9.box
	@echo "Base image built: packages/base/artifacts/base-rocky9.box"

build-base-rocky10: setup-ansible-inventory
	@echo "Building base Rocky 10 image..."
	@mkdir -p packages/base/artifacts
	@rm -f packages/base/artifacts/base-rocky10.box
	cd packages/base/images/rocky10 && vagrant up $(PROVIDER_FLAG)
	cd packages/base/images/rocky10 && vagrant package --output ../../artifacts/base-rocky10.box
	@echo "Base image built: packages/base/artifacts/base-rocky10.box"

build-org-standard: setup-ansible-inventory
	@echo "Building standard organization spin..."
	@echo "Note: Ensure base image is built first"
	@if [ ! -f packages/base/artifacts/base-rocky10.box ]; then \
		echo "WARNING: Base Rocky 10 box not found. Building it first..."; \
		$(MAKE) build-base-rocky10; \
	fi
	cd packages/organization/spins/standard && vagrant up $(PROVIDER_FLAG)
	@echo "Standard spin ready"

build-all:
	@echo "Building all compatible images for $(ARCH) architecture..."
	@if [ "$(ARCH)" = "arm64" ]; then \
		echo "Skipping Rocky 8 (not compatible with ARM64)"; \
		$(MAKE) build-base-rocky9 && \
		$(MAKE) build-base-rocky10 && \
		$(MAKE) build-org-standard; \
	else \
		$(MAKE) build-base-rocky8 && \
		$(MAKE) build-base-rocky9 && \
		$(MAKE) build-base-rocky10 && \
		$(MAKE) build-org-standard; \
	fi
	@echo "All compatible base images and layers built successfully"

test:
	@echo "Running tests..."
	cd tests && ./run-all-tests.sh

test-base:
	@echo "Testing base layer..."
	cd packages/base/tests && ansible-playbook verify-base.yml

test-org:
	@echo "Testing organization layer..."
	cd packages/organization/tests && ansible-playbook verify-org.yml

clean:
	@echo "Cleaning Vagrant environments..."
	find packages -name ".vagrant" -type d -exec rm -rf {} + 2>/dev/null || true
	find packages -name "*.log" -type f -delete 2>/dev/null || true
	@echo "Cleanup complete"

clean-artifacts:
	@echo "Removing built artifacts..."
	find packages -path "*/artifacts/*" -type f -delete 2>/dev/null || true
	@echo "Artifacts removed"

setup-venv:
	@if [ ! -d .venv ]; then \
		echo "Creating Python virtual environment..."; \
		python3 -m venv .venv; \
		echo "Installing Ansible and ansible-lint..."; \
		.venv/bin/pip install -q --upgrade pip; \
		.venv/bin/pip install -q ansible ansible-lint; \
		echo "Installing Ansible collections..."; \
		.venv/bin/ansible-galaxy collection install -r requirements.yml > /dev/null 2>&1; \
		echo "✓ Virtual environment ready"; \
	else \
		echo "✓ Virtual environment already exists"; \
	fi

lint: setup-venv
	@echo "Linting Ansible playbooks..."
	@for playbook in $$(find packages -name "*.yml" -path "*/playbooks/*"); do \
		dir=$$(dirname $$playbook); \
		ansible_dir=$$(dirname $$dir); \
		playbook_name=$$(basename $$playbook); \
		(cd $$ansible_dir && $(PROJECT_ROOT)/.venv/bin/ansible-lint playbooks/$$playbook_name) || exit 1; \
	done
	@echo "All playbooks passed linting"

lint-ci:
	@echo "Linting Ansible playbooks (CI mode)..."
	@for playbook in $$(find packages -name "*.yml" -path "*/playbooks/*"); do \
		dir=$$(dirname $$playbook); \
		ansible_dir=$$(dirname $$dir); \
		playbook_name=$$(basename $$playbook); \
		(cd $$ansible_dir && ansible-lint playbooks/$$playbook_name) || exit 1; \
	done
	@echo "All playbooks passed linting"

validate: setup-venv
	@echo "Validating configurations..."
	@echo "Checking playbooks syntax..."
	@for playbook in $$(find packages -name "*.yml" -path "*/playbooks/*" -o -name "*.yml" -path "*/tests/*"); do \
		dir=$$(dirname $$playbook); \
		ansible_dir=$$(dirname $$dir); \
		playbook_name=$$(basename $$playbook); \
		echo "Validating $$playbook..."; \
		if [ -d "$$ansible_dir/roles" ]; then \
			ANSIBLE_ROLES_PATH=$$ansible_dir/roles $(PROJECT_ROOT)/.venv/bin/ansible-playbook --syntax-check $$playbook 2>&1 | grep -v "playbook:" | grep -v "\[WARNING\]: No inventory" | grep -v "\[WARNING\]: provided hosts list is empty" || exit 1; \
		else \
			$(PROJECT_ROOT)/.venv/bin/ansible-playbook --syntax-check $$playbook 2>&1 | grep -v "playbook:" | grep -v "\[WARNING\]: No inventory" | grep -v "\[WARNING\]: provided hosts list is empty" || exit 1; \
		fi; \
	done
	@echo "All playbooks passed validation"

init-program:
	@echo "Creating new program environment..."
	@read -p "Enter program name: " name; \
	cp -r packages/programs/templates/basic packages/programs/$$name; \
	echo "Program environment created at packages/programs/$$name"

setup-docs:
	@echo "Setting up documentation environment..."
	@if [ ! -d docs/.venv ]; then \
		echo "Creating virtual environment..."; \
		python3 -m venv docs/.venv; \
	fi
	@echo "Installing dependencies..."
	@docs/.venv/bin/pip install -q --upgrade pip
	@docs/.venv/bin/pip install -q -r docs/requirements.txt
	@echo "Documentation environment ready"

docs: setup-docs
	@echo "Building documentation..."
	cd docs && .venv/bin/mkdocs build

serve-docs: setup-docs
	@echo "Serving documentation at http://localhost:8000"
	cd docs && .venv/bin/mkdocs serve
