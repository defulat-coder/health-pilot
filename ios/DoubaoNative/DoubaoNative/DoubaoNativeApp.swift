import SwiftUI

@main
struct HealthPilotApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(state: AppState(service: HTTPStreamingAssistantService()))
        }
    }
}
