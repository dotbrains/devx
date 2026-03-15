'use client';

import React, { useState } from 'react';
import { CodeBlock } from '@/components/CodeBlock';

export function CodeExamplesSection() {
  const [activeTab, setActiveTab] = useState<'build' | 'apps' | 'program'>('build');

  const examples = {
    build: `# Build a hardened base image (auto-detects provider)
$ make build-base-rocky10
→ Provider: parallels (Apple Silicon detected)
→ Building Rocky Linux 10 base image...
→ Applying security hardening...
→ SELinux: enforcing
→ Firewall: enabled
✓ Base image ready: packages/base/artifacts/base-rocky10.box

# Build organization spin (auto-builds base if needed)
$ make build-org-standard
→ Using base: base-rocky10.box
→ Installing App Store tools...
→ Setting up FOSS package system...
✓ Organization spin ready

# Run all tests
$ make test`,
    apps: `# packages/organization/ansible/group_vars/apps.yml
org_apps_to_install:
  - name: docker
    role: app-docker
    enabled: true
    config:
      version: "24.0"
      compose: true
      buildx: true

  - name: kubectl
    role: app-kubectl
    enabled: true
    config:
      version: "1.28"

  - name: python
    role: app-python
    enabled: true
    config:
      version: "3.11"
      pip_packages:
        - pytest
        - black
        - pylint

  - name: nodejs
    role: app-nodejs
    enabled: true
    config:
      version: "20"
      npm_packages:
        - yarn
        - typescript`,
    program: `# packages/programs/my-project/ansible/group_vars/all.yml
# Override organization defaults for this project
app_docker_version: "24.0.7"
app_nodejs_version: "20.10.0"

# Add project-specific apps
program_apps_to_install:
  - name: postgresql
    role: app-postgresql
    enabled: true
    config:
      version: "15"
      databases:
        - name: "myapp_dev"
          owner: "developer"

  - name: redis
    role: app-redis
    enabled: true
    config:
      version: "7.2"
      maxmemory: "256mb"`,
  };

  const tabs = [
    { key: 'build' as const, label: 'Build Images', language: 'bash' },
    { key: 'apps' as const, label: 'App Store Config', language: 'yaml' },
    { key: 'program' as const, label: 'Program Override', language: 'yaml' },
  ];

  return (
    <section id="code-examples" className="py-12 sm:py-16 lg:py-20 bg-dark-gray/50">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <div className="text-center mb-10 sm:mb-16">
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-cream mb-3 sm:mb-4">
            Code Examples
          </h2>
          <p className="text-cream/70 text-base sm:text-lg lg:text-xl max-w-3xl mx-auto">
            See DevX in action — building images, configuring apps, and customizing programs
          </p>
        </div>
        <div className="bg-dark-slate border border-devx-teal/30 rounded-xl overflow-hidden">
          <div className="flex border-b border-devx-teal/30 overflow-x-auto">
            {tabs.map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`flex-1 px-3 sm:px-6 py-3 sm:py-4 text-xs sm:text-sm font-semibold transition-colors whitespace-nowrap ${
                  activeTab === tab.key
                    ? 'bg-dark-gray/50 text-devx-teal border-b-2 border-devx-teal'
                    : 'text-cream/70 hover:text-cream hover:bg-dark-gray/30'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
          <div className="p-4 sm:p-6 overflow-x-auto">
            <CodeBlock
              code={examples[activeTab]}
              language={tabs.find((t) => t.key === activeTab)?.language}
            />
          </div>
        </div>
      </div>
    </section>
  );
}
