import SwiftUI

struct AddConnectionModalView: View {
    @ObservedObject var viewModel: AddConnectionViewModel

    var body: some View {
        VStack(spacing: 16) {
            AddConnectionModalHeaderView()
            AddConnectionFormView(viewModel: viewModel)
            if let message = viewModel.validationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            AddConnectionActionsView(viewModel: viewModel)
        }
        .padding(20)
        .frame(width: 420)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding()
    }
}

struct AddConnectionModalView_Previews: PreviewProvider {
    static var previews: some View {
        AddConnectionModalView(
            viewModel: AddConnectionViewModel(
                onCancel: {},
                onConnect: { _ in }
            )
        )
    }
}

extension ConnectionProtocolType {
    var tabTitle: String {
        switch self {
        case .sftp:
            return "SFTP"
        case .ftp:
            return "FTP"
        case .ftps:
            return "FTPS"
        case .s3:
            return "S3"
        case .smb:
            return "SMB"
        }
    }
}

struct AddConnectionModalHeaderView: View {
    var body: some View {
        HStack {
            Text("Add Connection")
                .font(.title3.weight(.semibold))
            Spacer()
        }
    }
}

struct AddConnectionFormView: View {
    @ObservedObject var viewModel: AddConnectionViewModel

    var body: some View {
        VStack(spacing: 14) {
            AddConnectionProtocolTabsView(
                selection: viewModel.selectedProtocol,
                onSelect: viewModel.selectProtocol
            )
            AddConnectionHostPortRowView(viewModel: viewModel)
            AddConnectionFieldView(
                title: "Username",
                placeholder: "user",
                text: $viewModel.username,
                isRequired: false,
                isSecure: false
            )
            AddConnectionFieldView(
                title: "Password",
                placeholder: "password",
                text: $viewModel.password,
                isRequired: false,
                isSecure: true
            )
            Divider()
            AddConnectionNameRowView(text: $viewModel.connectionName)
            AddConnectionSaveToggleView(isOn: $viewModel.saveConnection)
        }
    }
}

struct AddConnectionProtocolTabsView: View {
    let selection: ConnectionProtocolType
    let onSelect: (ConnectionProtocolType) -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ConnectionProtocolType.allCases) { option in
                Button(option.tabTitle) {
                    onSelect(option)
                }
                .buttonStyle(.bordered)
                .tint(option == selection ? .blue : .gray)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct AddConnectionHostPortRowView: View {
    @ObservedObject var viewModel: AddConnectionViewModel

    var body: some View {
        HStack(spacing: 12) {
            AddConnectionFieldView(
                title: "Host",
                placeholder: "ftp.example.com",
                text: $viewModel.host,
                isRequired: true,
                isSecure: false
            )
            .frame(maxWidth: .infinity)

            AddConnectionFieldView(
                title: "Port",
                placeholder: String(viewModel.selectedProtocol.defaultPort),
                text: $viewModel.port,
                isRequired: true,
                isSecure: false
            )
            .frame(width: 90)
        }
    }
}

struct AddConnectionFieldView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isRequired: Bool
    let isSecure: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if isRequired {
                    Text("*")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.roundedBorder)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}

struct AddConnectionNameRowView: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Button(action: {}) {
                Image(systemName: "folder")
            }
            .buttonStyle(.bordered)

            AddConnectionFieldView(
                title: "Connection Name",
                placeholder: "My Server",
                text: $text,
                isRequired: false,
                isSecure: false
            )
        }
    }
}

struct AddConnectionSaveToggleView: View {
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text("Save Connection")
                .font(.callout)
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle())
                .labelsHidden()
        }
    }
}

struct AddConnectionActionsView: View {
    @ObservedObject var viewModel: AddConnectionViewModel

    var body: some View {
        HStack(spacing: 12) {
            Button("Cancel") {
                viewModel.cancel()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            Button("Connect") {
                viewModel.connect()
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .disabled(!viewModel.canConnect)
            .frame(maxWidth: .infinity)
        }
    }
}
