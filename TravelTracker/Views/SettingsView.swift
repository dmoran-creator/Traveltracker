import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(SettingsKey.mileageRate) private var mileageRate = SettingsDefault.mileageRate
    @AppStorage(SettingsKey.currencyCode) private var currencyCode = SettingsDefault.currencyCode

    private let currencies = ["CAD", "USD", "EUR", "GBP", "AUD"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Currency", selection: $currencyCode) {
                        ForEach(currencies, id: \.self) { Text($0).tag($0) }
                    }
                    HStack {
                        Text("Mileage Rate")
                        Spacer()
                        TextField("Rate", value: $mileageRate, format: .number.precision(.fractionLength(2...3)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 100)
                        Text("/km")
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text("Mileage rate is multiplied by each trip's distance to calculate reimbursement.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
