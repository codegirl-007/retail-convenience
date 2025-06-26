//
//  PaymentManager.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import Foundation

/// Manages payment information storage and retrieval
struct PaymentManager {
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let customerName = "saved_customer_name"
        static let customerEmail = "saved_customer_email"
        static let cardNumber = "saved_card_number"
        static let expiryDate = "saved_expiry_date"
    }
    
    // MARK: - Payment Information Storage
    
    /// Saves payment information to UserDefaults
    /// - Parameters:
    ///   - name: Customer's full name
    ///   - email: Customer's email address
    ///   - cardNumber: Credit card number
    ///   - expiryDate: Card expiry date in MM/YY format
    /// - Note: CVV is intentionally not saved for security reasons
    static func savePaymentInformation(name: String, email: String, cardNumber: String, expiryDate: String) {
        UserDefaults.standard.set(name, forKey: Keys.customerName)
        UserDefaults.standard.set(email, forKey: Keys.customerEmail)
        UserDefaults.standard.set(cardNumber, forKey: Keys.cardNumber)
        UserDefaults.standard.set(expiryDate, forKey: Keys.expiryDate)
    }
    
    /// Loads saved payment information from UserDefaults
    /// - Returns: A tuple containing the saved payment information, or nil if no data exists
    static func loadSavedPaymentInfo() -> (name: String, email: String, cardNumber: String, expiryDate: String)? {
        guard let savedName = UserDefaults.standard.string(forKey: Keys.customerName),
              !savedName.isEmpty else {
            return nil
        }
        
        let email = UserDefaults.standard.string(forKey: Keys.customerEmail) ?? ""
        let cardNumber = UserDefaults.standard.string(forKey: Keys.cardNumber) ?? ""
        let expiryDate = UserDefaults.standard.string(forKey: Keys.expiryDate) ?? ""
        
        return (name: savedName, email: email, cardNumber: cardNumber, expiryDate: expiryDate)
    }
    
    /// Checks if payment information is saved
    /// - Returns: True if payment information exists in storage
    static func hasStoredPaymentInfo() -> Bool {
        return loadSavedPaymentInfo() != nil
    }
    
    /// Clears all saved payment information
    static func clearSavedPaymentInfo() {
        UserDefaults.standard.removeObject(forKey: Keys.customerName)
        UserDefaults.standard.removeObject(forKey: Keys.customerEmail)
        UserDefaults.standard.removeObject(forKey: Keys.cardNumber)
        UserDefaults.standard.removeObject(forKey: Keys.expiryDate)
    }
} 