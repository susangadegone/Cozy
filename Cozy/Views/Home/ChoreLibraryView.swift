import SwiftUI

// MARK: - Chore Library View
// Thin wrapper that presents BrowseChoresView in interactive mode,
// filtered to the rooms the user added during onboarding.
struct ChoreLibraryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        BrowseChoresView(previewMode: false, limitToRooms: [])
    }
}
