//
//  ProductListView.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

// MARK: - Product List View (Legacy)
// Note: This view is currently unused but kept for potential future features

/// Legacy product list view for individual category navigation
/// Currently unused - replaced by horizontal scrolling in dashboard
struct ProductListView: View {
    let category: ProductCategory
    
    var products: [Product] {
        ProductDataProvider.generateProducts(for: category)
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