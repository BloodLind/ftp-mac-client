# Technical Architecture and Stack

## Goals
1. Native macOS experience with Finder-mounted volumes.
2. Stable architecture that supports incremental features without redesigns.
3. Clear separation of UI, core logic, protocol adapters, and system integration.

## Technology Stack
1. Language: Swift.
2. UI: SwiftUI with AppKit bridging for menu-bar behavior.
3. Finder Integration: macFUSE (user-space filesystem).
4. Protocols: FTP, FTPS, SFTP via protocol adapters.
5. Persistence: UserDefaults or SQLite for configs.
6. Credentials: macOS Keychain.
7. Logging: os_log.

## Module Boundaries

### UI Module
- Purpose: Presentation only.
- Files: `src/UI/TrayView.swift`, `src/UI/Controls/*`.
- View models: `src/Core/Domain/ViewModels/*`.
- Rules:
  1. All layout is in views.
  2. All commands and state live in view models.
  3. Custom UI controls live in `src/UI/Controls`.

### Core Modules

#### Connection Core
- Purpose: Orchestrates connect, disconnect, reconnect, and server list state.
- Files: `src/Core/Connection/*`.
- Owns connection lifecycles and exposes simple summaries for the UI.

#### FTP Core
- Purpose: Protocol adapters and high-level FTP operations.
- Files: `src/Core/FTP/*`.

##### Finder Integration Subcore
- Purpose: macOS-specific mount layer (FUSE) that Finder talks to.
- Files: `src/Core/FTP/FinderIntegration/*`.

#### Config Core
- Purpose: Persistent server configuration and app settings.
- Files: `src/Core/Config/*`.

#### Auth Core
- Purpose: Credential storage and retrieval via Keychain.
- Files: `src/Core/Auth/*`.

#### Utils Core
- Purpose: Cross-cutting utilities, logging, and common helpers.
- Files: `src/Core/Utils/*`.

## Data Flow
1. User actions in tray UI trigger `TrayViewModel` commands.
2. `TrayViewModel` calls into `ConnectionManager` (Connection Core).
3. `ConnectionManager` loads config from Config Core and credentials from Auth Core.
4. `ConnectionManager` selects the proper protocol adapter (FTP, FTPS, SFTP).
5. `FinderMountService` mounts a volume through macFUSE and delegates file ops to the adapter.
6. Status updates flow back to `TrayViewModel` as server summaries.

## Architectural Constraints
1. UI has no direct dependency on protocol adapters or macFUSE.
2. Protocol adapters are swapped based on `protocolType` without changing UI code.
3. Finder integration is isolated under `FinderIntegration` to avoid leaking macOS-specific APIs into core modules.
4. Config and credentials are stored separately to reduce accidental exposure of secrets.

## Extension Points
1. Add new protocols by implementing `FTPAdapter` and registering in Connection Core.
2. Add richer UI controls by placing components in `src/UI/Controls`.
3. Add caching layers within FTP Core without changing UI or Finder integration.
