import type { Metadata } from 'next';
import '@/styles/globals.css';

export const metadata: Metadata = {
  title: 'DevX — Secure Developer Environment Framework',
  description: 'A modular, layered framework for building secure, reproducible developer environments at scale. Three-tier architecture with Vagrant and Ansible.',
  openGraph: {
    title: 'DevX — Secure Developer Environment Framework',
    description: 'A modular, layered framework for building secure, reproducible developer environments at scale. Three-tier architecture with Vagrant and Ansible.',
    url: 'https://devx.dotbrains.io',
    siteName: 'DevX',
    images: [
      {
        url: '/og-image.svg',
        width: 1200,
        height: 630,
        alt: 'DevX — Secure Developer Environment Framework',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'DevX — Secure Developer Environment Framework',
    description: 'A modular, layered framework for building secure, reproducible developer environments at scale. Three-tier architecture with Vagrant and Ansible.',
    images: ['/og-image.svg'],
  },
  icons: {
    icon: [
      {
        url: '/favicon.svg',
        type: 'image/svg+xml',
      },
    ],
    apple: [
      {
        url: '/favicon.svg',
        type: 'image/svg+xml',
      },
    ],
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <meta charSet="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      </head>
      <body>{children}</body>
    </html>
  );
}
