import Foundation

enum SettingsKey {
    static let mileageRate = "mileageRate"
    static let currencyCode = "currencyCode"
}

enum SettingsDefault {
    /// Default per-km reimbursement rate (CRA first-5,000 km rate).
    static let mileageRate = 0.72
    static let currencyCode = "CAD"
}

extension Double {
    func currency(_ code: String) -> String {
        formatted(.currency(code: code))
    }

    var kilometres: String {
        "\(formatted(.number.precision(.fractionLength(0...1)))) km"
    }
}
