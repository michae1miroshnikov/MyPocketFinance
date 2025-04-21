import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var loggedInUsername = ""
    
    var body: some View {
        Group {
            if isLoggedIn {
                ProfileView(isLoggedIn: $isLoggedIn, loggedInUsername: $loggedInUsername)
            } else {
                LoginView(isLoggedIn: $isLoggedIn, loggedInUsername: $loggedInUsername)
            }
        }
    }
}
