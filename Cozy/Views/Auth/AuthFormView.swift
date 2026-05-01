import SwiftUI

enum AuthMode {
    case signUp, logIn
    var title: String { self == .signUp ? "Create Account" : "Welcome Back" }
    var buttonLabel: String { self == .signUp ? "Sign Up" : "Log In" }
}

struct AuthFormView: View {
    let mode: AuthMode
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var magicLinkSent = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    header
                    inputFields
                    if let err = errorMessage { errorBanner(err) }
                    if magicLinkSent { magicLinkBanner }
                    mainButton
                    magicLinkButton
                }
                .padding(24)
            }
        }
        .navigationBarBackButtonHidden(false)
        .tint(CozyTheme.primary)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(mode.title)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Text(mode == .signUp ? "Let's set up your cozy home" : "Good to see you again")
                .font(.system(size: 15))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    private var inputFields: some View {
        VStack(spacing: 14) {
            CozyTextField(placeholder: "Email", text: $email, icon: "envelope")
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            CozyTextField(placeholder: "Password", text: $password, icon: "lock", isSecure: true)
                .textContentType(mode == .signUp ? .newPassword : .password)
        }
    }

    private func errorBanner(_ msg: String) -> some View {
        Text(msg)
            .font(.system(size: 13))
            .foregroundColor(.red)
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.08))
            .cornerRadius(12)
    }

    private var magicLinkBanner: some View {
        Text("✉️ Check your email for a magic link!")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(CozyTheme.accent)
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(CozyTheme.accent.opacity(0.1))
            .cornerRadius(12)
    }

    private var mainButton: some View {
        Button { performAuth() } label: {
            Group {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(mode.buttonLabel)
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(CozyTheme.primary)
            .cornerRadius(CozyTheme.cornerRadius)
        }
        .disabled(isLoading)
    }

    private var magicLinkButton: some View {
        Button { sendMagicLink() } label: {
            Text("Send Magic Link instead")
                .font(.system(size: 15))
                .foregroundColor(CozyTheme.accent)
        }
        .disabled(isLoading)
    }

    private func performAuth() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                if mode == .signUp {
                    try await authManager.signUp(email: email, password: password)
                } else {
                    try await authManager.signIn(email: email, password: password)
                }
                appState.loadData()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func sendMagicLink() {
        guard !email.isEmpty else {
            errorMessage = "Enter your email first"
            return
        }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await authManager.sendMagicLink(email: email)
                magicLinkSent = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

// MARK: - Cozy Text Field
struct CozyTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String = ""
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .foregroundColor(CozyTheme.mutedText)
                    .frame(width: 20)
            }
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(.system(size: 16))
        .padding(16)
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cornerRadius)
        .overlay(RoundedRectangle(cornerRadius: CozyTheme.cornerRadius).stroke(CozyTheme.border, lineWidth: 1))
    }
}
