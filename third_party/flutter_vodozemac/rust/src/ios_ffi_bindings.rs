//! C-compatible FFI bindings for iOS
//! These functions can be called directly from Swift without flutter_rust_bridge

use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use vodozemac::megolm::{InboundGroupSession, InboundGroupSessionPickle, MegolmMessage};

/// Result structure for iOS FFI decryption operations
#[repr(C)]
pub struct IOSDecryptResult {
    /// Decrypted plaintext (JSON string), or NULL on error
    pub plaintext: *mut c_char,
    /// Error message if operation failed, or NULL on success
    pub error: *mut c_char,
}

/// Decrypt an encrypted message using a pickled session
/// 
/// # Arguments
/// * `pickled_session` - Encrypted pickled session (from vodozemac)
/// * `pickle_key` - Pointer to 32-byte pickle key array
/// * `ciphertext` - Base64 encoded encrypted message
///
/// # Returns
/// An IOSDecryptResult containing:
/// - plaintext: The decrypted message (JSON string)
/// - error: Error message if decryption failed
/// 
/// Caller must free all non-NULL fields using `ios_free_result`
#[no_mangle]
pub extern "C" fn ios_decrypt_event(
    pickled_session: *const c_char,
    pickle_key: *const [u8; 32],
    ciphertext: *const c_char,
) -> IOSDecryptResult {
    // Initialize result with nulls
    let mut result = IOSDecryptResult {
        plaintext: std::ptr::null_mut(),
        error: std::ptr::null_mut(),
    };

    // Safety check for null pointers
    if pickled_session.is_null() || pickle_key.is_null() || ciphertext.is_null() {
        result.error = create_c_string("Invalid input: null pointer provided");
        return result;
    }

    // Convert C strings to Rust strings
    let pickled_session_str = match unsafe { CStr::from_ptr(pickled_session).to_str() } {
        Ok(s) => s,
        Err(e) => {
            result.error = create_c_string(&format!("Invalid pickled_session string: {}", e));
            return result;
        }
    };

    let ciphertext_str = match unsafe { CStr::from_ptr(ciphertext).to_str() } {
        Ok(s) => s,
        Err(e) => {
            result.error = create_c_string(&format!("Invalid ciphertext string: {}", e));
            return result;
        }
    };

    // Attempt decryption
    match decrypt_event_internal(pickled_session_str, unsafe { *pickle_key }, ciphertext_str) {
        Ok(plaintext) => {
            result.plaintext = create_c_string(&plaintext);
        }
        Err(e) => {
            result.error = create_c_string(&format!("Decryption failed: {}", e));
        }
    }

    result
}

/// Free a string allocated by this library
/// 
/// # Safety
/// Must only be called with strings returned by iOS FFI functions
#[no_mangle]
pub extern "C" fn ios_free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}

/// Free an IOSDecryptResult structure
/// 
/// # Safety
/// Must only be called with results returned by ios_decrypt_event
#[no_mangle]
pub extern "C" fn ios_free_result(result: IOSDecryptResult) {
    ios_free_string(result.plaintext);
    ios_free_string(result.error);
}

/// Helper to create a C string, returns null on error
fn create_c_string(s: &str) -> *mut c_char {
    match CString::new(s) {
        Ok(c_str) => c_str.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Internal decryption logic
fn decrypt_event_internal(
    pickled_session: &str,
    pickle_key: [u8; 32],
    ciphertext: &str,
) -> Result<String, Box<dyn std::error::Error>> {
    // Unpickle the session from vodozemac's encrypted pickle format
    let pickle = InboundGroupSessionPickle::from_encrypted(pickled_session, &pickle_key)?;
    let mut session = InboundGroupSession::from(pickle);

    // Parse the ciphertext
    let message = MegolmMessage::from_base64(ciphertext)?;

    // Decrypt the message
    let decrypted = session.decrypt(&message)?;

    // Convert plaintext bytes to UTF-8 string
    let plaintext = String::from_utf8(decrypted.plaintext)?;

    Ok(plaintext)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::CString;
    use vodozemac::megolm::GroupSession;

    #[test]
    fn test_decrypt_matrix_event_with_pickle() {
        // Create a group session and encrypt a message
        let mut outbound_session = GroupSession::new(vodozemac::megolm::SessionConfig::version_1());
        let session_key = outbound_session.session_key();
        let plaintext = "Hello, iOS Notification Extension!";
        let ciphertext = outbound_session.encrypt(plaintext);

        // Create inbound session and pickle it using vodozemac native format
        let inbound_session = InboundGroupSession::new(
            &session_key,
            vodozemac::megolm::SessionConfig::version_1(),
        );
        let pickle_key: [u8; 32] = *b"01234567890123456789012345678901";
        let pickled = inbound_session.pickle().encrypt(&pickle_key);

        // Convert to C strings
        let pickled_c = CString::new(pickled.clone()).unwrap();
        let ciphertext_c = CString::new(ciphertext.to_base64()).unwrap();

        // Call the C function
        let result = ios_decrypt_event(
            pickled_c.as_ptr(),
            &pickle_key,
            ciphertext_c.as_ptr(),
        );

        // Check for success
        if !result.error.is_null() {
            let error_msg = unsafe { CStr::from_ptr(result.error).to_str().unwrap() };
            panic!("Decryption failed: {}", error_msg);
        }
        assert!(!result.plaintext.is_null(), "Expected plaintext");

        // Convert result back to Rust string
        let result_plaintext = unsafe { CStr::from_ptr(result.plaintext).to_str().unwrap() };
        assert_eq!(result_plaintext, plaintext);

        // Clean up
        ios_free_result(result);
    }

    #[test]
    fn test_decrypt_with_invalid_pickle() {
        let pickle_key: [u8; 32] = *b"0123456789012345678901234567890!";
        let invalid_pickle = CString::new("invalid_base64_pickle").unwrap();
        let ciphertext = CString::new("some_ciphertext").unwrap();

        let result = ios_decrypt_event(
            invalid_pickle.as_ptr(),
            &pickle_key,
            ciphertext.as_ptr(),
        );

        // Should have error
        assert!(!result.error.is_null());
        assert!(result.plaintext.is_null());

        ios_free_result(result);
    }
}
