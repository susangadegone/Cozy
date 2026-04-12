import SwiftUI

struct WelcomeView: View {
    @State private var showSignUp = false
    @State private var showLogIn = false

    var body: some View {
        NavigationStack {
            ZStack {
                CozyTheme.background.ignoresSafeArea()
                VStack(spacing: 32) {
                    Spacer()
                    heroSection
                    Spacer()
                    buttonSection
                    footerText
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationDestination(isPresented: $showSignUp) {
                AuthFormView(mode: .signUp)
            }
            .navigationDestination(isPresented: $showLogIn) {
                AuthFormView(mode: .logIn)
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            Text("🏠")
                .font(.system(size: 80))
            Text("Cozy")
                .font(.system(size: 44, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Text("Your warm household\nchore companion")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
        }
    }

    private var buttonSection: some View {
        VStack(spacing: 14) {
            Button { showSignUp = true } label: {
                Text("Get Started")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(CozyTheme.primary)
                    .cornerRadius(CozyTheme.cornerRadius)
            }
            Button { showLogIn = true } label: {
                Text("I already have an account")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(CozyTheme.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(CozyTheme.card)
                    .overlay(RoundedRectangle(cornerRadius: CozyTheme.cornerRadius).stroke(CozyTheme.border, lineWidth: 1))
                    .cornerRadius(CozyTheme.cornerRadius)
            }
        }
    }

    private var footerText: some View {
        Text("By continuing, you agree to our Terms & Privacy Policy")
            .font(.system(size: 12))
            .foregroundColor(CozyTheme.mutedText)
            .multilineTextAlignment(.center)
    }
}
