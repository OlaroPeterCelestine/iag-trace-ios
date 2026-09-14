import SwiftUI
import TraceCore

struct LoginView: View {
    @EnvironmentObject var box: StoreBox
    @State private var username = ""
    @State private var password = ""
    @State private var error: String?
    @State private var showReset = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ZStack {
                        Color.black
                        IagBrandLogo(height: 132)
                            .padding(.vertical, 40)
                            .padding(.horizontal, 28)
                    }

                    VStack(spacing: 20) {
                        VStack(spacing: 6) {
                            Text(appName)
                                .font(.title.weight(.semibold))
                            Text("Sign in to farm, lots, and chain of custody.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 28)

                        VStack(spacing: 0) {
                            TextField("Username", text: $username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(16)
                            Divider().padding(.leading, 16)
                            SecureField("Password", text: $password)
                                .padding(16)
                        }
                        .iagCard()

                        Button("Forgot password?") { showReset = true }
                            .font(.footnote.weight(.medium))
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        if let error {
                            Text(error).font(.footnote).foregroundStyle(.red)
                        }

                        Button {
                            error = box.store.login(username, password)
                        } label: {
                            Text("Sign in")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(IagTheme.orange)
                        .controlSize(.large)

                        Text("Usernames include farmer, supplier, agent, and admin.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                }
            }
            .iagCanvas()
            .ignoresSafeArea(edges: .top)
            .sheet(isPresented: $showReset) {
                ResetPasswordView(username: username)
            }
        }
    }
}

struct ResetPasswordView: View {
    @EnvironmentObject var box: StoreBox
    @Environment(\.dismiss) private var dismiss
    @State var username: String
    @State private var password = ""
    @State private var confirm = ""
    @State private var error: String?
    @State private var done = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                SecureField("New password", text: $password)
                SecureField("Confirm", text: $confirm)
                if let error { Text(error).foregroundStyle(.red) }
                if done { Text("Password updated. Sign in with the new password.") }
            }
            .iagCanvas()
            .navigationTitle("Reset password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let err = box.store.resetPassword(username: username, newPassword: password, confirm: confirm) {
                            error = err
                            done = false
                        } else {
                            error = nil
                            done = true
                        }
                    }
                }
            }
        }
    }
}
