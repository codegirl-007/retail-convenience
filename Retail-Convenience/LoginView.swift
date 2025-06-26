//
//  LoginView.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

// MARK: - Login View

/// Authentication screen with username and password input
/// Demo credentials: username="admin", password="password"
struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    let onLoginSuccess: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.15, blue: 0.2),
                        Color(red: 0.2, green: 0.2, blue: 0.25),
                        Color(red: 0.25, green: 0.25, blue: 0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue, Color.blue.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                    )
                                
                                Image(systemName: "storefront.fill")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Welcome Back")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("Sign in to your retail account")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        VStack(spacing: 24) {
                            MaterialTextField(
                                text: $username,
                                placeholder: "Username",
                                icon: "person.fill"
                            )
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            
                            MaterialTextField(
                                text: $password,
                                placeholder: "Password",
                                icon: "lock.fill",
                                isSecure: true
                            )
                            
                            Button(action: handleLogin) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Sign In")
                                            .font(.headline)
                                            .fontWeight(.medium)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(username.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                                )
                                .shadow(
                                    color: username.isEmpty || password.isEmpty ? .clear : .blue.opacity(0.3),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                            }
                            .disabled(username.isEmpty || password.isEmpty || isLoading)
                            .animation(.easeInOut(duration: 0.2), value: username.isEmpty || password.isEmpty)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.3),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    Spacer()
                }
            }
        }
        .alert("Sign In Failed", isPresented: $showingAlert) {
            Button("Try Again") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleLogin() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            
            if username == "admin" && password == "password" {
                onLoginSuccess()
            } else {
                alertMessage = "Invalid username or password. Please try again."
                showingAlert = true
            }
        }
    }
}

struct MaterialTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var isSecure: Bool = false
    @State private var isFocused = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isFocused ? .blue : .white.opacity(0.6))
                    .frame(width: 20)
                
                if isSecure {
                    SecureField(placeholder, text: $text, onCommit: {
                        isFocused = false
                    })
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .onTapGesture {
                        isFocused = true
                    }
                } else {
                    TextField(placeholder, text: $text, onCommit: {
                        isFocused = false
                    })
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .onTapGesture {
                        isFocused = true
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isFocused ? 
                                    LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                lineWidth: 2
                            )
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

#Preview {
    LoginView(onLoginSuccess: {})
}