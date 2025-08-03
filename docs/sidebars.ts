import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */
const sidebars: SidebarsConfig = {
  // Wiki sidebar for the Compostables mod
  wikiSidebar: [
    {
      type: 'doc',
      id: 'intro',
      label: 'Introduction',
    },
    {
      type: 'doc',
      id: 'installation',
      label: 'Installation',
    },
    {
      type: 'doc',
      id: 'usage',
      label: 'Usage Guide',
    },
    {
      type: 'doc',
      id: 'technical',
      label: 'Technical Details',
    },
    {
      type: 'doc',
      id: 'modrinth',
      label: 'Modrinth Description',
    },
    {
      type: 'category',
      label: 'Reference',
      collapsed: false,
      items: [
        {
          type: 'doc',
          id: 'reference/composter',
          label: 'Composter Reference',
        },
        {
          type: 'doc',
          id: 'reference/flowers',
          label: 'Flowers',
        },
        {
          type: 'doc',
          id: 'reference/food',
          label: 'Food Items',
        },
        {
          type: 'doc',
          id: 'reference/natural',
          label: 'Natural Blocks',
        },
        {
          type: 'doc',
          id: 'reference/saplings',
          label: 'Saplings',
        },
        {
          type: 'doc',
          id: 'reference/structural',
          label: 'Structural Blocks',
        },
      ],
    },
  ],

  // But you can create a sidebar manually
  /*
  tutorialSidebar: [
    'intro',
    'hello',
    {
      type: 'category',
      label: 'Tutorial',
      items: ['tutorial-basics/create-a-document'],
    },
  ],
   */
};

export default sidebars;
