//
//  CartView.swift
//  Retail-Convenience
//
//  Created by Stephanie Gredell on 6/26/25.
//

import SwiftUI
import PassKit

// MARK: - Payment Method Enum

enum PaymentMethod: String, CaseIterable {
    case applePay = "Apple Pay"
    case creditCard = "Credit Card"
    
    var icon: String {
        switch self {
        case .applePay:
            return "applelogo"
        case .creditCard:
            return "creditcard.fill"
        }
    }
}

// MARK: - Cart View

/// Main cart view displaying items, order summary, and payment form
struct CartView: View {
    @ObservedObject var cartManager: CartManager
    @Binding var isPresented: Bool
    
    // MARK: - Payment Form State
    @State private var selectedPaymentMethod: PaymentMethod = .applePay
    @State private var customerName = ""
    @State private var customerEmail = ""
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var savePaymentInfo = false
    @State private var showingPaymentSuccess = false
    @State private var showingOrderConfirmation = false
    @State private var isProcessingPayment = false
    @State private var completedOrder: CompletedOrder?
    
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
                                
                                // Payment Method Selection
                                PaymentMethodSelector(selectedMethod: $selectedPaymentMethod)
                                    .padding(.horizontal, 24)
                                
                                // Payment Form
                                if selectedPaymentMethod == .applePay {
                                    ApplePaySection(
                                        total: cartManager.totalPrice * 1.08,
                                        onPayment: {
                                            processApplePayPayment()
                                        },
                                        isProcessing: isProcessingPayment
                                    )
                                    .padding(.horizontal, 24)
                                } else {
                                    PaymentForm(
                                        customerName: $customerName,
                                        customerEmail: $customerEmail,
                                        cardNumber: $cardNumber,
                                        expiryDate: $expiryDate,
                                        cvv: $cvv,
                                        savePaymentInfo: $savePaymentInfo,
                                        onPayment: {
                                            processManualPayment()
                                        },
                                        isProcessing: isProcessingPayment
                                    )
                                    .padding(.horizontal, 24)
                                }
                                
                                Spacer(minLength: 40)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingOrderConfirmation) {
            if let order = completedOrder {
                OrderConfirmationView(order: order) {
                    showingOrderConfirmation = false
                    isPresented = false
                }
            }
        }
        .onAppear {
            loadSavedPaymentInfo()
        }
    }
    
    // MARK: - Payment Processing
    
    /// Processes Apple Pay payment
    private func processApplePayPayment() {
        isProcessingPayment = true
        
        // Create Apple Pay payment request
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = "merchant.com.retailconvenience" // You'll need to register this
        paymentRequest.supportedNetworks = [.visa, .masterCard, .amex, .discover]
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = "USD"
        
        // Create payment summary items
        let items = cartManager.items.map { item in
            PKPaymentSummaryItem(
                label: "\(item.product.name) x\(item.quantity)",
                amount: NSDecimalNumber(value: item.totalPrice)
            )
        }
        
        let tax = PKPaymentSummaryItem(
            label: "Tax",
            amount: NSDecimalNumber(value: cartManager.totalPrice * 0.08)
        )
        
        let total = PKPaymentSummaryItem(
            label: "Retail Convenience",
            amount: NSDecimalNumber(value: cartManager.totalPrice * 1.08)
        )
        
        paymentRequest.paymentSummaryItems = items + [tax, total]
        
        // Present Apple Pay sheet
        if let paymentController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
            paymentController.delegate = ApplePayHandler(
                onSuccess: {
                    self.isProcessingPayment = false
                    self.showingPaymentSuccess = true
                },
                onFailure: {
                    self.isProcessingPayment = false
                }
            )
            
            // In a real app, you'd present this from the current view controller
            // For now, we'll simulate the payment process
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isProcessingPayment = false
                self.createCompletedOrder(paymentMethod: "Apple Pay")
                self.showingOrderConfirmation = true
            }
        } else {
            // Apple Pay not available, fall back to credit card
            selectedPaymentMethod = .creditCard
            isProcessingPayment = false
        }
    }
    
    /// Processes manual credit card payment
    private func processManualPayment() {
        isProcessingPayment = true
        
        // Save payment info if requested
        if savePaymentInfo {
            PaymentManager.savePaymentInformation(
                name: customerName,
                email: customerEmail,
                cardNumber: cardNumber,
                expiryDate: expiryDate
            )
        }
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isProcessingPayment = false
            createCompletedOrder(paymentMethod: "Credit Card")
            showingOrderConfirmation = true
        }
    }
    
    /// Creates a completed order object for the confirmation screen
    private func createCompletedOrder(paymentMethod: String) {
        completedOrder = CompletedOrder(
            orderNumber: generateOrderNumber(),
            items: cartManager.items,
            subtotal: cartManager.totalPrice,
            tax: cartManager.totalPrice * 0.08,
            total: cartManager.totalPrice * 1.08,
            paymentMethod: paymentMethod,
            customerName: customerName.isEmpty ? "Guest" : customerName,
            customerEmail: customerEmail.isEmpty ? nil : customerEmail,
            orderDate: Date(),
            estimatedDelivery: Calendar.current.date(byAdding: .minute, value: Int.random(in: 15...45), to: Date()) ?? Date()
        )
        cartManager.clearCart()
    }
    
    /// Generates a unique order number
    private func generateOrderNumber() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = Int.random(in: 100...999)
        return "RC\(timestamp % 100000)\(random)"
    }
    
    /// Loads previously saved payment information if available
    private func loadSavedPaymentInfo() {
        if let savedInfo = PaymentManager.loadSavedPaymentInfo() {
            customerName = savedInfo.name
            customerEmail = savedInfo.email
            cardNumber = savedInfo.cardNumber
            expiryDate = savedInfo.expiryDate
            savePaymentInfo = true
        }
    }
}

// MARK: - Apple Pay Handler

/// Handles Apple Pay authorization callbacks
class ApplePayHandler: NSObject, PKPaymentAuthorizationViewControllerDelegate {
    let onSuccess: () -> Void
    let onFailure: () -> Void
    
    init(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        // In a real app, you would:
        // 1. Send the payment token to your Go server
        // 2. Process the payment with Stripe
        // 3. Return success/failure based on server response
        
        // For now, simulate successful payment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            self.onSuccess()
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
    }
}

// MARK: - Payment Method Selector

/// Component to select between Apple Pay and Credit Card payment methods
struct PaymentMethodSelector: View {
    @Binding var selectedMethod: PaymentMethod
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Payment Method")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    PaymentMethodButton(
                        method: method,
                        isSelected: selectedMethod == method
                    ) {
                        selectedMethod = method
                    }
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
    }
}

// MARK: - Payment Method Button

/// Individual payment method selection button
struct PaymentMethodButton: View {
    let method: PaymentMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: method.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? .black : .white.opacity(0.7))
                
                Text(method.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .black : .white.opacity(0.7))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.green : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Apple Pay Section

/// Apple Pay payment section with styling similar to Apple Pay buttons
struct ApplePaySection: View {
    let total: Double
    let onPayment: () -> Void
    let isProcessing: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Apple Pay")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Apple Pay Benefits
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "shield.checkerboard")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.green)
                        
                        Text("Secure payment with Touch ID or Face ID")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "creditcard.and.123")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.green)
                        
                        Text("No need to enter card details")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                    }
                }
                .padding(.bottom, 8)
                
                // Apple Pay Button
                Button(action: onPayment) {
                    HStack(spacing: 8) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "applelogo")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Pay with")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Apple Pay")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("$\(total, specifier: "%.2f")")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .disabled(isProcessing)
                .opacity(isProcessing ? 0.7 : 1.0)
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
    }
}

// MARK: - Cart Item Row

/// Individual cart item row with quantity controls
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

// MARK: - Payment Form

/// Payment form with customer information and card details
struct PaymentForm: View {
    @Binding var customerName: String
    @Binding var customerEmail: String
    @Binding var cardNumber: String
    @Binding var expiryDate: String
    @Binding var cvv: String
    @Binding var savePaymentInfo: Bool
    let onPayment: () -> Void
    let isProcessing: Bool
    
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
                HStack(spacing: 8) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Complete Payment")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
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
            .disabled(isProcessing || customerName.isEmpty || customerEmail.isEmpty || cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty)
            .opacity((isProcessing || customerName.isEmpty || customerEmail.isEmpty || cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty) ? 0.5 : 1.0)
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

// MARK: - Payment Text Field

/// Custom text field for payment form inputs
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

// MARK: - Order Confirmation View

/// Beautiful order confirmation screen shown after successful payment
struct OrderConfirmationView: View {
    let order: CompletedOrder
    let onDismiss: () -> Void
    
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
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer(minLength: 40)
                    
                    // Success Animation & Header
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green, Color.green.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                )
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: true)
                        
                        VStack(spacing: 12) {
                            Text("Order Confirmed!")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Thank you for your purchase")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    // Order Details Card
                    VStack(spacing: 24) {
                        // Order Number & Date
                        VStack(spacing: 16) {
                            HStack {
                                Text("Order Details")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                OrderDetailRow(label: "Order Number", value: order.orderNumber)
                                OrderDetailRow(label: "Date", value: formatDate(order.orderDate))
                                OrderDetailRow(label: "Customer", value: order.customerName)
                                if let email = order.customerEmail {
                                    OrderDetailRow(label: "Email", value: email)
                                }
                                OrderDetailRow(label: "Payment", value: order.paymentMethod)
                                OrderDetailRow(label: "Estimated Pickup", value: formatTime(order.estimatedDelivery))
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // Order Items
                        VStack(spacing: 16) {
                            HStack {
                                Text("Items Ordered")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(order.items, id: \.id) { item in
                                    OrderItemRow(item: item)
                                }
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // Order Summary
                        VStack(spacing: 12) {
                            HStack {
                                Text("Order Summary")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Subtotal")
                                        .foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Text("$\(order.subtotal, specifier: "%.2f")")
                                        .foregroundColor(.white)
                                }
                                
                                HStack {
                                    Text("Tax")
                                        .foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Text("$\(order.tax, specifier: "%.2f")")
                                        .foregroundColor(.white)
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.3))
                                
                                HStack {
                                    Text("Total")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("$\(order.total, specifier: "%.2f")")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    
                    // Pickup Information
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.orange)
                            
                            Text("Pickup Information")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your order will be ready for pickup in:")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(formatTime(order.estimatedDelivery))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                            
                            Text("You'll receive a notification when your order is ready.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    
                    // Done Button
                    Button(action: onDismiss) {
                        Text("Done")
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
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Order Detail Row

/// Individual row for order details
struct OrderDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Order Item Row

/// Individual row for ordered items
struct OrderItemRow: View {
    let item: CartItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.7))
                    .frame(width: 40, height: 40)
                
                Text(String(item.product.name.prefix(2)).uppercased())
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Product Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("$\(item.product.price, specifier: "%.2f") each")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Quantity and Total
            VStack(alignment: .trailing, spacing: 4) {
                Text("×\(item.quantity)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("$\(item.totalPrice, specifier: "%.2f")")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.green)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Previews

#Preview {
    CartView(cartManager: CartManager(), isPresented: .constant(true))
} 