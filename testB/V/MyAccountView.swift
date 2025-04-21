import SwiftUI
import SafariServices

struct MyAccountView: View {
    @Binding var isLoggedIn: Bool
    @Binding var loggedInUsername: String
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showingDeleteAlert = false
    @State private var showingLogoutAlert = false
    @State private var showingEditUsername = false
    @State private var newUsername = ""
    @State private var showDeveloperLink = false
    
    private let developerLinkedIn = "https://linkedin.com/in/miroshnikov-mykhailo-b2a1a9342"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                profileHeaderSection()
                
                // Appearance Settings
                appearanceSection()
                
                // Account Actions
                accountActionsSection()
                
                // App Info
                appInfoSection()
                
                // Developer Contact
                developerContactSection()
            }
            .padding()
        }
        .navigationTitle("My Account")
        .sheet(isPresented: $showDeveloperLink) {
            SafariView(url: URL(string: developerLinkedIn)!)
        }
        .alert("Change Username", isPresented: $showingEditUsername) {
            TextField("New username", text: $newUsername)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                if !newUsername.isEmpty {
                    loggedInUsername = newUsername
                }
            }
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                isLoggedIn = false
            }
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAccount()
                isLoggedIn = false
            }
        }
    }
    
    // MARK: - View Components
    
    private func profileHeaderSection() -> some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
                .overlay(
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            
            Text(loggedInUsername)
                .font(.title2)
                .fontWeight(.semibold)
            
            Button(action: {
                newUsername = loggedInUsername
                showingEditUsername = true
            }) {
                Text("Edit Profile")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 20)
    }
    
    private func appearanceSection() -> some View {
        VStack(spacing: 16) {
            SectionHeader(title: "APPEARANCE")
            
            HStack(spacing: 0) {
                appearanceButton(icon: "sun.max", title: "Light", style: .light)
                appearanceButton(icon: "moon", title: "Dark", style: .dark)
            }
            .foregroundColor(.primary)
            .background(Color(.systemGray5))
            .cornerRadius(10)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func appearanceButton(icon: String, title: String, style: UIUserInterfaceStyle) -> some View {
        Button(action: {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = style
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(colorScheme == (style == .dark ? .dark : .light) ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
    }
    
    private func accountActionsSection() -> some View {
        VStack(spacing: 16) {
            SectionHeader(title: "ACCOUNT")
            
            accountActionButton(
                icon: "arrow.left.square",
                title: "Logout",
                color: .red,
                action: { showingLogoutAlert = true }
            )
            
            accountActionButton(
                icon: "trash",
                title: "Delete Account",
                color: .red,
                action: { showingDeleteAlert = true }
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func accountActionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(color)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(8)
        }
    }
    
    private func appInfoSection() -> some View {
        VStack(spacing: 16) {
            SectionHeader(title: "ABOUT")
            
            infoRow(title: "Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
            infoRow(title: "Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
    
    private func developerContactSection() -> some View {
        VStack(spacing: 16) {
            SectionHeader(title: "DEVELOPER")
            
            Button(action: {
                showDeveloperLink = true
            }) {
                HStack {
                    Image(systemName: "person.crop.square")
                        .foregroundColor(.blue)
                    Text("Contact Developer")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(8)
            }
            
            Text("Made with ❤️ by Mykhailo Miroshnikov")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Functions
    
    private func deleteAccount() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: loggedInUsername
        ]
        SecItemDelete(query as CFDictionary)
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        return SFSafariViewController(url: url, configuration: config)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
