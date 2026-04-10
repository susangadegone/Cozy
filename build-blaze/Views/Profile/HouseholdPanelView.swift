import SwiftUI

struct HouseholdPanelView: View {
    @EnvironmentObject var appState: AppState
    @State private var inviteCode: String = ""
    @State private var showInviteSheet = false
    @State private var showAddMember = false
    @State private var newMemberName = ""
    @State private var newMemberEmoji = "😊"

    private let avatarEmojis = ["😊","😄","🥰","😎","🤗","😇","🧑","👩","👨","🧒","👧","👦",
                                "🐶","🐱","🐼","🦊","🐸","🦄","🌸","⭐","🎸","🎨","🍕","🌿"]

    private var members: [HouseholdMember] { appState.profile?.members ?? [] }
    private var isAdmin: Bool { appState.profile?.isAdmin == true }
    private var atMax: Bool { members.count >= 6 }

    var body: some View {
        VStack(spacing: 0) {
            if members.isEmpty && !showAddMember {
                emptyState
            } else {
                ForEach(Array(members.enumerated()), id: \.element.name) { idx, member in
                    memberRow(member)
                    if idx < members.count - 1 {
                        Divider().opacity(0.3).padding(.leading, 52)
                    }
                }
            }
            if showAddMember {
                Divider().opacity(0.3)
                addMemberForm
            }
            Divider().opacity(0.3)
            addMemberButton
        }
        .sheet(isPresented: $showInviteSheet) {
            InviteSheetView(code: inviteCode)
                .presentationDetents([.fraction(0.45)])
                .presentationDragIndicator(.visible)
        }
    }

    private var emptyState: some View {
        Text("No members yet. Tap + Add Member below.")
            .font(.system(size: 13))
            .foregroundColor(CozyTheme.mutedText)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
    }

    private var addMemberButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showAddMember.toggle()
                if !showAddMember { newMemberName = ""; newMemberEmoji = "😊" }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: showAddMember ? "xmark" : "person.badge.plus")
                Text(showAddMember ? "Cancel" : (atMax ? "Max 6 members" : "Add Member"))
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(showAddMember ? CozyTheme.mutedText : CozyTheme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background((showAddMember ? CozyTheme.mutedText : CozyTheme.accent).opacity(0.08))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(atMax && !showAddMember)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var addMemberForm: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(avatarEmojis, id: \.self) { emoji in
                        Button { newMemberEmoji = emoji } label: {
                            Text(emoji)
                                .font(.system(size: 24))
                                .frame(width: 40, height: 40)
                                .background(newMemberEmoji == emoji ? CozyTheme.accent.opacity(0.2) : CozyTheme.background)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(newMemberEmoji == emoji ? CozyTheme.accent : CozyTheme.border, lineWidth: 1.5))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            HStack(spacing: 10) {
                TextField("Member's name", text: $newMemberName)
                    .font(.system(size: 15))
                    .foregroundColor(CozyTheme.primary)
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(CozyTheme.background)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(CozyTheme.border, lineWidth: 1))
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit { saveMember() }
                Button(action: saveMember) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(newMemberName.trimmingCharacters(in: .whitespaces).isEmpty ? CozyTheme.border : CozyTheme.accent)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(newMemberName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(.vertical, 12)
    }

    private func saveMember() {
        let trimmed = newMemberName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let member = HouseholdMember(name: trimmed, emoji: newMemberEmoji)
        Task { await appState.addHouseholdMember(member) }
        newMemberName = ""
        newMemberEmoji = avatarEmojis.randomElement() ?? "😊"
        withAnimation { showAddMember = false }
    }

    private func memberRow(_ member: HouseholdMember) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(CozyTheme.accent.opacity(0.14))
                    .frame(width: 40, height: 40)
                Text(member.emoji)
                    .font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(CozyTheme.primary)
                Text(member.role == "admin" ? "Admin" : "Member")
                    .font(.system(size: 12))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
            if isAdmin && member.name != appState.profile?.displayName {
                Button {
                    Task { await appState.removeMember(member) }
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.red.opacity(0.65))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }

    private func generateInviteCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<8).map { _ in chars[Int.random(in: 0..<chars.count)] })
    }
}

// MARK: - InviteSheetView
struct InviteSheetView: View {
    let code: String
    @State private var copied = false
    @Environment(\.dismiss) private var dismiss

    private var shareURL: String { "https://cozyhome.app/join/\(code)" }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 6) {
                Text("Invite to Household")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(CozyTheme.primary)
                Text("Share this code or link with your household member")
                    .font(.system(size: 14))
                    .foregroundColor(CozyTheme.mutedText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)

            Text(code)
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(CozyTheme.accent)
                .tracking(6)
                .padding(.vertical, 16)
                .padding(.horizontal, 28)
                .background(CozyTheme.accent.opacity(0.1))
                .cornerRadius(16)

            VStack(spacing: 10) {
                Button {
                    UIPasteboard.general.string = shareURL
                    withAnimation { copied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { copied = false }
                    }
                } label: {
                    HStack {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        Text(copied ? "Copied!" : "Copy Invite Link")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(copied ? Color.green : CozyTheme.accent)
                    .cornerRadius(CozyTheme.cornerRadius)
                    .animation(.easeInOut(duration: 0.2), value: copied)
                }
                .buttonStyle(.plain)

                Button("Done") { dismiss() }
                    .font(.system(size: 16))
                    .foregroundColor(CozyTheme.mutedText)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(CozyTheme.background)
    }
}
