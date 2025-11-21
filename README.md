# iOS SDK

This guide walks you through installing, configuring, and launching the WotNot chat widget natively in your iOS app (SwiftUI or UIKit).

## 1. Installing the SDK

### Step 1: Add the SDK via Swift Package Manager (Recommended)

Supports Xcode 13+ for both SwiftUI and UIKit projects.

#### 1. Open Xcode → Add SPM Package

File → Add Packages…

#### 2. Enter the SDK Package URL

In the dialog box that appears, paste the WotNotSDK repository URL into the search bar/text field.

https://github.com/wotnotbot/ios-sdk

#### 3. Configure dependency rule

* Rule: *Up to Next Major Version*

* Set the version to the required SDK version

> **Info:** This ensures you automatically get minor improvements without risking breaking changes.

#### 4. Add the package

Click Add Package, and Xcode will fetch and integrate the SDK.

### Step 2: Add required permissions

Add the following permission to your `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Step 3: Import the SDK

Add this import wherever you use the widget:

```swift
import SwiftUI
import WotNotSDK
```

## 2. Configuration

### Step 1: Create a WidgetConfig

This `WidgetConfig` object contains your bot credentials and optional UI settings.

```swift
import WotNotSDK

let config = WidgetConfig(
    botId: "YOUR_BOT_ID",                    // Required: Your bot ID
    visitorKey: "VISITOR_KEY",                // Required: Visitor key (32-bit long string)
    accountKey: "YOUR_ACCOUNT_KEY",           // Required: Your account key
    accountId: YOUR_ACCOUNT_ID,               // Required: Your account ID (Int)
    
    // Optional Configuration
    conversationKey: nil,                     // Optional: Pre-existing conversation key
    isMessageAvatarVisible: true,             // Show/hide message avatars (default: true)
    isHeaderVisible: true,                   // Show/hide headers (default: true)
    dataSessionPayload: nil,                 // Optional: Additional data payload
    badRequestMessage: "Bad request. Please check your configuration.",
    botNotActiveMessage: "Bot is not active."
)
```

#### Where to find these credentials

**YOUR_BOT_ID** — open the bot you want to embed, and copy the bot_id from the URL.

**YOUR_ACCOUNT_ID** — goto Settings > Account Settings and copy the account_id from the URL.

**YOUR_ACCOUNT_KEY** — Goto the bot list screen, open the embed option from context menu and copy the highlighted key.

### Step 2: Initialize the SDK

Initialize inside your `App` struct or `View`

```swift
import SwiftUI
import WotNotSDK

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    initializeSDK()
                }
        }
    }
    
    private func initializeSDK() {
        Task {
            do {
                let config = WidgetConfig(
                    botId: "YOUR_BOT_ID",
                    visitorKey: "VISITOR_KEY_32_BIT_LONG",
                    accountKey: "YOUR_ACCOUNT_KEY",
                    accountId: "YOUR_ACCOUNT_ID"
                )
                
                try await wn.initialize(config: config)
            } catch {
                print("SDK Initialization failed: \(error.localizedDescription)")
            }
        }
    }
}
```

> **Warning:** **IMPORTANT NOTES:**
> * SDK must be initialized before launching any chat UI.
> * Initialization is asynchronous (async throws), so use Task or an async context.
> * All required fields (i.e. `botID`, `visitorKey`, `accountKey`, `accountID`) must be provided.
> * The SDK performs validation and throws errors if credentials are invalid.

## 3. Launching chat screens (SwiftUI)

The SDK provides several functions that return SwiftUI `View` objects. These can be presented using `NavigationLink`, `.sheet()`, or other SwiftUI presentation methods.

### 3.1 Launch conversation list (Full Screen)

Opens the conversation in a full screen mode.

```swift
do {
    let view = try wn.launchConversationListFullScreen()
    // Present the view
} catch {
    print("Failed to launch: \(error)")
}
```

### 3.2 Launch conversation list (Bottom Sheet)

Opens the conversation list in a bottom sheet.

```swift
do {
    let view = try wn.launchConversationListBottomSheet()
    // Present bottom sheet
} catch {
    print("Failed to launch: \(error)")
}
```

### 3.3 Launch conversation detail (Without Passing a Key)

Opens the conversation detail screen without passing a key. Useful when history retention logic is handled by bot preferences.

```swift
Task {
    do {
        let key = try await wn.openConversationDetailScreenWithoutKey()
        let view = try wn.launchConversation(conversationId: key)
        // Present the view
    } catch {
        print("Failed to open: \(error)")
    }
}
```

## 4. Theme customization

Customize colors for bubbles, text, accents, and error states.

### 4.1 Theme colors reference

| Property | Setter | Default | Used For |
|----------|--------|---------|----------|
| accentPrimary | accentPrimary: Color(...) | #0075ff | Buttons, headers, links |
| userMessageTextColor | visitorMessageTextColor: Color(...) | #FFFFFF | User message text & timestamp |
| botMessageBackgroundColor | botMessageBackgroundColor: Color(...) | #F2F5F8 | Bot message bubble background color |
| botMessageTextColor | botMessageTextColor: Color(...) | #1C1C1E | Bot text & timestamp |
| accentSecondary | accentSecondary: Color(...) | #d4e3ffff | Secondary accents |
| failurePrimary | failurePrimary: Color(...) | #FF0000 | Error messages |
| failureSecondary | failureSecondary: Color(...) | #FFEBEE | Error states |

### 4.2 Applying a custom theme

Apply the theme after initialization:

```swift
Task {
    do {
        // 1. Initialize SDK (omitted for brevity)
        // try await wn.initialize(config: config)
        
        // 2. Apply custom theme
        let customTheme = WidgetTheme(
            // Right side (user)
            accentPrimary: Color(red: 0/255, green: 117/255, blue: 255/255), // #0075ff
            visitorMessageTextColor: Color.white,
            
            // Left side (bot)
            botMessageBackgroundColor: Color(red: 242/255, green: 245/255, blue: 248/255), // #F2F5F8
            botMessageTextColor: Color(red: 28/255, green: 28/255, blue: 30/255), // #1C1C1E
            
            // Accent colors
            accentSecondary: Color(red: 212/255, green: 227/255, blue: 255/255), // #d4e3ff
            
            // Failure colors
            failurePrimary: Color.red
        )
        
        try wn.setTheme(customTheme)
    } catch {
        print("SDK initialization or theme setup failed: \(error)")
    }
}
```

## Complete integration example

Below is a streamlined full example.

```swift
import SwiftUI
import WotNotSDK

@main
struct WotNotDemoApp: App {
    
    init() {
        Task { await initializeSDK() }
    }
    
    var body: some Scene {
        WindowGroup {
            // Embed ContentView in a NavigationView for proper UI context
            NavigationView {
                ContentView()
            }
        }
    }
    
    // Asynchronous SDK Initialization Function
    private func initializeSDK() async {
        do {
            let config = WidgetConfig(
                botId: "YOUR_BOT_ID",
                visitorKey: "YOUR_VISITOR_KEY",
                accountKey: "YOUR_ACCOUNT_KEY",
                accountId: "YOUR_ACCOUNT_ID"
            )
            
            // Set a basic theme (optional, for visual consistency)
            let theme = WidgetTheme(
                primaryBlue: Color.blue,
                primaryRed: Color.red
            )
            
            try wn.setTheme(theme)
            try await wn.initialize(config: config)
        } catch {
            print("SDK Initialization Error: \(error.localizedDescription)")
            // The ContentView status rows will reflect the failed state
        }
    }
}

// --- 2. ContentView: Launches Bottom Sheet Directly ---
struct ContentView: View {
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 80))
                    // Use theme color for header icon
                    .foregroundColor(wn.getTheme()?.primaryBlue ?? Color.blue) 
                
                Text("WotNot SDK")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Chat Integration")
                    .font(.subheadline)
                    // Use theme color for secondary text
                    .foregroundColor(wn.getTheme()?.textSecondaryColor ?? Color.secondary)
            }
            
            // SDK Status
            VStack(spacing: 12) {
                StatusRow(
                    title: "SDK Status",
                    status: wn.initializationStatus.description,
                    isSuccess: wn.isSDKInitialized()
                )
                
                StatusRow(
                    title: "Validation Status",
                    status: wn.validationStatus.description,
                    isSuccess: wn.isBotValidated()
                )
            }
            
            // Open Bottom Sheet Button - Simple SDK method call!
            Button(action: {
                openBottomSheetConversationList()
            }) {
                HStack {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title3)
                    
                    Text("Open Conversation List")
                        .fontWeight(.semibold)
                }
                // Use theme color for foreground and background
                .foregroundColor(wn.getTheme()?.white ?? Color.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(wn.getTheme()?.primaryBlue ?? Color.blue)
                .cornerRadius(12)
            }
            // Button is disabled until the SDK confirms initialization
            .disabled(!wn.isSDKInitialized()) 
            
            Spacer()
        }
        .padding()
        .navigationTitle("SDK Home")
        .alert("Alert", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // Function to launch the SDK UI
    private func openBottomSheetConversationList() {
        do {
            // Directly calls the SDK's presentation function
            try wn.presentBottomSheetConversationList()
        } catch {
            alertMessage = "Failed to open conversation list: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// --- 3. Helper Structs and Extensions ---
// Status Row Component
struct StatusRow: View {
    let title: String
    let status: String
    let isSuccess: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(status)
                .foregroundColor(wn.getTheme()?.textSecondaryColor ?? Color.secondary)
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isSuccess ? (wn.getTheme()?.primaryGreen ?? Color.green) : (wn.getTheme()?.primaryRed ?? Color.red))
        }
        .padding()
        .background(wn.getTheme()?.lightGray ?? Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Extension for InitializationStatus
extension InitializationStatus {
    var description: String {
        switch self {
        case .notInitialized:
            return "Not Initialized"
        case .initialized:
            return "Initialized"
        case .initializationFailed(let error):
            return "Failed: \(error)"
        @unknown default:
            return "Unknown"
        }
    }
}

// Extension for ValidationStatus
extension ValidationStatus {
    var description: String {
        switch self {
        case .notValidated:
            return "Not Validated"
        case .validating:
            return "Validating..."
        case .validated:
            return "Validated"
        case .validationFailed(let error):
            return "Failed: \(error)"
        @unknown default:
            return "Unknown"
        }
    }
}
```

