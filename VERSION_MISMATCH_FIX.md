# Version Mismatch Issue - FIXED

## Problem

Release 1.0.40 was created with JAR files named `su-compostables-1.0.39-*.jar` instead of `su-compostables-1.0.40-*.jar`.

**Root Cause:**
- The `release` job (auto-version) was downloading JARs from `build-matrix` artifacts
- These JARs were built with version 1.0.39 (before auto-version bumped to 1.0.40)
- The release was tagged with 1.0.40 but contained 1.0.39 JARs

## Fix Applied

Updated `.github/workflows/build.yml`:
- Changed `release` job to **rebuild all JARs** with the new version (like `release-manual` does)
- Removed the "Download all versioned JARs" step
- Added "Build all Minecraft versions with new version" step
- Updated "Collect all versioned JARs" to use the new version directly

## Current Status

- ✅ **Workflow Fixed**: Future releases will have matching versions
- ⚠️ **Release 1.0.40**: Has wrong JAR versions (needs to be fixed/deleted)

## How to Fix Release 1.0.40

### Option 1: Delete and Recreate
```powershell
.\scripts\fix-bad-release.ps1 -Version "1.0.40" -Action delete
.\release.ps1 -Version "1.0.40"
```

### Option 2: Rebuild Automatically
```powershell
.\scripts\fix-bad-release.ps1 -Version "1.0.40" -Action rebuild
```

### Option 3: Manual GitHub Delete
1. Go to GitHub Releases
2. Delete release 1.0.40
3. Run: `.\release.ps1 -Version "1.0.40"`

## Verification

After fixing, verify with:
```powershell
.\scripts\check-release-status.ps1 -Tag "1.0.40"
```

All JAR files should be named `su-compostables-1.0.40-*.jar`

