import Foundation
import SwiftData

@Model
final class Trip {
    var destination: String
    var purpose: String
    var project: String
    var startDate: Date
    var endDate: Date
    var distanceKm: Double
    var notes: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Expense.trip)
    var expenses: [Expense] = []

    init(
        destination: String = "",
        purpose: String = "",
        project: String = "",
        startDate: Date = .now,
        endDate: Date = .now,
        distanceKm: Double = 0,
        notes: String = ""
    ) {
        self.destination = destination
        self.purpose = purpose
        self.project = project
        self.startDate = startDate
        self.endDate = endDate
        self.distanceKm = distanceKm
        self.notes = notes
        self.createdAt = .now
    }

    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    /// Number of calendar days covered by the trip, inclusive.
    var days: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        let diff = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return max(1, diff + 1)
    }

    var status: TripStatus {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        if calendar.startOfDay(for: startDate) > today { return .upcoming }
        if calendar.startOfDay(for: endDate) < today { return .past }
        return .current
    }

    var sortedExpenses: [Expense] {
        expenses.sorted { $0.date < $1.date }
    }
}

enum TripStatus: String {
    case upcoming = "Upcoming"
    case current = "In Progress"
    case past = "Past"
}

@Model
final class Expense {
    var title: String
    var amount: Double
    var categoryRaw: String
    var date: Date
    var trip: Trip?

    init(title: String = "", amount: Double = 0, category: ExpenseCategory = .meals, date: Date = .now) {
        self.title = title
        self.amount = amount
        self.categoryRaw = category.rawValue
        self.date = date
    }

    var category: ExpenseCategory {
        get { ExpenseCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
}

enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case lodging, meals, transport, fuel, parking, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .lodging: "Lodging"
        case .meals: "Meals"
        case .transport: "Transport"
        case .fuel: "Fuel"
        case .parking: "Parking"
        case .other: "Other"
        }
    }

    var symbol: String {
        switch self {
        case .lodging: "bed.double"
        case .meals: "fork.knife"
        case .transport: "airplane"
        case .fuel: "fuelpump"
        case .parking: "parkingsign"
        case .other: "ellipsis.circle"
        }
    }
}
