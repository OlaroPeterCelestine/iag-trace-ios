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
                VStack(spacing: 16) {
                    Text("Trace iOS").font(.largeTitle.bold())
                    Text("IAG Farmer Traceability").font(.title3.weight(.semibold))
                    Text("Inspire Africa Group · farm to export lot")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Text("Demo: farmer, supplier, agent, admin — password iagdemo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    Button("Forgot password?") { showReset = true }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    if let error { Text(error).foregroundStyle(.red) }
                    Button("Sign in") {
                        error = box.store.login(username, password)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(iagOrange)
                }
                .padding(24)
            }
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
