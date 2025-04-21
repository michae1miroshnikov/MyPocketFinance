import Foundation

enum TransactionType: String, CaseIterable, Identifiable {
    case income = "Income"
    case expense = "Expense"
    var id: String { self.rawValue }
}

enum Currency: String, CaseIterable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case uah = "UAH"
    var id: String { self.rawValue }
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .uah: return "₴"
        }
    }
}

struct ExpenseCategory: Identifiable {
    let id = UUID()
    var name: String
    var amount: Double
    var type: TransactionType
}
