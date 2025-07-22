# SU Craftable Name Tag Documentation

This directory contains the documentation website for the SU Craftable Name Tag mod, built with Docusaurus.

## What's inside?

This documentation site includes:

- **Introduction** - Overview of the mod and its features
- **Installation Guide** - Step-by-step installation instructions
- **Usage Guide** - How to use the mod and craft name tags
- **Blog** - Updates and announcements about the mod

## Local Development

```bash
cd docs
npm install
npm start
```

This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.

## Build

```bash
cd docs
npm run build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.

## Deployment

The documentation is automatically deployed to GitHub Pages when changes are pushed to the main branch. The deployment is handled by GitHub Actions.

## Search

The documentation includes a local search feature that allows users to search through all content without requiring an external search service.

## Contributing

To contribute to the documentation:

1. Make your changes in the `docs/docs/` directory
2. Test locally with `npm start`
3. Submit a pull request

The documentation follows the same contribution guidelines as the main project.
