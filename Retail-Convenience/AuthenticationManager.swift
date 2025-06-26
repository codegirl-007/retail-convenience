//
//  AuthenticationManager.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: String = ""
    
    func login(username: String, password: String) -> Bool {
        if username == "admin" && password == "password" {
            isAuthenticated = true
            currentUser = username
            return true
        }
        return false
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = ""
    }
}