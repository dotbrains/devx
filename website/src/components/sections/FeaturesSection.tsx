'use client';

import { Layers, Store, Package, Shield, Globe, Terminal } from 'lucide-react';

export function FeaturesSection() {
  const features = [
    {
      icon: <Layers className="w-6 h-6" />,
      title: 'Layered Architecture',
      description: 'Three-tier model — Base, Organization, and Program layers. Each tier inherits and extends the previous through Ansible variable overrides.',
    },
    {
      icon: <Store className="w-6 h-6" />,
      title: 'App Store',
      description: 'Curated catalog of 17+ developer tools — Docker, Kubernetes, Python, Node.js, and more. Security-vetted and version-controlled.',
    },
    {
      icon: <Package className="w-6 h-6" />,
      title: 'FOSS Management',
      description: 'Complete ecosystem for managing vetted open-source packages with automated security scanning, license compliance, and internal mirrors.',
    },
    {
      icon: <Shield className="w-6 h-6" />,
      title: 'Security First',
      description: 'CIS-hardened base images with SELinux enforcement, firewall rules, and SSH hardening. No security weakening at higher tiers.',
    },
    {
      icon: <Globe className="w-6 h-6" />,
      title: 'REST API',
      description: 'Modern API for programmatic package management, registry operations, and automation. Full CRUD for packages and security metadata.',
    },
    {
      icon: <Terminal className="w-6 h-6" />,
      title: 'CLI Tools',
      description: 'Command-line interface for package discovery, submission, and management. Search, install, and audit packages from your terminal.',
    },
  ];

  return (
    <section id="features" className="py-12 sm:py-16 lg:py-20 bg-dark-slate">
      <div className="max-w-7xl mx-auto px-4 sm:px-6">
        <div className="text-center mb-10 sm:mb-16">
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-cream mb-3 sm:mb-4">
            Built for Enterprise Developer Environments
          </h2>
          <p className="text-cream/70 text-base sm:text-lg lg:text-xl max-w-3xl mx-auto">
            From hardened OS images to project-specific toolchains — everything is declarative, reproducible, and secure
          </p>
        </div>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6 lg:gap-8">
          {features.map((feature, index) => (
            <div
              key={index}
              className="group bg-dark-gray/50 border border-devx-teal/20 hover:border-devx-cyan/40 rounded-xl p-5 sm:p-6 transition-all hover:shadow-lg hover:shadow-devx-teal/10"
            >
              <div className="w-10 h-10 sm:w-12 sm:h-12 bg-gradient-to-br from-devx-teal to-devx-cyan rounded-lg flex items-center justify-center text-white mb-3 sm:mb-4 group-hover:scale-110 transition-transform">
                {feature.icon}
              </div>
              <h3 className="text-lg sm:text-xl font-semibold text-cream mb-2">{feature.title}</h3>
              <p className="text-cream/60 text-sm sm:text-base leading-relaxed">{feature.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
