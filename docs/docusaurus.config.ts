import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: 'Compostables',
  tagline: 'A Minecraft Fabric mod that extends composting functionality',
  favicon: 'img/favicon.ico',

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url: 'https://survivorsunited.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/mods-su-compostables/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'survivorsunited', // Usually your GitHub org/user name.
  projectName: 'mods-su-compostables', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/survivorsunited/mods-su-compostables/tree/main/docs/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  plugins: [
    [
      '@easyops-cn/docusaurus-search-local',
      {
        hashed: true,
        language: ['en'],
        highlightSearchTermsOnTargetPage: true,
        explicitSearchResultPath: true,
        searchBarPosition: 'right',
      },
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/docusaurus-social-card.jpg',
    navbar: {
      title: 'Compostables',
      logo: {
        alt: 'Compostables Logo',
        src: 'img/icon.png',
        href: '/docs/intro',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'wikiSidebar',
          position: 'left',
          label: 'Wiki',
        },
        {
          href: 'https://github.com/survivorsunited/mods-su-compostables',
          label: 'GitHub',
          position: 'right',
        },
        {
          href: 'https://modrinth.com/mod/su-compostables',
          label: 'Modrinth',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentation',
          items: [
            {
              label: 'Introduction',
              to: '/docs/intro',
            },
            {
              label: 'Installation',
              to: '/docs/installation',
            },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/survivorsunited/mods-su-compostables',
            },
            {
              label: 'Modrinth',
              href: 'https://modrinth.com/mod/su-compostables',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Survivors United. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
