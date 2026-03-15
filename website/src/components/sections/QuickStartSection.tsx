'use client';

import React from 'react';
import { CodeBlock } from '@/components/CodeBlock';

export function QuickStartSection() {
  return (
    <section id="quick-start" className="py-12 sm:py-16 lg:py-20 bg-dark-slate overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6">
        <div className="text-center mb-10 sm:mb-16">
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-cream mb-3 sm:mb-4">
            Quick Start
          </h2>
          <p className="text-slate-gray text-base sm:text-lg lg:text-xl max-w-3xl mx-auto">
            Get a fully configured developer environment in under 10 minutes
          </p>
        </div>
        <div className="grid lg:grid-cols-2 gap-8 lg:gap-12 items-start">
          <div className="bg-dark-gray/50 rounded-xl p-6 sm:p-8 border border-devx-teal/20 min-w-0">
            <h3 className="text-xl sm:text-2xl font-bold text-cream mb-4 sm:mb-6">1. Clone & Build</h3>
            <CodeBlock
              code={`# Clone the repository
git clone https://github.com/dotbrains/devx.git
cd devx

# Build the base image (auto-detects provider)
make build-base-rocky10

# Build organization spin with developer tools
make build-org-standard`}
              language="bash"
            />
            <div className="mt-6 bg-devx-teal/10 border border-devx-teal/30 rounded-lg p-4 sm:p-5">
              <p className="text-cream text-sm leading-relaxed">
                <span className="text-devx-teal font-semibold">Prerequisites:</span> Install{' '}
                <a href="https://www.vagrantup.com/" target="_blank" rel="noopener noreferrer" className="text-devx-sky underline">Vagrant</a>,{' '}
                <a href="https://www.virtualbox.org/" target="_blank" rel="noopener noreferrer" className="text-devx-sky underline">VirtualBox</a> (or Parallels on Apple Silicon), and{' '}
                <a href="https://www.ansible.com/" target="_blank" rel="noopener noreferrer" className="text-devx-sky underline">Ansible</a>.
              </p>
            </div>
          </div>
          <div className="bg-dark-gray/50 rounded-xl p-6 sm:p-8 border border-devx-cyan/20 min-w-0">
            <h3 className="text-xl sm:text-2xl font-bold text-cream mb-4 sm:mb-6">2. Use Your Environment</h3>
            <CodeBlock
              code={`# Create a new program environment
make init-program
# Enter name: my-project

# Start the environment
cd packages/programs/my-project
vagrant up

# SSH in — all tools pre-installed
vagrant ssh

# Verify installed tools
docker --version
kubectl version --client
python3 --version
node --version`}
              language="bash"
            />
            <div className="mt-6 bg-devx-cyan/10 border border-devx-cyan/30 rounded-lg p-4 sm:p-5">
              <p className="text-cream text-sm leading-relaxed">
                <span className="text-devx-sky font-semibold">Tip:</span> Customize your environment by editing <code className="bg-dark-slate/80 px-2 py-1 rounded text-devx-sky font-mono text-xs">ansible/group_vars/all.yml</code> then run <code className="bg-dark-slate/80 px-2 py-1 rounded text-devx-sky font-mono text-xs">vagrant provision</code>
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
