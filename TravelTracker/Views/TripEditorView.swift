import SwiftUI
import SwiftData

struct TripEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let trip: Trip?

    @State private var destination: String
    @State private var project: String
    @State private var purpose: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var distanceKm: Double
    @State private var notes: String

    init(trip: Trip?) {
        self.trip = trip
        _destination = State(initialValue: trip?.destination ?? "")
        _project = State(initialValue: trip?.project ?? "")
        _purpose = State(initialValue: trip?.purpose ?? "")
        _startDate = State(initialValue: trip?.startDate ?? .now)
        _endDate = State(initialValue: trip?.endDate ?? .now)
        _distanceKm = State(initialValue: trip?.distanceKm ?? 0)
        _notes = State(initialValue: trip?.notes ?? "")
    }

    private var canSave: Bool {
        !destination.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Where") {
                    TextField("Destination", text: $destination)
                        .textInputAutocapitalization(.words)
                    TextField("Project / Job #", text: $project)
                    TextField("Purpose", text: $purpose)
                }

                Section("When") {
                    DatePicker("Start", selection: $startDate, displayedComponents: .date)
                    DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: .date)
                }

                Section("Distance Driven") {
                    HStack {
                        TextField("0", value: $distanceKm, format: .number)
                            .keyboardType(.decimalPad)
                        Text("km")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle(trip == nil ? "New Trip" : "Edit Trip")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: startDate) { _, newValue in
                if endDate < newValue { endDate = newValue }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        let target = trip ?? Trip()
        target.destination = destination.trimmingCharacters(in: .whitespaces)
        target.project = project.trimmingCharacters(in: .whitespaces)
        target.purpose = purpose.trimmingCharacters(in: .whitespaces)
        target.startDate = startDate
        target.endDate = max(endDate, startDate)
        target.distanceKm = max(0, distanceKm)
        target.notes = notes
        if trip == nil {
            modelContext.insert(target)
        }
        dismiss()
    }
}
