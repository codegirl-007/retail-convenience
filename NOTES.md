# Retail Convenience App - Technical Notes

*Last Updated: 6/26/2024*

## **Architecture Decision: Go Server + Stripe Integration**

### **Overall Architecture**
```
iOS App → Go Server → Stripe API → Payment Processing
   ↓         ↓           ↓
UI/UX → Business Logic → Secure Payment
```

### **Why Server-Side Stripe Integration?**

#### **Security Benefits:**
- **API Keys Protection**: Stripe secret keys never exist in app binary (can't be reverse-engineered)
- **Payment Intent Security**: Server creates payment intents, app only handles UI flow
- **Webhook Security**: Server validates webhook signatures to prevent tampering
- **PCI Compliance**: Server handles sensitive operations, reducing PCI scope

#### **Architecture Benefits:**
- **Business Logic Centralization**: Order validation, inventory checks, tax calculations on server
- **Audit Trail**: All payment events logged server-side for compliance
- **Multi-Platform**: Same payment API can serve iOS, Android, web apps
- **Scalability**: Server can handle complex payment flows, subscriptions, refunds

---

## **Payment Processing Implementation**

### **Basic Payment Flow**

#### **iOS App Responsibilities:**
- Collect payment info using Stripe iOS SDK (secure card entry)
- Create payment method tokens (card data never touches your servers)
- Send order details to Go server
- Handle payment UI states (loading, success, error)

#### **Go Server Responsibilities:**
- Validate order data and inventory
- Calculate taxes and totals
- Create Stripe Payment Intents
- Handle webhook confirmations
- Update order status in database
- Send confirmation emails

### **Code Structure Examples**

#### **iOS App (Payment Processing):**
```swift
func processPayment() {
    let orderData = OrderRequest(
        items: cartItems,
        customerInfo: customerInfo,
        paymentMethodId: stripePaymentMethodId
    )
    
    apiClient.createOrder(orderData) { result in
        switch result {
        case .success(let order):
            // Handle successful payment
        case .failure(let error):
            // Handle payment error
        }
    }
}
```

#### **Go Server (Order Creation):**
```go
func createOrder(w http.ResponseWriter, r *http.Request) {
    // 1. Validate order data and user authentication
    // 2. Check inventory availability
    // 3. Calculate totals (items + tax + fees)
    // 4. Create Stripe Payment Intent
    // 5. Return client_secret to app for confirmation
    // 6. Handle webhook for final confirmation
}
```

---

## **Apple Pay & Google Pay Integration**

### **How Digital Wallets Work**
1. **iOS/Android handles secure payment** - Apple/Google encrypts card data
2. **App receives payment token** - Not actual card details
3. **Token sent to Go server** - Server processes with Stripe
4. **Stripe decrypts and processes** - Using their Apple Pay/Google Pay integration

### **Apple Pay Implementation**

#### **iOS App (Apple Pay):**
```swift
import PassKit

func handleApplePay() {
    let request = PKPaymentRequest()
    request.merchantIdentifier = "merchant.com.yourapp"
    request.supportedNetworks = [.visa, .masterCard, .amex]
    request.merchantCapabilities = .capability3DS
    
    let controller = PKPaymentAuthorizationViewController(paymentRequest: request)
    present(controller, animated: true)
}

func paymentAuthorizationController(
    _ controller: PKPaymentAuthorizationViewController,
    didAuthorizePayment payment: PKPayment,
    completion: @escaping (PKPaymentAuthorizationStatus) -> Void
) {
    sendPaymentToServer(payment.token) { success in
        completion(success ? .success : .failure)
    }
}
```

#### **Go Server (Apple Pay Processing):**
```go
func processApplePayPayment(w http.ResponseWriter, r *http.Request) {
    // 1. Receive Apple Pay token from iOS app
    var applePayToken ApplePayTokenRequest
    json.NewDecoder(r.Body).Decode(&applePayToken)
    
    // 2. Create Stripe Payment Method from Apple Pay token
    params := &stripe.PaymentMethodParams{
        Type: stripe.String("card"),
        Card: &stripe.PaymentMethodCardParams{
            Token: stripe.String(applePayToken.TokenData),
        },
    }
    
    // 3. Stripe handles Apple Pay decryption automatically
    paymentMethod, _ := paymentmethod.New(params)
    
    // 4. Create Payment Intent as normal
}
```

### **Digital Wallet Benefits**
- **Security**: No card data in app, Apple/Google handle encryption
- **User Experience**: Faster checkout, biometric auth, auto-filled info
- **Fraud Protection**: Apple/Google + Stripe validation layers

---

## **Saved Payment Methods (Stripe Customers)**

### **Security-First Approach**
**✅ Store:** Stripe Customer IDs, Payment Method IDs, User preferences
**❌ Never Store:** Card numbers, CVV codes, expiration dates, any raw payment data

### **Implementation Architecture**

#### **Customer Creation (Go Server):**
```go
func createStripeCustomer(userID string, email string) {
    customerParams := &stripe.CustomerParams{
        Email: stripe.String(email),
        Metadata: map[string]string{
            "user_id": userID,
        },
    }
    customer, _ := customer.New(customerParams)
    
    // Store ONLY the Stripe customer ID in database
    db.SaveUser(userID, customer.ID)
}
```

#### **Saving Payment Methods (SetupIntents):**
```go
func createSetupIntent(customerID string) {
    setupParams := &stripe.SetupIntentParams{
        Customer: stripe.String(customerID),
        Usage:    stripe.String("off_session"), // For future payments
    }
    setupIntent, _ := setupintent.New(setupParams)
    
    // Return client_secret to iOS app
}
```

#### **Database Schema:**
```sql
-- Users table - NO card data stored
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255),
    stripe_customer_id VARCHAR(255), -- Only Stripe ID
    created_at TIMESTAMP
);

-- Payment method preferences
CREATE TABLE user_payment_preferences (
    user_id UUID REFERENCES users(id),
    stripe_payment_method_id VARCHAR(255), -- Only Stripe ID
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP
);
```

### **Using Saved Payment Methods**

#### **List Saved Methods:**
```go
func getSavedPaymentMethods(customerID string) {
    params := &stripe.PaymentMethodListParams{
        Customer: stripe.String(customerID),
        Type:     stripe.String("card"),
    }
    
    methods := paymentmethod.List(params)
    // Return masked card info (last 4 digits, brand)
}
```

#### **Pay with Saved Method:**
```go
func createPaymentWithSavedMethod(customerID string, paymentMethodID string, amount int64) {
    params := &stripe.PaymentIntentParams{
        Amount:        stripe.Int64(amount),
        Currency:      stripe.String("usd"),
        Customer:      stripe.String(customerID),
        PaymentMethod: stripe.String(paymentMethodID),
        Confirmation:  stripe.String("automatic"),
        OffSession:    stripe.Bool(true), // Indicates saved payment method
    }
    
    paymentIntent, _ := paymentintent.New(params)
}
```

### **iOS UI for Saved Methods:**
```swift
struct SavedPaymentMethodsView: View {
    @State private var savedMethods: [SavedPaymentMethod] = []
    
    var body: some View {
        List(savedMethods) { method in
            HStack {
                Image(method.brand) // Visa, Mastercard, etc.
                VStack(alignment: .leading) {
                    Text("•••• •••• •••• \(method.last4)")
                    Text("Expires \(method.expMonth)/\(method.expYear)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                if method.isDefault {
                    Text("Default")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
```

---

## **Security & Compliance Benefits**

### **PCI DSS Compliance**
- **Drastically Reduced Scope**: You're not storing card data
- **Stripe Handles Compliance**: Stripe is PCI Level 1 certified
- **Token-Based Architecture**: Only encrypted tokens in your system

### **Data Breach Protection**
- **Minimal Risk**: Only Stripe IDs in your database
- **No Card Data**: Impossible to leak what you don't store
- **Tokenization**: Stripe handles all sensitive data tokenization

### **Risk Reduction Estimates**
- **Payment Security**: ~95% risk reduction (server-side Stripe + PCI compliance)
- **Authentication Security**: ~80% risk reduction (proper JWT + server validation)
- **Data Security**: ~85% risk reduction (server-side validation + encrypted storage)
- **Overall Security Posture**: ~85% improvement with proper server implementation

---

## **Implementation Roadmap**

### **Phase 1: Backend Foundation**
1. Go server setup with proper project structure
2. Authentication API (JWT tokens, user management)
3. Core API endpoints (products, cart, orders)
4. Database setup with proper migrations

### **Phase 2: Payment Integration**
1. Stripe server integration (Payment Intents, webhooks)
2. iOS Stripe SDK integration
3. Basic payment flow testing
4. Apple Pay integration

### **Phase 3: Saved Payment Methods**
1. Stripe Customer creation on user registration
2. SetupIntent flow for saving payment methods
3. API endpoints for managing saved methods
4. iOS UI for saved payment methods

### **Phase 4: Enhanced Features**
1. Multiple payment methods per user
2. Default payment method selection
3. Payment method verification for high-value transactions
4. Automatic card updater (Stripe feature)

---

## **Cost Considerations**

### **Stripe Fees**
- **Standard Processing**: 2.9% + 30¢ per transaction
- **Apple Pay**: Same rates as card payments
- **SetupIntents**: Usually free for saving payment methods
- **Customer Creation**: Free
- **International**: Additional fees may apply

### **Server Costs**
- **Go Server Hosting**: $10-50/month (depending on scale)
- **Database**: $10-30/month (PostgreSQL recommended)
- **SSL Certificates**: Free with Let's Encrypt
- **Monitoring/Logging**: $10-20/month

---

## **Technical Stack Recommendations**

### **Go Server**
- **Framework**: Gin or Echo for REST API
- **Database**: PostgreSQL with GORM ORM
- **Authentication**: JWT tokens with proper rotation
- **Environment**: Docker containers for deployment

### **iOS App**
- **Current**: SwiftUI with ObservableObject pattern
- **Networking**: URLSession with proper error handling
- **Stripe**: Official Stripe iOS SDK
- **Storage**: Keychain for secure token storage

### **DevOps**
- **Deployment**: Docker + GitHub Actions
- **Monitoring**: Prometheus + Grafana
- **Logging**: Structured logging with correlation IDs
- **Error Tracking**: Sentry for both server and iOS

---

## **Next Steps**

1. **Set up Go server project structure**
2. **Implement authentication endpoints**
3. **Create Stripe integration foundation**
4. **Update iOS app to use API instead of mock data**
5. **Implement payment flow end-to-end**
6. **Add Apple Pay support**
7. **Implement saved payment methods**

*This document should be updated as implementation progresses and architecture decisions evolve.*
