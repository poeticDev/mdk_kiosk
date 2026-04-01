

## Task 1 Findings

- **Flavor source sets** in Android Gradle: `android/app/src/<flavorName>/` is the standard directory for flavor-specific overrides. `kiosk` and `playstore` are already defined in `build.gradle` under `productFlavors`.
- **Manifest merging**: Flutter's Gradle plugin merges all flavor-level manifests with the main manifest. A flavor manifest can add new elements (like `<meta-data>`) without duplicating the full manifest.
- **Minimal override pattern**: For a single metadata addition, the minimal override is just `<manifest><application><meta-data ... /></application></manifest>`. The manifest merger will merge the `<application>` node into the main manifest's `<application>`.
- **Impeller disable**: `io.flutter.embedding.android.EnableImpeller` with `android:value="false"` is the standard manifest-based approach (Flutter docs). This is per-flavor-safe — only the kiosk build will include this override.
- **Playstore guard**: No `android/app/src/playstore/` directory or files were created; playstore flavor will use the main manifest as-is.

## Task 3 Findings

- **README structure**: Added new section `# rk3399 기기 Impeller 비활성화` after the Android Toolchain section, keeping release history intact.
- **Scope clarity**: Documentation explicitly states kiosk-only mitigation, playstore unchanged, avoiding any implication of universal Flutter bug.
- **Rollback documentation**: Two rollback paths documented - delete kiosk manifest file or remove the EnableImpeller metadata entry.
- **Flutter upgrade guardrail**: Added explicit note that Flutter major/minor upgrades require revalidating Impeller ON/OFF behavior on rk3399.
- **Commands documented**: Dev run command (`flutter run --flavor kiosk -d <device-id> --no-enable-impeller`) and release build command (`flutter build apk --flavor kiosk --release`) are both present.
- **Evidence logs created**: `.sisyphus/evidence/task-3-readme-rollout.log` and `.sisyphus/evidence/task-3-readme-rollback.log` verify all required content is present.
