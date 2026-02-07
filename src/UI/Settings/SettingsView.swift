import AppKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SettingsSectionHeaderView(title: "General")
                SettingsCardView {
                    SettingsToggleRowView(
                        title: "Launch at login",
                        subtitle: "Automatically start the client when you sign in",
                        isOn: $viewModel.launchAtLogin
                    )
                    Divider()
                    SettingsToggleRowView(
                        title: "Show in Menu Bar",
                        subtitle: "Show status icon in the macOS menu bar",
                        isOn: $viewModel.showInMenuBar
                    )
                }

                SettingsSectionHeaderView(title: "Connections")
                SettingsCardView {
                    SettingsPickerRowView(
                        title: "Default Protocol",
                        selection: $viewModel.defaultProtocol
                    )
                    Divider()
                    SettingsToggleRowView(
                        title: "Auto-reconnect",
                        subtitle: "Attempt to restore connection on drops",
                        isOn: $viewModel.autoReconnect
                    )
                }

                SettingsSectionHeaderView(title: "Support")
                SupportCardView()
            }
            .padding(20)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel())
            .frame(width: 700, height: 500)
    }
}

struct SettingsSectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SettingsToggleRowView: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.callout.weight(.medium))
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

struct SettingsPickerRowView: View {
    let title: String
    @Binding var selection: ConnectionProtocolType

    var body: some View {
        HStack {
            Text(title)
                .font(.callout.weight(.medium))
            Spacer()
            Picker("", selection: $selection) {
                ForEach(ConnectionProtocolType.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .labelsHidden()
            .frame(width: 160)
        }
        .padding(.vertical, 8)
    }
}

struct SettingsCardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct SupportCardView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "ant")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.accentColor)
            Text("Encountered an issue?")
                .font(.callout.weight(.semibold))
            Text("Our team is ready to help squash bugs and improve your experience.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Report a Bug") {}
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
