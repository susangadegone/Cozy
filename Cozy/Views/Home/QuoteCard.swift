import SwiftUI

struct QuoteCard: View {
    private static let quotes: [String] = [
        "A clean space is a kind thing to do for tomorrow-you.",
        "Daily resets beat weekend marathons.",
        "You don't have to do it all. Just the next one.",
        "Your future self is the one you're cleaning for.",
        "A tidy corner is enough for today.",
        "The home you want is built one quiet step at a time.",
        "Five minutes of care counts.",
        "You showed up. That's the work.",
        "Calm rooms come from calm habits.",
        "Today's quiet effort is tomorrow's easy morning.",
        "One wiped counter changes the whole kitchen.",
        "Enough is a real place to land.",
        "The dishes will keep. So will you.",
        "A made bed is a soft welcome home.",
        "You're allowed to stop before you're done.",
        "One room at a time is still a home.",
        "The work you did today still counts tomorrow.",
        "Care is quieter than people say it is.",
        "A folded blanket is a love letter to the couch.",
        "You don't owe anyone a spotless house.",
        "Done for now is a finished thing.",
        "The sink can hold what you haven't gotten to.",
        "Quiet rooms remember you took care of them.",
        "A clear surface is room to breathe.",
        "You came back to it. That matters.",
        "The house is patient. Be patient with it.",
        "Care adds up even when no one sees it.",
        "Ten minutes is a real contribution.",
        "You don't have to earn rest.",
        "The good home is the one you live in gently."
    ]

    private var quote: String {
        let cal = Calendar.current
        let now = Date()
        let year = cal.component(.year, from: now)
        let dayOfYear = cal.ordinality(of: .day, in: .year, for: now) ?? 1
        let seed = year * 366 + dayOfYear
        return Self.quotes[abs(seed) % Self.quotes.count]
    }

    var body: some View {
        Text(quote)
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(CozyTheme.primary)
            .lineSpacing(5)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(CozyTheme.yellow)
            .cornerRadius(CozyTheme.cornerRadius)
            .padding(.horizontal, 20)
    }
}

#Preview {
    QuoteCard()
        .padding(.vertical, 40)
        .background(CozyTheme.background)
}
