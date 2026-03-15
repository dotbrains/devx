'use client';

import { Building2, Users, User, WifiOff, ShieldCheck, Zap } from 'lucide-react';

export function UseCasesSection() {
  const useCases = [
    {
      icon: <Building2 className="w-6 h-6" />,
      title: 'Organizations',
      description: 'Maintain consistent developer environments across teams. Enforce security policies, manage approved tooling, and support compliance requirements.',
    },
    {
      icon: <Users className="w-6 h-6" />,
      title: 'Teams',
      description: 'Quickly spin up project-specific environments. Inherit organization standards while customizing for project needs. Onboard new members in minutes.',
    },
    {
      icon: <User className="w-6 h-6" />,
      title: 'Individuals',
      description: 'Reproducible development environments isolated from your host. Experiment safely with different tool versions without polluting your machine.',
    },
    {
      icon: <WifiOff className="w-6 h-6" />,
      title: 'Airgap Deployment',
      description: 'Fully offline-capable with internal package mirrors, pre-packaged dependencies, and local repositories. No internet required after initial setup.',
    },
    {
      icon: <ShieldCheck className="w-6 h-6" />,
      title: 'Security Compliance',
      description: 'CIS-benchmarked base images, automated security scanning, license compliance tracking, and approval workflows for new packages.',
    },
    {
      icon: <Zap className="w-6 h-6" />,
      title: 'Fast Onboarding',
      description: 'New team members get a fully configured environment with one command. All tools, configs, and access pre-provisioned. Zero setup friction.',
    },
  ];

  return (
    <section id="use-cases" className="py-12 sm:py-16 lg:py-20 bg-dark-slate">
      <div className="max-w-7xl mx-auto px-4 sm:px-6">
        <div className="text-center mb-10 sm:mb-16">
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-cream mb-3 sm:mb-4">
            Use Cases
          </h2>
          <p className="text-cream/70 text-base sm:text-lg lg:text-xl max-w-3xl mx-auto">
            DevX scales from individual developers to enterprise organizations
          </p>
        </div>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6 lg:gap-8">
          {useCases.map((useCase, index) => (
            <div
              key={index}
              className="bg-dark-gray/50 border border-devx-teal/20 rounded-xl p-5 sm:p-6 hover:border-devx-cyan/40 transition-all"
            >
              <div className="w-10 h-10 sm:w-12 sm:h-12 bg-gradient-to-br from-devx-teal to-devx-cyan rounded-lg flex items-center justify-center text-white mb-3 sm:mb-4">
                {useCase.icon}
              </div>
              <h3 className="text-lg sm:text-xl font-semibold text-cream mb-2">{useCase.title}</h3>
              <p className="text-cream/60 text-sm sm:text-base leading-relaxed">{useCase.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
