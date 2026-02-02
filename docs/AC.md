# Acceptance Criteria

## Business Criteria
1. App runs on macOS and provides a menu-bar (tray) UI when active.
2. App can connect to FTP, FTPS, and SFTP servers and mount each as a filesystem volume visible in Finder.
3. Mounted volumes behave like normal Finder devices: users can browse, open, copy, paste, move, create, rename, and delete files/folders, subject to server permissions.
4. Finder interactions (drag-and-drop, context menu actions, Info panel) work on mounted volumes without errors.
5. Tray UI lists all configured server locations and shows connection status (connected/disconnected).
6. User can connect to a server from the tray UI and see the volume mount in Finder within a reasonable time (target under 10 seconds on typical connections).
7. User can disconnect a mounted server from the tray UI, and the volume unmounts cleanly in Finder.
8. User can reconnect a previously configured server from the tray UI without re-entering server details, unless credentials are missing or expired.
9. User can rename a configured location from the tray UI, and the new name appears in the tray list and Finder volume label.
10. App supports multiple simultaneous mounted locations, each as a separate Finder volume.
11. Tray actions are context-aware and disabled when not applicable.
12. When adding a new connection, the app displays an authorization form for host, protocol, port, username, and password or key file (SFTP).
13. Authorization form validates required fields and provides clear error messages for invalid input or failed authentication.
14. Connection failures (auth, network, timeout) are surfaced to the user with actionable feedback.
15. Configured locations persist across app restarts and remain visible in the tray list.
16. On app quit or system logout/restart, mounted volumes disconnect gracefully and do not leave Finder in a broken state.
17. No offline mode is provided; the app may use transient caching for performance but does not promise offline access.
18. Credentials are stored securely in macOS Keychain or the user is prompted on each connection if secure storage is disabled.

## Non-Functional Criteria
1. Performance: Mounting completes within 10 seconds on a typical broadband connection; directory listings for folders up to 1,000 items return within 3 seconds.
2. Reliability: App remains stable during prolonged use (8 hours) with multiple mounted volumes and no memory leaks that materially degrade performance.
3. Error Handling: Network interruptions do not crash the app; the user receives a clear status and can reconnect from the tray.
4. Security: Credentials are stored only in Keychain or not stored at all if user opts out; no plaintext credentials on disk.
5. Privacy: App does not transmit user data beyond the configured FTP, FTPS, or SFTP servers.
6. Compatibility: Works on the latest two macOS major versions available at release.
7. UX Responsiveness: Tray UI responds within 200 ms for common actions (open menu, select server, connect/disconnect).
8. Logging: User-readable logs are available for connection attempts and errors and do not include plaintext passwords.
9. Resource Usage: With one mounted volume idle, CPU usage stays below 2% and memory below 200 MB on a typical Mac.
10. Update Safety: App updates do not delete configured locations or saved credentials.
