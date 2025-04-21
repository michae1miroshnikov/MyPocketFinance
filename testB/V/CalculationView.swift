import SwiftUI
import Charts

struct CalculationView: View {
    @StateObject private var viewModel = TransactionViewModel()
    @State private var selectedCategory: String = ""
    @FocusState private var amountIsFocused: Bool
    @State private var showingCurrencyConverter = false
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        // Currency Section
                        VStack(spacing: 12) {
                            SectionHeader(title: "CURRENCY")
                            
                            Picker("", selection: $viewModel.selectedCurrency) {
                                ForEach(Currency.allCases) { currency in
                                    Text(currency.rawValue).tag(currency)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Button(action: {
                                showingCurrencyConverter = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.left.arrow.right")
                                    Text("Currency Converter")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Balance Summary
                        VStack(spacing: 12) {
                            SectionHeader(title: "BALANCE")
                            
                            VStack(spacing: 8) {
                                Text("\(viewModel.selectedCurrency.symbol)\(viewModel.balance, specifier: "%.2f")")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(viewModel.balance >= 0 ? .green : .red)
                                
                                HStack {
                                    VStack(spacing: 4) {
                                        Text("Income")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("\(viewModel.selectedCurrency.symbol)\(viewModel.totalIncome, specifier: "%.2f")")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    Divider()
                                    
                                    VStack(spacing: 4) {
                                        Text("Expenses")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("\(viewModel.selectedCurrency.symbol)\(viewModel.totalExpense, specifier: "%.2f")")
                                            .font(.headline)
                                            .foregroundColor(.red)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .frame(height: 60)
                            }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Chart
                        VStack(spacing: 12) {
                            SectionHeader(title: "OVERVIEW")
                            
                            Chart {
                                ForEach(TransactionType.allCases) { type in
                                    BarMark(
                                        x: .value("Type", type.rawValue),
                                        y: .value("Amount", viewModel.chartData[type] ?? 0)
                                    )
                                    .foregroundStyle(type == .income ? .green : .red)
                                }
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Transaction Input
                        VStack(spacing: 12) {
                            SectionHeader(title: "NEW TRANSACTION")
                            
                            Picker("", selection: $viewModel.selectedType) {
                                ForEach(TransactionType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom, 8)
                            
                            Picker("Category", selection: $selectedCategory) {
                                Text("Select Category").tag("")
                                ForEach(viewModel.currentCategoryList, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .onChange(of: selectedCategory) { newValue in
                                viewModel.newCategoryName = newValue
                            }
                            .padding(.bottom, 8)
                            
                            TextField("Amount", text: $viewModel.newAmount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($amountIsFocused)
                                .padding(.bottom, 8)
                            
                            Button(action: {
                                viewModel.addCategory()
                                amountIsFocused = false
                            }) {
                                Text("Add Transaction")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.newCategoryName.isEmpty || viewModel.newAmount.isEmpty)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .id("inputSection")
                        
                        // Transactions List
                        VStack(spacing: 12) {
                            SectionHeader(title: "RECENT TRANSACTIONS")
                            
                            if viewModel.categories.isEmpty {
                                Text("No transactions yet")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(viewModel.categories) { category in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(category.name)
                                                .font(.headline)
                                            Text(category.type.rawValue)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text("\(viewModel.selectedCurrency.symbol)\(category.amount, specifier: "%.2f")")
                                            .font(.headline)
                                            .foregroundColor(category.type == .income ? .green : .red)
                                    }
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                }
                                .onDelete(perform: viewModel.deleteCategory)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding()
                }
                .onChange(of: amountIsFocused) { isFocused in
                    if isFocused {
                        withAnimation {
                            proxy.scrollTo("inputSection", anchor: .center)
                        }
                    }
                }
            }
            .navigationTitle("Finance Tracker")
            .sheet(isPresented: $showingCurrencyConverter) {
                CurrencyConverterView()
                    .presentationDetents([.medium, .large])
            }
            .onTapGesture {
                amountIsFocused = false
            }
        }
    }
}
