# Agent notes

Native iOS Traceability. Keep RBAC in `Sources/TraceCore` aligned with the web farmer-traceability desk (`visibleRoutes`, portal scoping).

- UI: `App/` (SwiftUI)
- Core: `Sources/TraceCore` (roles, catalog, store)
- Tests: `swift test` (must stay green in CI before `xcodebuild`)
