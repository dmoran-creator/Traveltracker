import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(SettingsKey.currencyCode) private var currencyCode = SettingsDefault.currencyCode
    @AppStorage(SettingsKey.mileageRate) private var mileageRate = SettingsDefault.mileageRate

    let trip: Trip

    @State private var showingEditor = false
    @State private var showingNewExpense = false
    @State private var editingExpense: Expense?

    private var mileageAmount: Double { trip.distanceKm * mileageRate }

    var body: some View {
        List {
            Section("Trip") {
                LabeledContent("Dates", value: dateRange(trip))
                LabeledContent("Days", value: "\(trip.days)")
                if !trip.project.isEmpty {
                    LabeledContent("Project", value: trip.project)
                }
                if !trip.purpose.isEmpty {
                    LabeledContent("Purpose", value: trip.purpose)
                }
                LabeledContent("Status", value: trip.status.rawValue)
            }

            Section {
                if trip.expenses.isEmpty {
                    Text("No expenses yet")
                        .foregroundStyle(.secondary)
                }
                ForEach(trip.sortedExpenses) { expense in
                    Button {
                        editingExpense = expense
                    } label: {
                        ExpenseRow(expense: expense, currencyCode: currencyCode)
                            .foregroundStyle(Color.primary)
                    }
                }
                .onDelete { offsets in
                    let sorted = trip.sortedExpenses
                    for index in offsets {
                        modelContext.delete(sorted[index])
                    }
                }
                Button {
                    showingNewExpense = true
                } label: {
                    Label("Add Expense", systemImage: "plus.circle.fill")
                }
            } header: {
                Text("Expenses")
            }

            Section("Totals") {
                LabeledContent("Expenses", value: trip.totalExpenses.currency(currencyCode))
                LabeledContent("Distance", value: trip.distanceKm.kilometres)
                LabeledContent(
                    "Mileage (\(mileageRate.currency(currencyCode))/km)",
                    value: mileageAmount.currency(currencyCode)
                )
                LabeledContent("Total") {
                    Text((trip.totalExpenses + mileageAmount).currency(currencyCode))
                        .bold()
                }
            }

            if !trip.notes.isEmpty {
                Section("Notes") {
                    Text(trip.notes)
                }
            }
        }
        .navigationTitle(trip.destination.isEmpty ? "Trip" : trip.destination)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") { showingEditor = true }
        }
        .sheet(isPresented: $showingEditor) {
            TripEditorView(trip: trip)
        }
        .sheet(isPresented: $showingNewExpense) {
            ExpenseEditorView(trip: trip, expense: nil)
        }
        .sheet(item: $editingExpense) { expense in
            ExpenseEditorView(trip: trip, expense: expense)
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    let currencyCode: String

    var body: some View {
        HStack {
            Image(systemName: expense.category.symbol)
                .foregroundStyle(.tint)
                .frame(width: 28)
            VStack(alignment: .leading) {
                Text(expense.title.isEmpty ? expense.category.label : expense.title)
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(expense.amount.currency(currencyCode))
                .monospacedDigit()
        }
    }
}
