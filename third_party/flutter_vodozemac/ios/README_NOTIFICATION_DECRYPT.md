# iOS Matrix Notification Decryption

This directory contains iOS-specific C-compatible FFI functions for decrypting Matrix events in iOS Notification Service Extensions. These functions allow you to decrypt encrypted Matrix messages directly from push notifications without launching the main app.

## Files

- **`vodozemac_ios_ffi_bindings.h`** - C header file declaring the iOS FFI bindings
- **`MatrixNotificationDecryptExample.swift`** - Swift example code demonstrating usage
- **`../../../rust/src/ios_ffi_bindings.rs`** - Rust implementation

## Overview

The API provides a simple function to decrypt Matrix Megolm encrypted events using pickled (serialized) inbound group sessions. This is specifically designed for iOS Notification Service Extensions where you need to show decrypted message content in notifications.

## API

### Core Function

```c
IOSDecryptResult ios_decrypt_event(
    const char* pickled_session,
    const uint8_t pickle_key[32],
    const char* ciphertext
);
```

**Parameters:**
- `pickled_session`: Encrypted pickled session (vodozemac native format)
- `pickle_key`: 32-byte array containing the pickle key
- `ciphertext`: Base64 encoded encrypted message

**Returns:** `IOSDecryptResult` struct containing:
- `plaintext`: The decrypted message (JSON string), or NULL on error
- `error`: Error message if operation failed, or NULL on success

### Memory Management

```c
void ios_free_string(char* s);
void ios_free_result(IOSDecryptResult result);
```

Always call `ios_free_result()` to free the returned result.

## Important Notes

### Pickle Format

This implementation uses **vodozemac's native pickle format**, not the legacy libolm format. When creating and storing session pickles from your main app, ensure you use vodozemac's pickle methods:

```dart
// In your Dart/Flutter app
final session = InboundGroupSession(sessionKey);
final pickledSession = session.toPickleEncrypted(pickleKey);
// Store pickledSession for use in notification extension
```

### Session Management

The pickled sessions should be stored and managed by your application. Load the appropriate pickled session for each room/sender to decrypt messages in your notification extension.

## Integration Steps

### 1. Add Notification Service Extension

In Xcode, add a new **Notification Service Extension** target to your iOS app:
1. File > New > Target
2. Select "Notification Service Extension"
3. Name it (e.g., "NotificationServiceExtension")

### 2. Link the Rust Library

Add the pod `flutter_vodozemac` with the path for the extension:
```
pod 'flutter_vodozemac', :path => '.symlinks/plugins/flutter_vodozemac/ios'
```
Then, include the `vodozemac_ios_ffi_bindings.h` header in your bridging header. For example, create a new file `Notification-Extension-Bridging-Extension.h` with the following content:

```
#ifndef Notification_Extension_Bridging_Header_h
#define Notification_Extension_Bridging_Header_h

// Import the vodozemac C header
#import "vodozemac_ios_ffi_bindings.h"

#endif /* Notification_Extension_Bridging_Header_h */
```

In your Xcode project settings for the Notification Extension target. 
1. Go to Build Settings
2. Find Objective-C Bridging Header
3. Set it to the path of your bridging header (in this case - `ios/Notification Extension/Notification-Extension-Bridging-Header.h`)

Run `pod install` now.

### 3. Implement Decryption Logic

See `MatrixNotificationDecryptExample.swift` for a complete example of:
- Setting up the decryptor with your pickle key
- Loading and saving pickled sessions
- Decrypting messages in your notification service extension
- Updating notification content with decrypted messages

## Testing

The Rust implementation includes comprehensive tests. To run them:

```bash
cd rust
cargo test ios_ffi_bindings
```

## License

See the main project LICENSE file.

