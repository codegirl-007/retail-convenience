//
//  CartView.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI

struct CartItem {
    let id = UUID()
    let product: Product
    var quantity: Int
    
    var totalPrice: Double {
        product.price * Double(quantity)
    }
}

class CartManager: ObservableObject {
    @Published var items: [CartItem] = []
    
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    func addItem(_ product: Product) {
        if let existingItem = items.first(where: { $0.product.id == product.id }) {
            updateQuantity(for: existingItem.id, quantity: existingItem.quantity + 1)
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
    }
    
    func removeItem(_ itemId: UUID) {
        items.removeAll { $0.id == itemId }
    }
    
    func updateQuantity(for itemId: UUID, quantity: Int) {
        if quantity <= 0 {
            removeItem(itemId)
        } else {
            if let index = items.firstIndex(where: { $0.id == itemId }) {
                items[index] = CartItem(product: items[index].product, quantity: quantity)
            }
        }
    }
    
    func clearCart() {
        items.removeAll()
    }
}

struct CartView: View {
    @ObservedObject var cartManager: CartManager
    @Binding var isPresented: Bool
    
    @State private var customerName = ""
    @State private var customerEmail = ""
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var savePaymentInfo = false
    @State private var showingPaymentSuccess = false
    
    var body: some View {
        NavigationView {
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
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark")
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
                        
                        Spacer()
                        
                        Text("Your Cart")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if !cartManager.items.isEmpty {
                            Button(action: {
                                cartManager.clearCart()
                            }) {
                                Text("Clear")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.red)
                            }
                        } else {
                            Spacer()
                                .frame(width: 40)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    if cartManager.items.isEmpty {
                        // Empty Cart
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image(systemName: "cart")
                                .font(.system(size: 80, weight: .thin))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("Your cart is empty")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("Add some products to get started")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Cart Items
                                VStack(spacing: 16) {
                                    ForEach(cartManager.items, id: \.id) { item in
                                        CartItemRow(item: item, cartManager: cartManager)
                                    }
                                }
                                .padding(.horizontal, 24)
                                
                                // Order Summary
                                VStack(spacing: 16) {
                                    HStack {
                                        Text("Order Summary")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    
                                    VStack(spacing: 8) {
                                        HStack {
                                            Text("Items (\(cartManager.totalItems))")
                                                .foregroundColor(.white.opacity(0.7))
                                            Spacer()
                                            Text("$\(cartManager.totalPrice, specifier: "%.2f")")
                                                .foregroundColor(.white)
                                        }
                                        
                                        HStack {
                                            Text("Tax")
                                                .foregroundColor(.white.opacity(0.7))
                                            Spacer()
                                            Text("$\(cartManager.totalPrice * 0.08, specifier: "%.2f")")
                                                .foregroundColor(.white)
                                        }
                                        
                                        Divider()
                                            .background(Color.white.opacity(0.3))
                                        
                                        HStack {
                                            Text("Total")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.white)
                                            Spacer()
                                            Text("$\(cartManager.totalPrice * 1.08, specifier: "%.2f")")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 24)
                                
                                // Payment Form
                                PaymentForm(
                                    customerName: $customerName,
                                    customerEmail: $customerEmail,
                                    cardNumber: $cardNumber,
                                    expiryDate: $expiryDate,
                                    cvv: $cvv,
                                    savePaymentInfo: $savePaymentInfo,
                                    onPayment: {
                                        processPayment()
                                    }
                                )
                                .padding(.horizontal, 24)
                                
                                Spacer(minLength: 40)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Payment Successful!", isPresented: $showingPaymentSuccess) {
            Button("OK") {
                cartManager.clearCart()
                isPresented = false
            }
        } message: {
            Text("Your order has been processed successfully!")
        }
        .onAppear {
            loadSavedPaymentInfo()
        }
    }
    
    private func processPayment() {
        // Save payment info if requested
        if savePaymentInfo {
            savePaymentInformation()
        }
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showingPaymentSuccess = true
        }
    }
    
    private func savePaymentInformation() {
        UserDefaults.standard.set(customerName, forKey: "saved_customer_name")
        UserDefaults.standard.set(customerEmail, forKey: "saved_customer_email")
        UserDefaults.standard.set(cardNumber, forKey: "saved_card_number")
        UserDefaults.standard.set(expiryDate, forKey: "saved_expiry_date")
        // Note: In a real app, you'd never save CVV or use proper encryption
    }
    
    private func loadSavedPaymentInfo() {
        if let savedName = UserDefaults.standard.string(forKey: "saved_customer_name"), !savedName.isEmpty {
            customerName = savedName
            customerEmail = UserDefaults.standard.string(forKey: "saved_customer_email") ?? ""
            cardNumber = UserDefaults.standard.string(forKey: "saved_card_number") ?? ""
            expiryDate = UserDefaults.standard.string(forKey: "saved_expiry_date") ?? ""
            savePaymentInfo = true
        }
    }
}

struct CartItemRow: View {
    let item: CartItem
    @ObservedObject var cartManager: CartManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Product Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.7))
                    .frame(width: 50, height: 50)
                
                Text(String(item.product.name.prefix(2)).uppercased())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Product Details
            VStack(alignment: .leading, spacing: 6) {
                Text(item.product.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("$\(item.product.price, specifier: "%.2f")/ea")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                // Quantity Controls
                HStack(spacing: 4) {
                    Button(action: {
                        cartManager.updateQuantity(for: item.id, quantity: item.quantity - 1)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.red)
                    }
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(minWidth: 16)
                    
                    Button(action: {
                        cartManager.updateQuantity(for: item.id, quantity: item.quantity + 1)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // Total Price
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(item.totalPrice, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct PaymentForm: View {
    @Binding var customerName: String
    @Binding var customerEmail: String
    @Binding var cardNumber: String
    @Binding var expiryDate: String
    @Binding var cvv: String
    @Binding var savePaymentInfo: Bool
    let onPayment: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Payment Information")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 16) {
                PaymentTextField(text: $customerName, placeholder: "Full Name", icon: "person.fill")
                PaymentTextField(text: $customerEmail, placeholder: "Email", icon: "envelope.fill")
                PaymentTextField(text: $cardNumber, placeholder: "Card Number", icon: "creditcard.fill")
                
                HStack(spacing: 16) {
                    PaymentTextField(text: $expiryDate, placeholder: "MM/YY", icon: "calendar")
                    PaymentTextField(text: $cvv, placeholder: "CVV", icon: "lock.fill")
                }
                
                // Save Payment Info Toggle
                HStack {
                    Toggle(isOn: $savePaymentInfo) {
                        HStack(spacing: 8) {
                            Image(systemName: "creditcard.and.123")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("Save payment information for future purchases")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                }
                .padding(.vertical, 8)
            }
            
            Button(action: onPayment) {
                Text("Complete Payment")
                    .font(.system(size: 18, weight: .bold))
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
            .disabled(customerName.isEmpty || customerEmail.isEmpty || cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty)
            .opacity(customerName.isEmpty || customerEmail.isEmpty || cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty ? 0.5 : 1.0)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct PaymentTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    CartView(cartManager: CartManager(), isPresented: .constant(true))
} 