'use client';

import { HardDrive, Building2, FolderGit2 } from 'lucide-react';

export function ArchitectureSection() {
  const tiers = [
    {
      icon: <HardDrive className="w-8 h-8" />,
      tier: '1',
      title: 'Base Layer',
      subtitle: 'Hardened OS Foundation',
      description: 'Rocky Linux images with CIS security benchmarks, SELinux enforcement, minimal package set, and airgap compatibility. The secure foundation for everything above.',
      details: ['Security hardening', 'SELinux & firewall', 'Minimal packages', 'Airgap ready'],
    },
    {
      icon: <Building2 className="w-8 h-8" />,
      tier: '2',
      title: 'Organization Layer',
      subtitle: 'Developer Tools & Standards',
      description: 'Curated App Store with 17+ tools, FOSS package ecosystem with security scanning, and organization-wide spins for consistent environments.',
      details: ['App Store catalog', 'FOSS packages', 'Security vetting', 'Org spins'],
    },
    {
      icon: <FolderGit2 className="w-8 h-8" />,
      tier: '3',
      title: 'Program Layer',
      subtitle: 'Project-Specific Configs',
      description: 'Project-specific tool versions, custom application stacks, team workflows, and CI/CD integration. Override any setting from lower tiers.',
      details: ['Custom toolchains', 'Version overrides', 'Team workflows', 'CI/CD integration'],
    },
  ];

  return (
    <section id="architecture" className="py-12 sm:py-16 lg:py-20 bg-dark-gray/50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6">
        <div className="text-center mb-10 sm:mb-16">
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-cream mb-3 sm:mb-4">
            Three-Tier Architecture
          </h2>
          <p className="text-cream/70 text-base sm:text-lg lg:text-xl max-w-3xl mx-auto">
            Each layer inherits, extends, and can override the previous — progressive customization with security guarantees
          </p>
        </div>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6 sm:gap-8">
          {tiers.map((tier, index) => (
            <div key={index} className="relative sm:col-span-2 lg:col-span-1 last:sm:col-start-auto last:lg:col-start-auto">
              <div className="bg-dark-slate border border-devx-teal/30 rounded-xl p-6 sm:p-8 text-center hover:border-devx-cyan/40 transition-all h-full">
                <div className="w-14 h-14 sm:w-16 sm:h-16 bg-gradient-to-br from-devx-teal to-devx-cyan rounded-full flex items-center justify-center text-white text-xl sm:text-2xl font-bold mx-auto mb-3 sm:mb-4">
                  {tier.tier}
                </div>
                <div className="w-10 h-10 sm:w-12 sm:h-12 mx-auto mb-3 sm:mb-4 text-devx-teal flex items-center justify-center">
                  {tier.icon}
                </div>
                <h3 className="text-lg sm:text-xl font-semibold text-cream mb-1">{tier.title}</h3>
                <p className="text-devx-sky text-sm font-medium mb-2 sm:mb-3">{tier.subtitle}</p>
                <p className="text-cream/60 text-sm sm:text-base leading-relaxed mb-4">{tier.description}</p>
                <div className="flex flex-wrap justify-center gap-2">
                  {tier.details.map((detail, i) => (
                    <span key={i} className="text-xs px-2.5 py-1 bg-devx-teal/10 border border-devx-teal/20 rounded-full text-devx-sky">
                      {detail}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
        {/* Flow arrow indicator */}
        <div className="mt-8 text-center">
          <p className="text-cream/50 text-sm">
            Configuration flows upward: Base defaults → Organization overrides → Program overrides
          </p>
        </div>
      </div>
    </section>
  );
}
