//
//  Models.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

// MARK: - Product Models

/// Represents a product category in the retail store
struct ProductCategory {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let itemCount: Int
}

/// Represents an individual product available for purchase
struct Product {
    let id = UUID()
    let name: String
    let price: Double
    let description: String
    let inStock: Bool
    let stockCount: Int
}

// MARK: - Cart Models

/// Represents an item in the shopping cart with quantity
struct CartItem {
    let id = UUID()
    let product: Product
    var quantity: Int
    
    /// Calculated total price for this cart item (price × quantity)
    var totalPrice: Double {
        product.price * Double(quantity)
    }
} 