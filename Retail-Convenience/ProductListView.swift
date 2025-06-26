//
//  ProductListView.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

struct Product {
    let id = UUID()
    let name: String
    let price: Double
    let description: String
    let inStock: Bool
    let stockCount: Int
}

struct ProductListView: View {
    let category: ProductCategory
    
    var products: [Product] {
        generateProducts(for: category)
    }
    
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
                HStack {
                    HStack(spacing: 12) {
                        NavigationBackButton()
                        
                        Text(category.name)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(category.color)
                            .frame(width: 8, height: 8)
                        Text("\(products.count) products")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(products, id: \.id) { product in
                            ProductRow(product: product, categoryColor: category.color)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
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
        case "Dairy":
            return [
                Product(name: "Milk 1 Gallon", price: 3.99, description: "Whole milk", inStock: true, stockCount: 8),
                Product(name: "Greek Yogurt", price: 1.29, description: "Plain Greek yogurt cup", inStock: true, stockCount: 15),
                Product(name: "Cheddar Cheese", price: 4.49, description: "Sharp cheddar cheese block", inStock: true, stockCount: 6),
                Product(name: "Butter 1lb", price: 4.99, description: "Salted butter", inStock: true, stockCount: 4),
                Product(name: "Cream Cheese", price: 2.99, description: "Philadelphia cream cheese", inStock: true, stockCount: 7)
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

struct NavigationBackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
    }
}

struct ProductRow: View {
    let product: Product
    let categoryColor: Color
    @State private var isAddingToCart = false
    @State private var showAddedFeedback = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
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
                    .frame(width: 70, height: 70)
                
                Text(String(product.name.prefix(2)).uppercased())
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(product.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                
                HStack {
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(product.inStock ? .green : .red)
                            .frame(width: 8, height: 8)
                        
                        Text(product.inStock ? "In Stock (\(product.stockCount))" : "Out of Stock")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(product.inStock ? .green : .red)
                    }
                }
            }
            
            VStack(spacing: 8) {
                Button(action: addToCart) {
                    HStack(spacing: 6) {
                        if isAddingToCart {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else if showAddedFeedback {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                        }
                        
                        if !isAddingToCart {
                            Text(showAddedFeedback ? "Added" : "Add")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: showAddedFeedback ? 
                                        [Color.green, Color.green.opacity(0.8)] :
                                        [Color.green, Color.green.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
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
        .padding(20)
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
    }
    
    private func addToCart() {
        guard product.inStock else { return }
        
        isAddingToCart = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAddingToCart = false
            showAddedFeedback = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showAddedFeedback = false
            }
        }
    }
}

#Preview {
    ProductListView(category: ProductCategory(name: "Beverages", icon: "cup.and.saucer.fill", color: .blue, itemCount: 45))
}