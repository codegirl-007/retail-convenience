//
//  CartManager.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

/// Manages the shopping cart state and operations
class CartManager: ObservableObject {
    @Published var items: [CartItem] = []
    
    // MARK: - Computed Properties
    
    /// Total price of all items in the cart
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    /// Total number of individual items in the cart
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    // MARK: - Cart Operations
    
    /// Adds a product to the cart or increases quantity if already present
    /// - Parameter product: The product to add to the cart
    func addItem(_ product: Product) {
        if let existingItem = items.first(where: { $0.product.id == product.id }) {
            updateQuantity(for: existingItem.id, quantity: existingItem.quantity + 1)
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
    }
    
    /// Removes an item completely from the cart
    /// - Parameter itemId: The ID of the cart item to remove
    func removeItem(_ itemId: UUID) {
        items.removeAll { $0.id == itemId }
    }
    
    /// Updates the quantity of a specific cart item
    /// - Parameters:
    ///   - itemId: The ID of the cart item to update
    ///   - quantity: The new quantity (item is removed if quantity <= 0)
    func updateQuantity(for itemId: UUID, quantity: Int) {
        if quantity <= 0 {
            removeItem(itemId)
        } else {
            if let index = items.firstIndex(where: { $0.id == itemId }) {
                items[index] = CartItem(product: items[index].product, quantity: quantity)
            }
        }
    }
    
    /// Removes all items from the cart
    func clearCart() {
        items.removeAll()
    }
} 