import SwiftUI

@main
struct BlackboxDetectiveApp: App {
    init() {
        // Trigger database initialization and seeding on app start
        _ = DatabaseManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
