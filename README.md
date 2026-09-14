# IAG Trace iOS

Native SwiftUI Farmer Traceability for iPhone and iPad: farmers, intake, lots, chain of custody, and the supplier portal — same RBAC as web **IAG Farmer Traceability**.

**Version:** `1.0.0` — [changelog](./CHANGELOG.md)

**Bundle ID:** `africa.iag.trace.ios`

## Links

- **README:** [https://github.com/OlaroPeterCelestine/iag-trace-ios#readme](https://github.com/OlaroPeterCelestine/iag-trace-ios#readme)
- **Repository:** [https://github.com/OlaroPeterCelestine/iag-trace-ios](https://github.com/OlaroPeterCelestine/iag-trace-ios)
- **Web Trace:** [https://github.com/OlaroPeterCelestine/iag-farmer-traceability#readme](https://github.com/OlaroPeterCelestine/iag-farmer-traceability#readme)
- **Trace Android:** [https://github.com/OlaroPeterCelestine/iag-trace-android#readme](https://github.com/OlaroPeterCelestine/iag-trace-android#readme)
- **Users & roles (Admin):** [https://github.com/OlaroPeterCelestine/iag-admin#readme](https://github.com/OlaroPeterCelestine/iag-admin#readme)
- **Workspace index:** [https://github.com/OlaroPeterCelestine/iagtools#readme](https://github.com/OlaroPeterCelestine/iagtools#readme)

## What this app is

The native iOS TraceIAG desk. `TraceCore` is the RBAC + records host. Staff get Overview / Work / Lots / More. Farmers and suppliers get My farm / Farms / Lots / Trace.

## Who it is for

Demo roles: `farmer`, `supplier`, `agent`, `admin` (and `superadmin`). Demo password: `iagdemo`.

- **Farmer / supplier** see only their own farms, lots, and batches. They can request harvest pickup. They cannot open staff registers or intake.
- **Agent** can intake farmers, inspect, collect, advance batches, and look up public lot codes.
- **Admin** has the same staff desk plus delete.

## What you can do

- Lookup `IAG-LOT-00421` for Nakato Grace (same public story as the desk `/trace` page).
- Web intake: farmer + farm + first batch at Intake.
- Advance lots Intake → Wet mill → Drying → Dry mill → Approved → Exported.
- QR publish stays gated: every batch in the export lot must be Approved or Exported.

```
Sources/TraceCore/    # RBAC, catalog, seed, store
App/                  # SwiftUI shell
Tests/TraceCoreTests/ # same cases as the web desk
```

## Architecture

```
Trace iOS (SwiftUI)
  → TraceCore (roles, registers, lots)
  → optional shared Go API (same JWT as web Trace)
```

## Identity and data

Sign in with an account from **IAG Admin** when the app is pointed at the shared API.
On-device demo data (UserDefaults) is only for local/offline trials — it is not the production directory.

Local demo password is `iagdemo`.

## Run locally

```bash
cd trace-ios
swift test
open TraceIOS.xcodeproj
```

In Xcode, select the **Trace iOS** scheme and run on an iPhone simulator.

```bash
xcodebuild -project TraceIOS.xcodeproj -scheme "Trace iOS" \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

CI matches web Trace: tests, then a Debug build.

## Stack

SwiftUI · Swift 5.9 · TraceCore RBAC · UserDefaults (local) · optional shared Go API.

## Related IAG systems

| System | GitHub | README |
| --- | --- | --- |
| IAG tools workspace | [iagtools](https://github.com/OlaroPeterCelestine/iagtools) | [README](https://github.com/OlaroPeterCelestine/iagtools#readme) |
| IAG Admin | [iag-admin](https://github.com/OlaroPeterCelestine/iag-admin) | [README](https://github.com/OlaroPeterCelestine/iag-admin#readme) |
| IAG Farmer Traceability | [iag-farmer-traceability](https://github.com/OlaroPeterCelestine/iag-farmer-traceability) | [README](https://github.com/OlaroPeterCelestine/iag-farmer-traceability#readme) |
| IAG Trace iOS ← this repo | [iag-trace-ios](https://github.com/OlaroPeterCelestine/iag-trace-ios) | [README](https://github.com/OlaroPeterCelestine/iag-trace-ios#readme) |
| IAG Trace Android | [iag-trace-android](https://github.com/OlaroPeterCelestine/iag-trace-android) | [README](https://github.com/OlaroPeterCelestine/iag-trace-android#readme) |
| ACP Farmers City iOS | [iag-acp-ios](https://github.com/OlaroPeterCelestine/iag-acp-ios) | [README](https://github.com/OlaroPeterCelestine/iag-acp-ios#readme) |
| ACP Farmers City Android | [iag-acp-android](https://github.com/OlaroPeterCelestine/iag-acp-android) | [README](https://github.com/OlaroPeterCelestine/iag-acp-android#readme) |
