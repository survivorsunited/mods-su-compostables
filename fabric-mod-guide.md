# Complete Guide: Creating a Minecraft Fabric Mod with CI/CD Pipeline and Documentation

This guide walks through creating a complete Minecraft Fabric mod project with automated builds, releases, and documentation using modern development practices.

## Table of Contents
1. [Project Setup](#project-setup)
2. [Mod Development](#mod-development)
3. [Build Configuration](#build-configuration)
4. [CI/CD Pipeline](#cicd-pipeline)
5. [Documentation Site](#documentation-site)
6. [Release Process](#release-process)
7. [Best Practices](#best-practices)

## Project Setup

### Prerequisites
- **Java 21** (required for modern Fabric mods)
- **Git** for version control
- **GitHub** account for hosting and CI/CD
- **Node.js 18+** for documentation site

### Initial Project Structure
```
mod-project/
├── .github/workflows/
├── docs/
├── gradle/
├── src/main/java/
├── src/main/resources/
├── build.gradle
├── gradle.properties
├── settings.gradle
└── README.md
```

### 1. Create Basic Project Files

#### `gradle.properties`
```properties
# Gradle settings
org.gradle.jvmargs=-Xmx1G
org.gradle.parallel=true

# Fabric Properties
minecraft_version=1.21.6
yarn_mappings=1.21.6+build.1
loader_version=0.16.14
loom_version=1.10-SNAPSHOT

# Mod Properties
mod_version=1.0.0
maven_group=org.survivorsunited
archives_base_name=su-mod

# Dependencies
fabric_version=0.127.1+1.21.6
```

#### `settings.gradle`
```gradle
pluginManagement {
    repositories {
        maven {
            name = 'Fabric'
            url = 'https://maven.fabricmc.net/'
        }
        mavenCentral()
        gradlePluginPortal()
    }
}

rootProject.name = 'my-mod'
```

#### `build.gradle`
```gradle
plugins {
    id 'fabric-loom' version "${loom_version}"
    id 'maven-publish'
}

version = project.mod_version
group = project.maven_group

base {
    archivesName = project.archives_base_name
}

repositories {
    // Add repositories here if needed
}

loom {
    mods {
        "my-mod" {
            sourceSet sourceSets.main
        }
    }
}

dependencies {
    minecraft "com.mojang:minecraft:${project.minecraft_version}"
    mappings "net.fabricmc:yarn:${project.yarn_mappings}:v2"
    modImplementation "net.fabricmc:fabric-loader:${project.loader_version}"
    modImplementation "net.fabricmc.fabric-api:fabric-api:${project.fabric_version}"
}

processResources {
    inputs.property "version", project.version
    filesMatching("fabric.mod.json") {
        expand "version": inputs.properties.version
    }
}

tasks.withType(JavaCompile).configureEach {
    it.options.release = 21
}

java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}

jar {
    from("LICENSE") {
        rename { "${it}_${project.base.archivesName}"}
    }
}

publishing {
    publications {
        create("mavenJava", MavenPublication) {
            artifactId = project.archives_base_name
            from components.java
        }
    }
}
```

### 2. Create Main Mod Class

#### `src/main/java/com/example/mymod/MyMod.java`
```java
package org.survivorsunited.mymod;

import net.fabricmc.api.ModInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MyMod implements ModInitializer {
    public static final String MOD_ID = "my-mod";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitialize() {
        LOGGER.info("My Mod initialized!");
    }
}
```

### 3. Create Mod Metadata

#### `src/main/resources/fabric.mod.json`
```json
{
    "schemaVersion": 1,
    "id": "my-mod",
    "version": "${version}",
    "name": "My Mod",
    "description": "A Minecraft Fabric mod",
    "authors": ["Your Name"],
    "contact": {
        "homepage": "https://github.com/yourusername/my-mod",
        "sources": "https://github.com/yourusername/my-mod"
    },
    "license": "MIT",
    "icon": "assets/my-mod/icon.png",
    "environment": "*",
    "entrypoints": {
        "main": ["org.survivorsunited.mymod.MyMod"]
    },
    "depends": {
        "fabricloader": ">=0.16.14",
        "minecraft": "~1.21.6",
        "java": ">=21",
        "fabric-api": "*"
    }
}
```

## Mod Development

### Adding Recipes

Create JSON recipes in `src/main/resources/data/{modid}/recipes/`:

#### `src/main/resources/data/my-mod/recipes/example_item.json`
```json
{
    "type": "minecraft:crafting_shaped",
    "pattern": [
        "SSS",
        "S S",
        "SSS"
    ],
    "key": {
        "S": "minecraft:stone"
    },
    "result": {
        "item": "minecraft:diamond",
        "count": 1
    }
}
```

### Adding Localization

#### `src/main/resources/assets/my-mod/lang/en_us.json`
```json
{
    "item.minecraft.example_item": "Example Item",
    "recipe.my-mod.example_item": "Example Item"
}
```

## Build Configuration

### Local Build Script

#### `build.ps1` (Windows)
```powershell
# Set the correct JDK 21 path
$jdkPath = "C:\path\to\your\jdk-21"
$env:JAVA_HOME = $jdkPath
$env:Path = "$jdkPath\bin;" + $env:Path

Write-Host "JAVA_HOME set to $jdkPath"

# Build the mod
./gradlew build

# Optionally run client
# ./gradlew runClient
```

#### `build.sh` (Linux/Mac)
```bash
#!/bin/bash
export JAVA_HOME=/path/to/your/jdk-21
export PATH=$JAVA_HOME/bin:$PATH

echo "JAVA_HOME set to $JAVA_HOME"

# Build the mod
./gradlew build

# Optionally run client
# ./gradlew runClient
```

## CI/CD Pipeline

### GitHub Actions Workflow

#### `.github/workflows/build.yml`
```yaml
name: build
on: [pull_request, push]

jobs:
  build:
    runs-on: ubuntu-24.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'microsoft'

      - name: Validate Gradle Wrapper
        uses: gradle/actions/wrapper-validation@v4

      - name: Make Gradle executable
        run: chmod +x ./gradlew

      - name: Build project
        run: ./gradlew build

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: Artifacts
          path: build/libs/

  docs:
    runs-on: ubuntu-24.04
    permissions:
      contents: read
      pages: write
      id-token: write
    concurrency:
      group: "pages"
      cancel-in-progress: false
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: docs/package-lock.json

      - name: Setup Pages
        uses: actions/configure-pages@v4

      - name: Install dependencies
        run: |
          cd docs
          npm ci

      - name: Build documentation
        run: |
          cd docs
          npm run build

      - name: Upload Pages artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./docs/build

  deploy-docs:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-24.04
    needs: docs
    if: github.ref == 'refs/heads/main'
    permissions:
      pages: write
      id-token: write
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4

  release:
    needs: [build, docs]
    if: startsWith(github.ref, 'refs/tags/')
    runs-on: ubuntu-24.04
    permissions:
      contents: write
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'microsoft'

      - name: Validate Gradle Wrapper
        uses: gradle/actions/wrapper-validation@v4

      - name: Make Gradle executable
        run: chmod +x ./gradlew

      - name: Build project
        run: ./gradlew build

      - name: Generate changelog
        id: changelog
        run: |
          if git describe --tags --abbrev=0 HEAD^ 2>/dev/null; then
            PREV_TAG=$(git describe --tags --abbrev=0 HEAD^)
            CHANGELOG="## Changes in ${{ github.ref_name }}"
            CHANGELOG="$CHANGELOG"$'\n'
            CHANGELOG="$CHANGELOG$(git log --pretty=format:'- %s' $PREV_TAG..HEAD)"
          else
            CHANGELOG="## Initial Release ${{ github.ref_name }}"
            CHANGELOG="$CHANGELOG"$'\n'
            CHANGELOG="$CHANGELOG- Initial release"
          fi
          echo "changelog<<EOF" >> $GITHUB_OUTPUT
          echo "$CHANGELOG" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ github.ref_name }}
          name: Release ${{ github.ref_name }}
          body: ${{ steps.changelog.outputs.changelog }}
          files: build/libs/*.jar
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Publish to Modrinth
        uses: cloudnode-pro/modrinth-publish@v2
        with:
          token: ${{ secrets.MODRINTH_TOKEN }}
          project: ${{ secrets.PROJECT_ID }}
          loaders: fabric
          files: build/libs/*.jar
          version: ${{ github.ref_name }}
          changelog: ${{ steps.changelog.outputs.changelog }}
          game-versions: |-
            1.21.x
          featured: true
          channel: release
```

## Documentation Site

### Setup Docusaurus

#### Initialize Documentation
```bash
npx create-docusaurus@latest docs classic --typescript
cd docs
npm install @easyops-cn/docusaurus-search-local
```

#### `docs/docusaurus.config.ts`
```typescript
import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'My Mod',
  tagline: 'A Minecraft Fabric mod',
  favicon: 'img/icon.png',
  url: 'https://yourusername.github.io',
  baseUrl: '/my-mod/',
  organizationName: 'yourusername',
  projectName: 'my-mod',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

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
          editUrl: 'https://github.com/yourusername/my-mod/tree/main/docs/',
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
    navbar: {
      title: 'My Mod',
      logo: {
        alt: 'My Mod Logo',
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
          href: 'https://github.com/yourusername/my-mod',
          label: 'GitHub',
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
              href: 'https://github.com/yourusername/my-mod',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Your Name. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
```

#### `docs/sidebars.ts`
```typescript
import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
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
      id: 'faq',
      label: 'FAQ',
    },
  ],
};

export default sidebars;
```

#### `docs/src/pages/index.tsx`
```typescript
import {useEffect} from 'react';
import {useHistory} from '@docusaurus/router';

export default function Home() {
  const history = useHistory();
  useEffect(() => {
    history.replace('/docs/intro');
  }, [history]);
  return null;
}
```

### Create Documentation Pages

#### `docs/docs/intro.md`
```markdown
---
sidebar_position: 1
---

# Introduction

Welcome to My Mod! This mod adds [describe your mod's features].

## Features

- Feature 1
- Feature 2
- Feature 3

## Quick Start

1. Install the mod
2. Start Minecraft
3. Enjoy the new features!

## Crafting Recipe

[Describe your crafting recipe here]
```

#### `docs/docs/installation.md`
```markdown
---
sidebar_position: 2
---

# Installation

## Prerequisites

- Minecraft 1.21.6
- Fabric Loader 0.16.14+
- Fabric API

## Installation Steps

### For Players

1. Download the mod JAR file
2. Place it in your `mods` folder
3. Start Minecraft

### For Server Owners

1. Download the mod JAR file
2. Place it in your server's `mods` folder
3. Restart the server
```

## Release Process

### 1. Update Version
Edit `gradle.properties`:
```properties
mod_version=1.0.1
```

### 2. Commit Changes
```bash
git add .
git commit -m "Release version 1.0.1"
git push origin main
```

### 3. Create and Push Tag
```bash
git tag 1.0.1
git push origin 1.0.1
```

### 4. Automated Release
The CI/CD pipeline will automatically:
- Build the mod
- Generate changelog from Git history
- Create GitHub release
- Publish to Modrinth
- Deploy documentation updates

## Best Practices

### Code Organization
- Keep mod logic simple and focused
- Use JSON recipes when possible
- Follow Minecraft/Fabric naming conventions
- Use proper logging with SLF4J

### Version Management
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Update version in `gradle.properties`
- Create Git tags for releases
- Generate changelogs automatically

### Documentation
- Keep documentation up-to-date with code changes
- Use clear, concise language
- Include code examples
- Test documentation locally before pushing

### CI/CD
- Use staged pipelines (build → docs → release)
- Generate dynamic changelogs
- Test on multiple platforms
- Automate publishing to multiple platforms

### Security
- Never commit API keys or secrets
- Use GitHub Secrets for sensitive data
- Validate all inputs
- Follow security best practices

## Troubleshooting

### Common Issues

#### Build Failures
- Ensure Java 21 is installed and set in `JAVA_HOME`
- Check that all dependencies are correctly specified
- Verify Gradle wrapper version compatibility

#### CI/CD Issues
- Check GitHub Actions logs for specific errors
- Verify repository secrets are set correctly
- Ensure proper permissions are configured

#### Documentation Issues
- Test documentation build locally: `cd docs && npm run build`
- Check for broken links and images
- Verify Docusaurus configuration

### Getting Help
- Check the [Fabric documentation](https://fabricmc.net/wiki/)
- Review [GitHub Actions documentation](https://docs.github.com/en/actions)
- Consult [Docusaurus documentation](https://docusaurus.io/docs)

## Conclusion

This guide provides a complete foundation for creating a professional Minecraft Fabric mod with automated builds, releases, and documentation. By following these patterns, you can create maintainable, well-documented mods that are easy to distribute and update.

Remember to:
- Test thoroughly before releasing
- Keep documentation updated
- Follow security best practices
- Use semantic versioning
- Automate repetitive tasks

Happy modding! 