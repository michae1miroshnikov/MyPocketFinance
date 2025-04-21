import SwiftUI
import Security

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var loggedInUsername: String
    
    @State private var username = ""
    @State private var password = ""
    @State private var selectedTab = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isPasswordVisible = false
    @State private var showDashboardAfterSignup = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                Text("My Pocket Finance")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Picker("", selection: $selectedTab) {
                    Text("Register").tag(0)
                    Text("Login").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    
                    HStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    
                    Button(action: {
                        selectedTab == 0 ? signUp() : login()
                    }) {
                        Text(selectedTab == 0 ? "Sign Up" : "Login")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Message"),
                              message: Text(alertMessage),
                              dismissButton: .default(Text("OK")) {
                            if showDashboardAfterSignup {
                                loggedInUsername = username
                                isLoggedIn = true
                            }
                        })
                    }
                    
                    HStack {
                        Text(selectedTab == 0 ? "Have an account?" : "Don't have an account?")
                        Button(action: {
                            selectedTab = selectedTab == 0 ? 1 : 0
                        }) {
                            Text(selectedTab == 0 ? "Login" : "Sign Up")
                                .foregroundColor(.blue)
                        }
                    }
                    .font(.footnote)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Rectangle()
                    .frame(width: 50, height: 5)
                    .cornerRadius(2.5)
                    .foregroundColor(.black)
                    .padding(.bottom, 8)
            }
            .navigationBarHidden(true)
        }
    }

    private func signUp() {
        guard !username.isEmpty, !password.isEmpty else {
            alertMessage = "Username and password cannot be empty."
            showAlert = true
            return
        }
        
        if saveToKeychain(username: username, password: password) {
            alertMessage = "Account created successfully. Logging in..."
            showDashboardAfterSignup = true
        } else {
            alertMessage = "Failed to create account."
            showDashboardAfterSignup = false
        }
        showAlert = true
    }

    private func login() {
        guard !username.isEmpty, !password.isEmpty else {
            alertMessage = "Username and password cannot be empty."
            showAlert = true
            return
        }
        
        if let savedPassword = getFromKeychain(username: username), savedPassword == password {
            loggedInUsername = username
            isLoggedIn = true
        } else {
            alertMessage = "Invalid credentials."
            showAlert = true
        }
    }
    
    // Keychain operations
    private func saveToKeychain(username: String, password: String) -> Bool {
        let passwordData = Data(password.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecValueData as String: passwordData
        ]
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    private func getFromKeychain(username: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
           let data = item as? Data,
           let password = String(data: data, encoding: .utf8) {
            return password
        }
        return nil
    }
}
