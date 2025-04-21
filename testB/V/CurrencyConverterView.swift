import SwiftUI

struct CurrencyConverterView: View {
    @StateObject private var viewModel = CurrencyConverterViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Amount Input
                    VStack(spacing: 12) {
                        SectionHeader(title: "AMOUNT")
                        
                        TextField("Enter amount", text: $viewModel.amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Currency Selection
                    VStack(spacing: 12) {
                        SectionHeader(title: "CURRENCIES")
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("From")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Picker("", selection: $viewModel.sourceCurrency) {
                                    ForEach(viewModel.availableCurrencies, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                            
                            HStack {
                                Text("To")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Picker("", selection: $viewModel.targetCurrency) {
                                    ForEach(viewModel.availableCurrencies, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Result
                    VStack(spacing: 12) {
                        SectionHeader(title: "RESULT")
                        
                        VStack(spacing: 8) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                            } else if let error = viewModel.error {
                                Text(error)
                                    .foregroundColor(.red)
                                    .padding()
                            } else if let result = viewModel.convertedValue {
                                VStack(spacing: 4) {
                                    Text("\(viewModel.amount) \(viewModel.sourceCurrency)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("=")
                                        .font(.title3)
                                    Text("\(result, specifier: "%.2f") \(viewModel.targetCurrency)")
                                        .font(.system(size: 28, weight: .bold))
                                }
                                .padding()
                            } else {
                                Text("Enter amount to convert")
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Info Footer
                    Text("Data from exchangerate.host")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .navigationTitle("Currency Converter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.amount) { _ in viewModel.convert() }
            .onChange(of: viewModel.sourceCurrency) { _ in viewModel.convert() }
            .onChange(of: viewModel.targetCurrency) { _ in viewModel.convert() }
        }
    }
}
