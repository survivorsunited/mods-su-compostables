---
sidebar_position: 2
---

# Installation

Learn how to install the Compostables mod on your Minecraft server or client.

## Prerequisites

Before installing Compostables, ensure you have:

- Minecraft 1.21.5+ 
- Fabric Loader 0.16.14+
- Fabric API
- Java 21+

## Client Installation

### Using a Launcher (Recommended)

1. Install a mod launcher that supports Fabric:
   - [Prism Launcher](https://prismlauncher.org/)
   - [ATLauncher](https://atlauncher.com/)
   - [MultiMC](https://multimc.org/)

2. Create a new Fabric instance for Minecraft 1.21.5+

3. Download the required mods:
   - [Fabric API](https://modrinth.com/mod/fabric-api)
   - [Compostables](https://modrinth.com/mod/su-compostables)

4. Place both JAR files in the `mods` folder

5. Launch the game!

### Manual Installation

1. Download and run the [Fabric installer](https://fabricmc.net/use/)
2. Select Minecraft 1.21.5+ and install
3. Download [Fabric API](https://modrinth.com/mod/fabric-api) and [Compostables](https://modrinth.com/mod/su-compostables)
4. Place both JARs in `.minecraft/mods` folder
5. Launch Minecraft using the Fabric profile

## Server Installation

### For Server Owners

1. Download [Fabric server installer](https://fabricmc.net/use/server/)

2. Run the installer:
   ```bash
   java -jar fabric-installer.jar server -mcversion 1.21.5
   ```

3. Download required mods:
   - [Fabric API](https://modrinth.com/mod/fabric-api)
   - [Compostables](https://modrinth.com/mod/su-compostables)

4. Create a `mods` folder in your server directory

5. Place both JAR files in the `mods` folder

6. Start your server:
   ```bash
   java -Xmx4G -jar fabric-server-launch.jar nogui
   ```

### For Hosting Providers

Most hosting providers support Fabric servers. Simply:

1. Select Fabric 1.21.5+ as your server type
2. Upload Fabric API and Compostables to the mods folder
3. Restart your server

## Verification

To verify the mod is working:

1. Start Minecraft/server
2. Check the logs for "Initializing Compostables mod!"
3. Try composting rotten flesh in a composter
4. If it works, you're all set!

## Troubleshooting

### Mod Not Loading
- Ensure you have the correct Minecraft version (1.21.5+)
- Verify Fabric API is installed
- Check that Java 21+ is being used

### Crashes on Startup
- Update to the latest Fabric Loader
- Remove conflicting mods
- Check the crash report for details

### Items Not Composting
- Ensure you're using a composter block
- Verify the mod loaded successfully
- Check if other mods might be conflicting

## Compatibility

Compostables is compatible with:
- Most Fabric mods
- Vanilla clients (when installed on server)
- Major mod packs

Known incompatibilities:
- None currently reported