import SwiftUI

struct OnboardingStep3: View {
    @Binding var members: [HouseholdMember]
    @State private var newName: String = ""
    @State private var selectedEmoji: String = "😊"
    @State private var showingEmojiPicker = false

    let avatarEmojis = ["😊","😄","🥰","😎","🤗","😇","🧑","👩","👨","🧒","👧","👦",
                        "🐶","🐱","🐼","🦊","🐸","🦄","🌸","⭐","🎸","🎨","🍕","🌿"]

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            if !members.isEmpty { membersList }
            if members.count < 6 { addMemberSection }
            Spacer()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("👥")
                .font(.system(size: 64))
                .padding(.top, 8)
            Text("Household Members")
                .font(.custom("Fraunces-Regular", size: 28))
                .foregroundColor(CozyTheme.primary)
            Text("Add the people you share your home with.\nYou can always edit this later.")
                .font(.custom("DMSans-Regular", size: 16))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.bottom, 24)
    }

    private var membersList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(members) { member in
                    MemberChip(member: member) {
                        withAnimation {
                            members.removeAll { $0.name == member.name }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 20)
    }

    private var addMemberSection: some View {
        VStack(spacing: 16) {
            emojiRow
            nameRow
        }
        .padding(.horizontal, 24)
    }

    private var emojiRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pick an avatar")
                .font(.custom("DMSans-Medium", size: 14))
                .foregroundColor(CozyTheme.mutedText)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(avatarEmojis, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                        } label: {
                            Text(emoji)
                                .font(.system(size: 28))
                                .frame(width: 44, height: 44)
                                .background(selectedEmoji == emoji ? CozyTheme.accent.opacity(0.2) : CozyTheme.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedEmoji == emoji ? CozyTheme.accent : CozyTheme.border, lineWidth: 1.5)
                                )
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var nameRow: some View {
        HStack(spacing: 10) {
            TextField("Member's name", text: $newName)
                .font(.custom("DMSans-Regular", size: 16))
                .foregroundColor(CozyTheme.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(CozyTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                        .stroke(CozyTheme.border, lineWidth: 1)
                )
                .cornerRadius(CozyTheme.cornerRadius)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .onSubmit { addMember() }

            Button(action: addMember) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(newName.trimmingCharacters(in: .whitespaces).isEmpty ? CozyTheme.border : CozyTheme.accent)
                    .cornerRadius(14)
            }
            .buttonStyle(.plain)
            .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    private func addMember() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, members.count < 6 else { return }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            members.append(HouseholdMember(name: trimmed, emoji: selectedEmoji))
        }
        newName = ""
        selectedEmoji = avatarEmojis.randomElement() ?? "😊"
    }
}

struct MemberChip: View {
    let member: HouseholdMember
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                Text(member.emoji)
                    .font(.system(size: 36))
                    .frame(width: 60, height: 60)
                    .background(CozyTheme.card)
                    .overlay(Circle().stroke(CozyTheme.border, lineWidth: 1.5))
                    .clipShape(Circle())
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(CozyTheme.primary.opacity(0.7))
                        .background(Color.white.clipShape(Circle()))
                }
                .offset(x: 4, y: -4)
            }
            Text(member.name)
                .font(.custom("DMSans-Regular", size: 12))
                .foregroundColor(CozyTheme.primary)
                .lineLimit(1)
        }
        .frame(width: 70)
    }
}
