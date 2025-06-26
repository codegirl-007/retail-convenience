//
//  RetailDashboardView.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

struct ProductCategory {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let itemCount: Int
}

struct RetailDashboardView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var cartManager = CartManager()
    @State private var showingCart = false
    
    let categories = [
        ProductCategory(name: "Beverages", icon: "cup.and.saucer.fill", color: .blue, itemCount: 45),
        ProductCategory(name: "Snacks", icon: "bag.fill", color: .orange, itemCount: 32),
        ProductCategory(name: "Health", icon: "cross.fill", color: .green, itemCount: 22),
        ProductCategory(name: "Personal Care", icon: "heart.fill", color: .pink, itemCount: 28)
    ]
    
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
                        ForEach(categories, id: \.id) { category in
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

struct CategorySection: View {
    let category: ProductCategory
    @ObservedObject var cartManager: CartManager
    
    var products: [Product] {
        generateProducts(for: category)
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
    
    private func generateProducts(for category: ProductCategory) -> [Product] {
        switch category.name {
        case "Beverages":
            return [
                Product(name: "Coca-Cola 12oz", price: 1.99, description: "Classic cola soft drink", inStock: true, stockCount: 24),
                Product(name: "Pepsi 12oz", price: 1.99, description: "Cola soft drink", inStock: true, stockCount: 18),
                Product(name: "Sprite 12oz", price: 1.99, description: "Lemon-lime soda", inStock: true, stockCount: 15),
                Product(name: "Orange Juice 16oz", price: 3.49, description: "Fresh squeezed orange juice", inStock: true, stockCount: 12),
                Product(name: "Water Bottle 16.9oz", price: 0.99, description: "Purified drinking water", inStock: true, stockCount: 48),
                Product(name: "Energy Drink 16oz", price: 2.99, description: "High caffeine energy drink", inStock: false, stockCount: 0),
                Product(name: "Iced Tea 20oz", price: 2.49, description: "Sweet tea beverage", inStock: true, stockCount: 8)
            ]
        case "Snacks":
            return [
                Product(name: "Lay's Potato Chips", price: 2.99, description: "Classic salted potato chips", inStock: true, stockCount: 16),
                Product(name: "Doritos Nacho Cheese", price: 3.49, description: "Nacho cheese flavored tortilla chips", inStock: true, stockCount: 12),
                Product(name: "Snickers Bar", price: 1.49, description: "Chocolate bar with peanuts and caramel", inStock: true, stockCount: 32),
                Product(name: "Pringles Original", price: 2.79, description: "Stackable potato crisps", inStock: true, stockCount: 8),
                Product(name: "Trail Mix", price: 4.99, description: "Mixed nuts, dried fruit, and chocolate", inStock: true, stockCount: 6),
                Product(name: "Beef Jerky", price: 6.99, description: "Original flavored beef jerky", inStock: false, stockCount: 0)
            ]

        case "Health":
            return [
                Product(name: "Multivitamins", price: 12.99, description: "Daily vitamin supplement", inStock: true, stockCount: 15),
                Product(name: "Pain Relief", price: 6.99, description: "Ibuprofen 200mg tablets", inStock: true, stockCount: 8),
                Product(name: "Allergy Medicine", price: 8.49, description: "24-hour allergy relief", inStock: true, stockCount: 12),
                Product(name: "Cough Drops", price: 2.99, description: "Honey lemon cough drops", inStock: true, stockCount: 20),
                Product(name: "Thermometer", price: 15.99, description: "Digital thermometer", inStock: true, stockCount: 5),
                Product(name: "Hand Sanitizer", price: 3.49, description: "70% alcohol hand sanitizer", inStock: false, stockCount: 0),
                Product(name: "First Aid Kit", price: 19.99, description: "Complete first aid kit", inStock: true, stockCount: 3)
            ]
        case "Personal Care":
            return [
                Product(name: "Toothpaste", price: 3.99, description: "Fluoride toothpaste", inStock: true, stockCount: 10),
                Product(name: "Shampoo", price: 5.99, description: "Daily care shampoo", inStock: true, stockCount: 8),
                Product(name: "Body Wash", price: 4.49, description: "Moisturizing body wash", inStock: true, stockCount: 12),
                Product(name: "Deodorant", price: 3.49, description: "24-hour protection", inStock: false, stockCount: 0),
                Product(name: "Toothbrush", price: 2.99, description: "Soft bristle toothbrush", inStock: true, stockCount: 18),
                Product(name: "Face Wash", price: 6.99, description: "Gentle daily face cleanser", inStock: true, stockCount: 9)
            ]
        default:
            return [
                Product(name: "Sample Product 1", price: 9.99, description: "Description for sample product", inStock: true, stockCount: 10),
                Product(name: "Sample Product 2", price: 14.99, description: "Another sample product", inStock: false, stockCount: 0),
                Product(name: "Sample Product 3", price: 7.49, description: "Third sample product", inStock: true, stockCount: 5)
            ]
        }
    }
}

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

#Preview {
    RetailDashboardView()
        .environmentObject(AuthenticationManager())
}