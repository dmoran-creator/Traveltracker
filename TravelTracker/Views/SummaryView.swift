import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Trip.startDate) private var trips: [Trip]
    @AppStorage(SettingsKey.currencyCode) private var currencyCode = SettingsDefault.currencyCode
    @AppStorage(SettingsKey.mileageRate) private var mileageRate = SettingsDefault.mileageRate

    @State private var selectedYear = Calendar.current.component(.year, from: .now)

    private var years: [Int] {
        let all = Set(trips.map { Calendar.current.component(.year, from: $0.startDate) })
        return all.union([selectedYear]).sorted(by: >)
    }

    private var yearTrips: [Trip] {
        trips.filter { Calendar.current.component(.year, from: $0.startDate) == selectedYear }
    }

    private var totalDays: Int { yearTrips.reduce(0) { $0 + $1.days } }
    private var totalKm: Double { yearTrips.reduce(0) { $0 + $1.distanceKm } }
    private var totalExpenses: Double { yearTrips.reduce(0) { $0 + $1.totalExpenses } }
    private var mileageAmount: Double { totalKm * mileageRate }

    private var byCategory: [(ExpenseCategory, Double)] {
        ExpenseCategory.allCases.compactMap { category in
            let sum = yearTrips
                .flatMap(\.expenses)
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.amount }
            return sum > 0 ? (category, sum) : nil
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                }

                Section("Overview") {
                    LabeledContent("Trips", value: "\(yearTrips.count)")
                    LabeledContent("Days Travelling", value: "\(totalDays)")
                    LabeledContent("Distance Driven", value: totalKm.kilometres)
                }

                Section("Costs") {
                    ForEach(byCategory, id: \.0) { category, sum in
                        LabeledContent {
                            Text(sum.currency(currencyCode)).monospacedDigit()
                        } label: {
                            Label(category.label, systemImage: category.symbol)
                        }
                    }
                    LabeledContent("Mileage", value: mileageAmount.currency(currencyCode))
                    LabeledContent("Total") {
                        Text((totalExpenses + mileageAmount).currency(currencyCode)).bold()
                    }
                }

                Section {
                    ShareLink(
                        item: CSVFile(text: CSVExporter.csv(for: yearTrips, mileageRate: mileageRate)),
                        preview: SharePreview("Travel \(String(selectedYear)).csv")
                    ) {
                        Label("Export \(String(selectedYear)) as CSV", systemImage: "square.and.arrow.up")
                    }
                    .disabled(yearTrips.isEmpty)
                } footer: {
                    Text("One row per expense plus a mileage row per trip — ready for a spreadsheet or expense claim.")
                }
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct CSVFile: Transferable {
    let text: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { file in
            Data(file.text.utf8)
        }
        .suggestedFileName("TravelTracker.csv")
    }
}

enum CSVExporter {
    static func csv(for trips: [Trip], mileageRate: Double) -> String {
        var rows = [["Trip Start", "Trip End", "Destination", "Project", "Purpose",
                     "Date", "Category", "Description", "Distance (km)", "Amount"]]
        let day = Date.ISO8601FormatStyle().year().month().day()

        for trip in trips {
            let base = [trip.startDate.formatted(day), trip.endDate.formatted(day),
                        trip.destination, trip.project, trip.purpose]
            for expense in trip.sortedExpenses {
                rows.append(base + [expense.date.formatted(day), expense.category.label,
                                    expense.title, "", String(format: "%.2f", expense.amount)])
            }
            if trip.distanceKm > 0 {
                rows.append(base + [trip.startDate.formatted(day), "Mileage",
                                    String(format: "%.2f/km", mileageRate),
                                    String(format: "%.1f", trip.distanceKm),
                                    String(format: "%.2f", trip.distanceKm * mileageRate)])
            }
        }

        return rows.map { $0.map(escape).joined(separator: ",") }.joined(separator: "\n") + "\n"
    }

    private static func escape(_ field: String) -> String {
        guard field.contains(where: { $0 == "," || $0 == "\"" || $0 == "\n" }) else { return field }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
