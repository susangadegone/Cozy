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
    @State private var appeared = false

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    backButton
                    headerSection
                        .padding(.top, 12)
                    fieldsSection
                        .padding(.top, 32)
                    forgotPasswordRow
                        .padding(.top, 12)
                    signInButton
                        .padding(.top, 28)
                    errorBanner
                    Spacer(minLength: 32)
                    footerLinks
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if let saved = UserDefaults.standard.string(forKey: "lastUsedEmail"), !saved.isEmpty {
                email = saved
            }
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    // MARK: - Subviews

    private var backButton: some View {
        Button { appRouter.navigateBack() } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("Back")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(CozyTheme.accent)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome back")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(CozyTheme.primary)
            Text("Sign in to your Cozy home.")
                .font(.system(size: 16))
                .foregroundColor(CozyTheme.mutedText)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private var fieldsSection: some View {
        VStack(spacing: 14) {
            CozyField(title: "Email", placeholder: "you@example.com",
                      text: $email, error: $emailError,
                      contentType: .emailAddress, keyboard: .emailAddress)
            LoginPasswordField(password: $password, showPassword: $showPassword, error: $passwordError)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var forgotPasswordRow: some View {
        Group {
            if forgotSent {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(CozyTheme.teal)
                    Text("Reset link sent — check your inbox.")
                        .font(.system(size: 13))
                        .foregroundColor(CozyTheme.teal)
                }
            } else {
                Button {
                    guard email.contains("@") else { emailError = "Enter your email first"; return }
                    Task {
                        try? await authManager.sendMagicLink(email: email)
                        withAnimation { forgotSent = true }
                    }
                } label: {
                    Text("Forgot password?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(CozyTheme.accent)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var signInButton: some View {
        Button { Task { await signIn() } } label: {
            ZStack {
                RoundedRectangle(cornerRadius: CozyTheme.pillRadius)
                    .fill(CozyTheme.accent)
                    .frame(height: 54)
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Sign in")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(isLoading)
    }

    @ViewBuilder
    private var errorBanner: some View {
        if !generalError.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                Text(generalError)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
            }
            .padding(.top, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var footerLinks: some View {
        Button { appRouter.navigate(to: .signUp) } label: {
            Group {
                Text("Don't have an account? ")
                    .foregroundColor(CozyTheme.mutedText) +
                Text("Sign up")
                    .foregroundColor(CozyTheme.accent)
                    .bold()
            }
            .font(.system(size: 15))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Logic

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

// MARK: - Password field (login)

struct LoginPasswordField: View {
    @Binding var password: String
    @Binding var showPassword: Bool
    @Binding var error: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Password")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
            HStack {
                Group {
                    if showPassword {
                        TextField("••••••••", text: $password)
                            .textContentType(.password)
                            .autocapitalization(.none)
                    } else {
                        SecureField("••••••••", text: $password)
                            .textContentType(.password)
                    }
                }
                .font(.system(size: 16))
                Button { showPassword.toggle() } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(CozyTheme.mutedText)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(14)
            .background(CozyTheme.card)
            .cornerRadius(CozyTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                    .stroke(error.isEmpty ? CozyTheme.border : Color.red, lineWidth: 1)
            )
            if !error.isEmpty {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
        }
    }
}
