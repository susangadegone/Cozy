import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var emailError = ""
    @State private var passwordError = ""
    @State private var generalError = ""
    @State private var isLoading = false
    @State private var forgotSent = false

    var body: some View {
        ZStack {
            Color(hex: "FAF7F2").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    fieldsSection
                    forgotPasswordRow
                    signInButton
                    if !generalError.isEmpty {
                        Text(generalError)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    Spacer(minLength: 20)
                    footerLinks
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            if let saved = UserDefaults.standard.string(forKey: "lastUsedEmail"), !saved.isEmpty {
                email = saved
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome back")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Text("Sign in to your Cozy home.")
                .font(.system(size: 15))
                .foregroundColor(CozyTheme.mutedText)
        }
    }

    private var fieldsSection: some View {
        VStack(spacing: 16) {
            CozyField(title: "Email", text: $email, error: $emailError,
                      contentType: .emailAddress, keyboard: .emailAddress)
            passwordField
        }
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Password").font(.system(size: 13, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
            HStack {
                if showPassword {
                    TextField("••••••••", text: $password)
                        .textContentType(.password)
                        .autocapitalization(.none)
                } else {
                    SecureField("••••••••", text: $password)
                        .textContentType(.password)
                }
                Button { showPassword.toggle() } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(CozyTheme.mutedText)
                }
            }
            .padding(14)
            .background(CozyTheme.card)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(passwordError.isEmpty ? CozyTheme.border : .red, lineWidth: 1))
            if !passwordError.isEmpty {
                Text(passwordError).font(.system(size: 12)).foregroundColor(.red)
            }
        }
    }

    private var forgotPasswordRow: some View {
        Group {
            if forgotSent {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(Color(hex: "4CAF82"))
                    Text("Reset link sent — check your inbox.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "4CAF82"))
                }
            } else {
                Button {
                    guard email.contains("@") else { emailError = "Enter your email first"; return }
                    Task {
                        try? await authManager.sendMagicLink(email: email)
                        forgotSent = true
                    }
                } label: {
                    Text("Forgot password?")
                        .font(.system(size: 13))
                        .foregroundColor(CozyTheme.accent)
                        .underline()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var signInButton: some View {
        Button { Task { await signIn() } } label: {
            ZStack {
                Text("Sign in")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(isLoading ? 0 : 1)
                if isLoading { ProgressView().tint(.white) }
            }
            .frame(maxWidth: .infinity).frame(height: 54)
            .background(CozyTheme.primary)
            .cornerRadius(CozyTheme.cornerRadius)
        }
        .disabled(isLoading)
    }

    private var footerLinks: some View {
        VStack(spacing: 10) {
            Button { appRouter.navigate(to: .signUp) } label: {
                (Text("Don't have an account? ").foregroundColor(CozyTheme.mutedText) +
                 Text("Sign up").foregroundColor(CozyTheme.accent).bold())
            }
            .font(.system(size: 14))
        }
        .frame(maxWidth: .infinity)
    }

    private func signIn() async {
        emailError = ""; passwordError = ""; generalError = ""
        var valid = true
        if !email.contains("@") { emailError = "Enter a valid email"; valid = false }
        if password.isEmpty { passwordError = "Password is required"; valid = false }
        guard valid else { return }
        isLoading = true
        do {
            try await authManager.signIn(email: email, password: password)
            UserDefaults.standard.set(email, forKey: "lastUsedEmail")
            await appState.loadData()
            appRouter.navigate(to: .dashboard)
        } catch {
            generalError = error.localizedDescription
        }
        isLoading = false
    }
}
