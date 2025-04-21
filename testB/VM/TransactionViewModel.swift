import Foundation

class TransactionViewModel: ObservableObject {
    @Published var categories: [ExpenseCategory] = []
    @Published var selectedType: TransactionType = .expense
    @Published var newCategoryName = ""
    @Published var newAmount = ""
    @Published var selectedCurrency: Currency = .usd
    
    let incomeCategories = ["Salary", "Freelance", "Investments"]
    let expenseCategories = ["Food", "Transport", "Shopping", "Rent"]
    
    var currentCategoryList: [String] {
        selectedType == .income ? incomeCategories : expenseCategories
    }
    
    var totalIncome: Double {
        categories.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        categories.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double {
        totalIncome - totalExpense
    }
    
    var chartData: [TransactionType: Double] {
        Dictionary(grouping: categories, by: { $0.type })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }
    
    func addCategory() {
        guard !newCategoryName.isEmpty, let amount = Double(newAmount) else { return }
        
        let newCategory = ExpenseCategory(
            name: newCategoryName,
            amount: amount,
            type: selectedType
        )
        
        categories.append(newCategory)
        newCategoryName = ""
        newAmount = ""
    }
    
    func deleteCategory(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
    }
}
