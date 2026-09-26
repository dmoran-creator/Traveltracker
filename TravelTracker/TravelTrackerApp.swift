import SwiftUI
import SwiftData

@main
struct TravelTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            TripListView()
        }
        .modelContainer(for: [Trip.self, Expense.self])
    }
}
