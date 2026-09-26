import SwiftUI
import SwiftData

struct ExpenseEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let trip: Trip
    let expense: Expense?

    @State private var title: String
    @State private var amount: Double
    @State private var category: ExpenseCategory
    @State private var date: Date

    init(trip: Trip, expense: Expense?) {
        self.trip = trip
        self.expense = expense
        _title = State(initialValue: expense?.title ?? "")
        _amount = State(initialValue: expense?.amount ?? 0)
        _category = State(initialValue: expense?.category ?? .meals)
        _date = State(initialValue: expense?.date ?? min(max(.now, trip.startDate), trip.endDate))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Label(category.label, systemImage: category.symbol)
                                .tag(category)
                        }
                    }
                    TextField("Description (optional)", text: $title)
                    TextField("Amount", value: $amount, format: .number.precision(.fractionLength(2)))
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle(expense == nil ? "New Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(amount <= 0)
                }
            }
        }
    }

    private func save() {
        let target = expense ?? Expense()
        target.title = title.trimmingCharacters(in: .whitespaces)
        target.amount = amount
        target.category = category
        target.date = date
        if expense == nil {
            modelContext.insert(target)
            target.trip = trip
        }
        dismiss()
    }
}
