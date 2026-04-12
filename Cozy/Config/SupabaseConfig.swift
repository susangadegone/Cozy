import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://movvdcquzrlmvjeotfgi.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vdnZkY3F1enJsbXZqZW90ZmdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2MjI4NTUsImV4cCI6MjA5MTE5ODg1NX0.QuiyxIkVNTN2iZEkoXJ1sT3zUiIDavGGCoiARXSZjXA"

    static let client = SupabaseClient(
        supabaseURL: url,
        supabaseKey: anonKey
    )
}
