//
//  Retail_ConvenienceApp.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

@main
struct Retail_ConvenienceApp: App {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
