import SwiftUI

struct BadgeGridView: View {
    @EnvironmentObject var appState: AppState

    private var earnedIds: Set<String> {
        Set(appState.profile?.earnedBadgeIds ?? [])
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(BadgeService.all) { badge in
                let earned = earnedIds.contains(badge.id)
                BadgeTileView(badge: badge, earned: earned)
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 4)
    }
}

struct BadgeTileView: View {
    let badge: BadgeDefinition
    let earned: Bool
    @State private var showTooltip = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) { showTooltip.toggle() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showTooltip = false }
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(earned ? CozyTheme.accent.opacity(0.15) : Color.gray.opacity(0.08))
                        .frame(width: 52, height: 52)

                    Text(badge.icon)
                        .font(.system(size: 24))
                        .grayscale(earned ? 0 : 1)
                        .opacity(earned ? 1 : 0.4)

                    if !earned {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(3)
                            .background(Color.gray.opacity(0.6))
                            .clipShape(Circle())
                            .offset(x: 16, y: 16)
                    }
                }

                Text(badge.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(earned ? CozyTheme.primary : CozyTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .buttonStyle(.plain)
        .overlay(
            Group {
                if showTooltip {
                    VStack(spacing: 0) {
                        Text(badge.description)
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(CozyTheme.primary.opacity(0.9))
                            .cornerRadius(8)
                        Triangle()
                            .fill(CozyTheme.primary.opacity(0.9))
                            .frame(width: 10, height: 6)
                    }
                    .offset(y: -52)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(10)
                }
            }
        )
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
