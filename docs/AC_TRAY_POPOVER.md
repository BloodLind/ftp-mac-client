# Tray Popover Acceptance Criteria

## Scope
1. This document defines acceptance criteria for the menu bar tray popover UI only.
2. It covers layout, states, and button behavior for the tray popover.
3. It does not define backend connection or filesystem mount implementation details.

## Popover Layout
1. Popover width matches the tray design spec (default 320 px).
2. The title "FTP Client" is visible at the top of the popover.
3. Each configured server appears as a row with:
   - Server display name.
   - Status label (e.g., Connected/Disconnected).
   - Connect and Disconnect actions.
4. The server list area and the action buttons are separated by a divider.
5. The "Add Server" and "Quit" buttons are on the same row and sized evenly.

## Button Visual Design
1. All buttons use a capsule shape and "liquid" Apple-style appearance.
2. Primary actions use prominent styling.
3. Secondary actions use bordered styling.
4. The Quit action uses a red destructive style.
5. Buttons maintain readable labels and accessible contrast in light and dark appearances.

## Button Behavior
1. Connect
   - Enabled only when a server is disconnected and credentials are valid.
   - When tapped, it initiates a connection for the selected server.
   - While connecting, the button shows a disabled state and prevents repeat taps.
2. Disconnect
   - Enabled only when a server is currently connected.
   - When tapped, it cleanly unmounts the associated Finder volume.
   - While disconnecting, the button shows a disabled state and prevents repeat taps.
3. Add Server
   - Opens the add-server flow (form/modal) from the tray.
   - The tray remains responsive while the form is presented.
4. Quit
   - Disconnects all mounted servers (clean unmount).
   - After all disconnects complete (or are safely terminated), the app exits.
   - If a disconnect fails, the user receives a clear error before exit or the app retries per policy.

## State & Feedback
1. Buttons are disabled when their action is not valid in the current state.
2. The status label updates to reflect connection state changes.
3. Errors surfaced from connect/disconnect are shown in the tray UI or via a system alert.

## Accessibility
1. Buttons have accessible labels matching their visible text.
2. The Quit button is marked as destructive for assistive technologies.
3. The popover supports keyboard navigation across all actionable controls.
