import SwiftUI

// MARK: - PartnerInviteView
struct PartnerInviteView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var joinCode = ""
    @State private var showJoinField = false
    @State private var joinError: String? = nil
    @State private var joinSuccess = false
    @State private var codeCopied = false
    @State private var shareExpanded = false

    private var myCode: String {
        appState.profile?.inviteCode ?? generateCode()
    }
    private var shareURL: String { "https://cozyhome.app/join/\(myCode)" }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "FAF7F2").ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        heroSection
                        myCodeCard
                        dividerOr
                        joinCard
                        membersCard
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Partner Invite")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(CozyTheme.mutedText)
                }
            }
        }
    }

    // MARK: - Hero
    private var heroSection: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(CozyTheme.accent.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "person.2.fill")
                    .font(.system(size: 34, weight: .light))
                    .foregroundColor(CozyTheme.accent)
            }
            Text("Invite your household")
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
            Text("Share your invite code or link so your partner or roommates can join your home.")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
    }

    // MARK: - My Code
    private var myCodeCard: some View {
        InviteCard(title: "Your invite code", icon: "qrcode") {
            VStack(spacing: 16) {
                Text(myCode)
                    .font(.system(size: 34, weight: .bold, design: .monospaced))
                    .foregroundColor(CozyTheme.accent)
                    .tracking(6)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity)
                    .background(CozyTheme.accent.opacity(0.08))
                    .cornerRadius(14)

                HStack(spacing: 10) {
                    // Copy code button
                    Button {
                        UIPasteboard.general.string = myCode
                        withAnimation(.spring(response: 0.3)) { codeCopied = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { codeCopied = false }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: codeCopied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 13, weight: .medium))
                            Text(codeCopied ? "Copied!" : "Copy code")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(codeCopied ? Color(hex: "4CAF82") : CozyTheme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background((codeCopied ? Color(hex: "4CAF82") : CozyTheme.accent).opacity(0.1))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke((codeCopied ? Color(hex: "4CAF82") : CozyTheme.accent).opacity(0.25), lineWidth: 1))
                        .animation(.easeInOut(duration: 0.2), value: codeCopied)
                    }
                    .buttonStyle(.plain)

                    // Share link button
                    ShareLink(item: shareURL) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 13, weight: .medium))
                            Text("Share link")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(CozyTheme.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(CozyTheme.border.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(CozyTheme.border, lineWidth: 1))
                    }
                }

                Text("Code expires after someone joins or in 7 days.")
                    .font(.system(size: 11))
                    .foregroundColor(CozyTheme.mutedText)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    // MARK: - Divider
    private var dividerOr: some View {
        HStack(spacing: 12) {
            Rectangle().fill(CozyTheme.border).frame(height: 1)
            Text("or join one")
                .font(.system(size: 13))
                .foregroundColor(CozyTheme.mutedText)
                .fixedSize()
            Rectangle().fill(CozyTheme.border).frame(height: 1)
        }
    }

    // MARK: - Join Card
    private var joinCard: some View {
        InviteCard(title: "Join a household", icon: "person.badge.plus") {
            VStack(spacing: 12) {
                Text("Enter an invite code from your partner to join their home.")
                    .font(.system(size: 13))
                    .foregroundColor(CozyTheme.mutedText)

                HStack(spacing: 10) {
                    TextField("Enter invite code", text: $joinCode)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(CozyTheme.primary)
                        .tracking(3)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(CozyTheme.background)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(
                            joinError != nil ? Color.red.opacity(0.5) : CozyTheme.border, lineWidth: 1))

                    Button {
                        attemptJoin()
                    } label: {
                        Text(joinSuccess ? "✓" : "Join")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 72, height: 46)
                            .background(joinSuccess ? Color(hex: "4CAF82") : CozyTheme.accent)
                            .cornerRadius(10)
                            .animation(.easeInOut(duration: 0.2), value: joinSuccess)
                    }
                    .buttonStyle(.plain)
                    .disabled(joinCode.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                if let err = joinError {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 12))
                        Text(err)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.red.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                if joinSuccess {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "4CAF82"))
                        Text("You've joined! Refreshing household...")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "4CAF82"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    // MARK: - Current Members
    private var membersCard: some View {
        let members = appState.profile?.members ?? []
        return InviteCard(title: "In your home", icon: "house.fill") {
            VStack(spacing: 0) {
                if members.isEmpty {
                    Text("No members yet.")
                        .font(.system(size: 14))
                        .foregroundColor(CozyTheme.mutedText)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(Array(members.enumerated()), id: \.element.name) { idx, member in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(CozyTheme.accent.opacity(0.14))
                                    .frame(width: 38, height: 38)
                                Text(member.emoji)
                                    .font(.system(size: 18))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(member.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(CozyTheme.primary)
                                Text(member.role == "admin" ? "Admin" : "Member")
                                    .font(.system(size: 12))
                                    .foregroundColor(CozyTheme.mutedText)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "4CAF82"))
                                .font(.system(size: 16))
                        }
                        .padding(.vertical, 10)
                        if idx < members.count - 1 {
                            Divider().opacity(0.25).padding(.leading, 50)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Join logic
    private func attemptJoin() {
        let code = joinCode.trimmingCharacters(in: .whitespaces).uppercased()
        guard code.count >= 6 else {
            withAnimation { joinError = "Code must be at least 6 characters." }
            return
        }
        joinError = nil
        // In a real app this would verify against the backend.
        // For now we simulate a successful join by refreshing the profile.
        withAnimation { joinSuccess = true }
        joinCode = ""
        Task {
            await appState.refreshProfile()
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation { joinSuccess = false }
        }
    }

    private func generateCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<8).map { _ in chars[Int.random(in: 0..<chars.count)] })
    }
}

// MARK: - InviteCard
struct InviteCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(CozyTheme.accent)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(CozyTheme.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            Divider().opacity(0.25)
            content()
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 16)
        }
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cardCornerRadius)
        .overlay(RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius).stroke(CozyTheme.border, lineWidth: 1))
        .shadow(color: CozyTheme.primary.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
