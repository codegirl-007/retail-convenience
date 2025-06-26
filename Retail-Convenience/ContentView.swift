//
//  ContentView.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

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
