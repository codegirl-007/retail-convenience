//
//  ProductData.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

/// Provides static product data for the retail convenience store
struct ProductDataProvider {
    
    // MARK: - Categories
    
    /// Available product categories in the store
    static let categories = [
        ProductCategory(name: "Beverages", icon: "cup.and.saucer.fill", color: .blue, itemCount: 45),
        ProductCategory(name: "Snacks", icon: "bag.fill", color: .orange, itemCount: 32),
        ProductCategory(name: "Health", icon: "cross.fill", color: .green, itemCount: 22),
        ProductCategory(name: "Personal Care", icon: "heart.fill", color: .pink, itemCount: 28)
    ]
    
    // MARK: - Product Generation
    
    /// Generates products for a specific category
    /// - Parameter category: The category to generate products for
    /// - Returns: Array of products for the specified category
    static func generateProducts(for category: ProductCategory) -> [Product] {
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