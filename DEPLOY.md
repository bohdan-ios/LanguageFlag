# Version Update & Deploy

## 1. Update Version Numbers

Three places need the new version (e.g. `1.3`):

### Info.plist
<!-- path: LanguageFlag/Supporting files/Info.plist -->
```xml
<key>CFBundleShortVersionString</key>
<string>1.3</string>
<key>CFBundleVersion</key>
<string>1</string>
```
> Bump `CFBundleVersion` (build number) if shipping multiple builds of the same marketing version.

### project.pbxproj (Xcode)
Easiest via **Xcode → Target → General → Identity → Version**, which updates both Debug and Release configs automatically.

Alternatively, ensure `MARKETING_VERSION` matches in the `.pbxproj` for both configurations.

---

## 2. Commit & Push

```bash
git add -A
git commit -m "Bump version to 1.3"
git push origin main
```

---

## 3. Create a Git Tag to Trigger Release

The CI workflow (`.github/workflows/release.yml`) triggers on tags matching `v*`:

```bash
git tag v1.3
git push origin v1.3
```

This kicks off the release workflow which:

1. **Archives** the app with `xcodebuild archive` (Release config, ad-hoc signed)
2. **Zips** the `.app` into `LanguageFlag-1.3.zip` and `LanguageFlag.zip`
3. **Creates a GitHub Release** with auto-generated notes and both zip files attached
4. **Updates the Homebrew tap** (`bohdan-ios/homebrew-languageflag`) with the new version and SHA256

---

## 4. Monitor & Manage Release CI

```bash
# List recent release workflow runs
gh run list --workflow=release.yml -L 5

# Watch a run in real-time
gh run watch

# View logs of a failed run
gh run view <RUN_ID> --log-failed

# Re-run a failed release
gh run rerun <RUN_ID>
```

### Re-trigger a release (delete & recreate tag)

```bash
git tag -d v1.3
git push origin :refs/tags/v1.3
git tag v1.3
git push origin main --force
git push origin v1.3
```

---

## 5. Verify

- Check [GitHub Releases](https://github.com/bohdan-ios/LanguageFlag/releases) for the new release
- Verify Homebrew: `brew update && brew info languageflag`
- Test install: `brew install --cask bohdan-ios/languageflag/languageflag`
