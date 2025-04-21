import SwiftUI

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @Binding var loggedInUsername: String
    
    var body: some View {
        TabView {
            StockView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stocks")
                }
            
            CalculationView()
                .tabItem {
                    Image(systemName: "pencil.and.list.clipboard.rtl")
                    Text("Finance")
                }
            
            NewsView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("News")
                }
            
            MyAccountView(isLoggedIn: $isLoggedIn, loggedInUsername: $loggedInUsername)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Account")
                }
        }
        .navigationTitle("Welcome, \(loggedInUsername)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
