//
//  RetailDashboardView.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

// MARK: - Main Dashboard View

/// Main dashboard displaying product categories and cart functionality
struct RetailDashboardView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var cartManager = CartManager()
    @State private var showingCart = false
    
    var body: some View {
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
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What would you like?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        authManager.logout()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Categories with horizontal product scrolls
                ScrollView {
                    LazyVStack(spacing: 32) {
                        ForEach(ProductDataProvider.categories, id: \.id) { category in
                            CategorySection(category: category, cartManager: cartManager)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
                
                // View Cart Button
                Button(action: {
                    showingCart = true
                }) {
                    HStack {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 18, weight: .bold))
                        
                        if cartManager.totalItems > 0 {
                            Text("View Cart (\(cartManager.totalItems))")
                                .font(.system(size: 18, weight: .bold))
                        } else {
                            Text("View Cart")
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(
                                color: .green.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingCart) {
            CartView(cartManager: cartManager, isPresented: $showingCart)
        }
    }
}

// MARK: - Category Section

/// Displays a category header with horizontally scrollable products
struct CategorySection: View {
    let category: ProductCategory
    @ObservedObject var cartManager: CartManager
    
    /// Products for this category
    var products: [Product] {
        ProductDataProvider.generateProducts(for: category)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category Header
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    category.color.opacity(0.8),
                                    category.color.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("\(products.count) products available")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            
            // Horizontal Product Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(products, id: \.id) { product in
                        ProductCard(product: product, categoryColor: category.color, cartManager: cartManager)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    

}

// MARK: - Product Card

/// Individual product card with add to cart functionality
struct ProductCard: View {
    let product: Product
    let categoryColor: Color
    @ObservedObject var cartManager: CartManager
    @State private var isAddingToCart = false
    @State private var showAddedFeedback = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Product Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                categoryColor.opacity(0.8),
                                categoryColor.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text(String(product.name.prefix(2)).uppercased())
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Product Info
            VStack(spacing: 8) {
                Text(product.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text("$\(product.price, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                // Add to Cart Button
                Button(action: addToCart) {
                    HStack(spacing: 6) {
                        if isAddingToCart {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else if showAddedFeedback {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                        }
                        
                        if !isAddingToCart {
                            Text(showAddedFeedback ? "Added" : (product.inStock ? "Add" : "Sold Out"))
                                .font(.system(size: 12, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(height: 32)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: !product.inStock ? 
                                        [Color.gray, Color.gray.opacity(0.7)] :
                                        showAddedFeedback ? 
                                        [Color.green, Color.green.opacity(0.8)] :
                                        [Color.green, Color.green.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .disabled(!product.inStock || isAddingToCart || showAddedFeedback)
                .opacity(product.inStock ? 1.0 : 0.4)
                .scaleEffect(showAddedFeedback ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showAddedFeedback)
                .animation(.easeInOut(duration: 0.1), value: isAddingToCart)
            }
        }
        .frame(width: 160, height: 200)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
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
                    RoundedRectangle(cornerRadius: 20)
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
        .overlay(
            // Corner Banner for Low Stock
            Group {
                if product.inStock && product.stockCount < 5 {
                    CornerBanner(text: "Going fast!", color: .orange)
                }
            }
        )
        .clipped()
    }
    
    // MARK: - Actions
    
    /// Handles adding the product to the cart with visual feedback
    private func addToCart() {
        guard product.inStock else { return }
        
        isAddingToCart = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAddingToCart = false
            cartManager.addItem(product)
            showAddedFeedback = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showAddedFeedback = false
            }
        }
    }
}

// MARK: - Corner Banner

/// Diagonal corner banner for special product states (low stock, sales, etc.)
struct CornerBanner: View {
    let text: String
    let color: Color
    
    var body: some View {
        ZStack {
            // Banner background
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 20)
                .rotationEffect(.degrees(45))
                .shadow(color: color.opacity(0.3), radius: 2, x: 1, y: 1)
            
            // Banner text
            Text(text)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .rotationEffect(.degrees(45))
        }
        .offset(x: 70, y: -85)
        .frame(width: 50, height: 50)
    }
}

// MARK: - Previews

#Preview {
    RetailDashboardView()
        .environmentObject(AuthenticationManager())
}