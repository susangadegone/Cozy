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
                    createButton
                        .padding(.top, 28)
                    dividerRow
                        .padding(.top, 24)
                    socialButtons
                        .padding(.top, 16)
                    Spacer(minLength: 32)
                    footerLinks
                        .padding(.top, 24)
                    termsText
                        .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
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
            Text("Create your account")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(CozyTheme.primary)
            Text("Takes about 2 minutes.")
                .font(.system(size: 16))
                .foregroundColor(CozyTheme.mutedText)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private var fieldsSection: some View {
        VStack(spacing: 14) {
            CozyField(title: "Your name", placeholder: "Alex",
                      text: $name, error: $nameError,
                      contentType: .name, keyboard: .default)
            CozyField(title: "Email", placeholder: "you@example.com",
                      text: $email, error: $emailError,
                      contentType: .emailAddress, keyboard: .emailAddress)
            SignUpPasswordField(password: $password, showPassword: $showPassword, error: $passwordError)
            if !generalError.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(generalError)
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var createButton: some View {
        Button { Task { await signUp() } } label: {
            ZStack {
                RoundedRectangle(cornerRadius: CozyTheme.pillRadius)
                    .fill(CozyTheme.accent)
                    .frame(height: 54)
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Create account")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(isLoading)
    }

    private var dividerRow: some View {
        HStack(spacing: 12) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(CozyTheme.border)
            Text("or")
                .font(.system(size: 13))
                .foregroundColor(CozyTheme.mutedText)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(CozyTheme.border)
        }
    }

    private var socialButtons: some View {
        VStack(spacing: 12) {
            googleButton
            SignInWithAppleButton(.continue, onRequest: configureApple, onCompletion: handleApple)
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(CozyTheme.cornerRadius)
        }
    }

    private var googleButton: some View {
        Button {} label: {
            HStack(spacing: 10) {
                Text("G")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "4285F4"))
                Text("Continue with Google")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CozyTheme.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(CozyTheme.card)
            .cornerRadius(CozyTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                    .stroke(CozyTheme.border, lineWidth: 1)
            )
        }
    }

    private var footerLinks: some View {
        Button { appRouter.navigate(to: .login) } label: {
            Group {
                Text("Already have an account? ")
                    .foregroundColor(CozyTheme.mutedText) +
                Text("Sign in")
                    .foregroundColor(CozyTheme.accent)
                    .bold()
            }
            .font(.system(size: 15))
        }
        .frame(maxWidth: .infinity)
    }

    private var termsText: some View {
        Text("By continuing you agree to our Terms of Service and Privacy Policy")
            .font(.system(size: 11))
            .foregroundColor(CozyTheme.mutedText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Logic

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
            passwordError = "At least 6 characters required"; valid = false
        }
        guard valid else { return }
        isLoading = true
        do {
            try await authManager.signUp(email: email, password: password)
            let trimmedName = name.trimmingCharacters(in: .whitespaces)
            onboardingVM.userName = trimmedName
            // Create a profile row immediately so onboarding data has a home
            if authManager.currentUserId != nil {
                let p = LocalStore.shared.defaultProfile()
                try? await DataService.shared.createProfile(p)
            }
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
            if let first = cred.fullName?.givenName { onboardingVM.userName = first }
            let hasSeen = UserDefaults.standard.bool(forKey: "hasSeenScienceScreen")
            appRouter.navigate(to: hasSeen ? .onboardingQ1 : .science)
        case .failure(let error):
            generalError = error.localizedDescription
        }
    }
}

// MARK: - Sign-up password field

struct SignUpPasswordField: View {
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
                        TextField("6+ characters", text: $password)
                            .textContentType(.newPassword)
                            .autocapitalization(.none)
                    } else {
                        SecureField("6+ characters", text: $password)
                            .textContentType(.newPassword)
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

// MARK: - Reusable CozyField

struct CozyField: View {
    let title: String
    var placeholder: String = ""
    @Binding var text: String
    @Binding var error: String
    var contentType: UITextContentType = .emailAddress
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
            TextField(placeholder.isEmpty ? title : placeholder, text: $text)
                .textContentType(contentType)
                .keyboardType(keyboard)
                .autocapitalization(contentType == .name ? .words : .none)
                .font(.system(size: 16))
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
