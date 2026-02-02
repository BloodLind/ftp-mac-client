import SwiftUI

struct TrayView: View {
    @StateObject private var viewModel: TrayViewModel

    init(viewModel: TrayViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FTP Client")
                .font(.headline)

            ForEach(viewModel.servers) { server in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(server.displayName)
                        Text(server.statusLabel)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button("Connect") { viewModel.connect(serverId: server.id) }
                        .disabled(!server.canConnect)
                    Button("Disconnect") { viewModel.disconnect(serverId: server.id) }
                        .disabled(!server.canDisconnect)
                }
            }

            Divider()

            Button("Add Server") { viewModel.presentAddServer() }
            Button("Quit") { viewModel.quitApp() }
        }
        .padding(12)
        .frame(width: 320)
    }
}

struct TrayView_Previews: PreviewProvider {
    static var previews: some View {
        TrayView(viewModel: TrayViewModel.preview())
    }
}
