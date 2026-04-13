import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var authManager: AuthManager

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var nameError = ""
    @State private var emailError = ""
    @State private var passwordError = ""
    @State private var isLoading = false
    @State private var generalError = ""

    var body: some View {
        ZStack {
            Color(hex: "FAF7F2").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    fieldsSection
                    createButton
                    divider
                    socialButtons
                    footerLinks
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 40)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Create your account")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Text("Takes about 2 minutes.")
                .font(.system(size: 15))
                .foregroundColor(CozyTheme.mutedText)
        }
    }

    private var fieldsSection: some View {
        VStack(spacing: 16) {
            CozyField(title: "Name", text: $name, error: $nameError,
                      contentType: .name, keyboard: .default)
            CozyField(title: "Email", text: $email, error: $emailError,
                      contentType: .emailAddress, keyboard: .emailAddress)
            passwordField
            if !generalError.isEmpty {
                Text(generalError)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .padding(.top, -8)
            }
        }
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Password").font(.system(size: 13, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
            HStack {
                if showPassword {
                    TextField("••••••••", text: $password)
                        .textContentType(.newPassword)
                        .autocapitalization(.none)
                } else {
                    SecureField("••••••••", text: $password)
                        .textContentType(.newPassword)
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

    private var createButton: some View {
        Button { Task { await signUp() } } label: {
            ZStack {
                Text("Create account")
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

    private var divider: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundColor(CozyTheme.border)
            Text("or").font(.system(size: 13)).foregroundColor(CozyTheme.mutedText).padding(.horizontal, 8)
            Rectangle().frame(height: 1).foregroundColor(CozyTheme.border)
        }
    }

    private var socialButtons: some View {
        VStack(spacing: 12) {
            Button {} label: {
                HStack(spacing: 10) {
                    Text("G").font(.system(size: 18, weight: .bold)).foregroundColor(Color(hex: "4285F4"))
                    Text("Continue with Google")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(CozyTheme.primary)
                }
                .frame(maxWidth: .infinity).frame(height: 50)
                .background(CozyTheme.card)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(CozyTheme.border, lineWidth: 1))
            }
            SignInWithAppleButton(.continue, onRequest: configureApple, onCompletion: handleApple)
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(12)
        }
    }

    private var footerLinks: some View {
        VStack(spacing: 10) {
            Button { appRouter.navigate(to: .login) } label: {
                Text("Already have an account? ")
                    .foregroundColor(CozyTheme.mutedText) +
                Text("Sign in").foregroundColor(CozyTheme.accent).bold()
            }
            .font(.system(size: 14))
            Text("By continuing you agree to our Terms of Service and Privacy Policy")
                .font(.system(size: 11))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions
    private func signUp() async {
        nameError = ""; emailError = ""; passwordError = ""; generalError = ""
        var valid = true
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "Name is required"; valid = false
        }
        if !email.contains("@") || !email.contains(".") {
            emailError = "Enter a valid email"; valid = false
        }
        if password.count < 6 {
            passwordError = "Password must be at least 6 characters"; valid = false
        }
        guard valid else { return }
        isLoading = true
        do {
            try await authManager.signUp(email: email, password: password)
            onboardingVM.userName = name.trimmingCharacters(in: .whitespaces)
            let hasSeen = UserDefaults.standard.bool(forKey: "hasSeenScienceScreen")
            appRouter.navigate(to: hasSeen ? .onboardingQ1 : .science)
        } catch {
            generalError = error.localizedDescription
        }
        isLoading = false
    }

    private func configureApple(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    private func handleApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let cred = auth.credential as? ASAuthorizationAppleIDCredential else { return }
            if let first = cred.fullName?.givenName {
                onboardingVM.userName = first
            }
            let hasSeen = UserDefaults.standard.bool(forKey: "hasSeenScienceScreen")
            appRouter.navigate(to: hasSeen ? .onboardingQ1 : .science)
        case .failure(let error):
            generalError = error.localizedDescription
        }
    }
}

// MARK: - Reusable CozyField
struct CozyField: View {
    let title: String
    @Binding var text: String
    @Binding var error: String
    var contentType: UITextContentType = .emailAddress
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 13, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
            TextField(title, text: $text)
                .textContentType(contentType)
                .keyboardType(keyboard)
                .autocapitalization(contentType == .name ? .words : .none)
                .padding(14)
                .background(CozyTheme.card)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(error.isEmpty ? CozyTheme.border : .red, lineWidth: 1))
            if !error.isEmpty {
                Text(error).font(.system(size: 12)).foregroundColor(.red)
            }
        }
    }
}
