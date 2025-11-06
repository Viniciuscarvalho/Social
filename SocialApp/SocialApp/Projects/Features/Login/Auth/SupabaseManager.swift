import Foundation
import Supabase

public class SupabaseManager {
  static let shared = SupabaseManager()

  let client: SupabaseClient

  private init() {
    guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
          let url = URL(string: urlString),
          let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
      client = SupabaseClient(
        supabaseURL: URL(string: "https://eewyzulhdokvzlvpxddl.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVld3l6dWxoZG9rdnpsdnB4ZGRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MTc5MjIsImV4cCI6MjA3NTA5MzkyMn0.CafOJkXtVIK3KrvT-AyQM_hybDqfMi65plGGxCtAWmQ"
      )
      return
    }

    client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
  }
}
