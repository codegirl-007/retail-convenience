//
//  ContentView.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

// MARK: - Main Content View

/// Main content coordinator that manages authentication flow
/// Shows LoginView for unauthenticated users, RetailDashboardView for authenticated users
struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                RetailDashboardView()
            } else {
                LoginView {
                    authManager.isAuthenticated = true
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: authManager.isAuthenticated)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
}
