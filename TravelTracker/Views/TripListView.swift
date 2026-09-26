import SwiftUI
import SwiftData

struct TripListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate, order: .reverse) private var trips: [Trip]
    @AppStorage(SettingsKey.currencyCode) private var currencyCode = SettingsDefault.currencyCode

    @State private var searchText = ""
    @State private var showingNewTrip = false
    @State private var showingSummary = false
    @State private var showingSettings = false

    private var filteredTrips: [Trip] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return trips }
        return trips.filter {
            $0.destination.localizedCaseInsensitiveContains(query)
                || $0.project.localizedCaseInsensitiveContains(query)
                || $0.purpose.localizedCaseInsensitiveContains(query)
        }
    }

    private var sections: [(TripStatus, [Trip])] {
        let order: [TripStatus] = [.current, .upcoming, .past]
        return order.compactMap { status in
            var group = filteredTrips.filter { $0.status == status }
            if status == .upcoming { group.reverse() } // soonest first
            return group.isEmpty ? nil : (status, group)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    ContentUnavailableView {
                        Label("No Trips Yet", systemImage: "airplane.departure")
                    } description: {
                        Text("Tap + to log your first trip.")
                    } actions: {
                        Button("Add Trip") { showingNewTrip = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else if filteredTrips.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(sections, id: \.0) { status, group in
                            Section(status.rawValue) {
                                ForEach(group) { trip in
                                    NavigationLink(value: trip) {
                                        TripRow(trip: trip, currencyCode: currencyCode)
                                    }
                                }
                                .onDelete { offsets in
                                    for index in offsets {
                                        modelContext.delete(group[index])
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Travel Tracker")
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
            }
            .searchable(text: $searchText, prompt: "Destination, project, purpose")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showingSummary = true
                    } label: {
                        Label("Summary", systemImage: "chart.bar")
                    }
                    .disabled(trips.isEmpty)
                    Button {
                        showingNewTrip = true
                    } label: {
                        Label("Add Trip", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewTrip) {
                TripEditorView(trip: nil)
            }
            .sheet(isPresented: $showingSummary) {
                SummaryView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

struct TripRow: View {
    let trip: Trip
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(trip.destination.isEmpty ? "Untitled Trip" : trip.destination)
                    .font(.headline)
                Spacer()
                Text(trip.totalExpenses.currency(currencyCode))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Text(dateRange(trip))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if !trip.project.isEmpty {
                Label(trip.project, systemImage: "folder")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

func dateRange(_ trip: Trip) -> String {
    let start = trip.startDate.formatted(date: .abbreviated, time: .omitted)
    if Calendar.current.isDate(trip.startDate, inSameDayAs: trip.endDate) {
        return start
    }
    let end = trip.endDate.formatted(date: .abbreviated, time: .omitted)
    return "\(start) – \(end)"
}
