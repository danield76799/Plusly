#ifndef VODOZEMAC_IOS_FFI_BINDINGS_H
#define VODOZEMAC_IOS_FFI_BINDINGS_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Result structure for iOS FFI decryption operations.
 * Contains the decrypted plaintext and error information.
 */
typedef struct {
    /** Decrypted plaintext (JSON string), or NULL on error */
    char* plaintext;
    /** Error message if operation failed, or NULL on success */
    char* error;
} IOSDecryptResult;

/**
 * Decrypt an encrypted message using a pickled session.
 * 
 * This function is designed for use in iOS Notification Extensions where you need
 * to decrypt messages without the main app running.
 * 
 * @param pickled_session Encrypted pickled session (vodozemac format)
 * @param pickle_key Pointer to 32-byte array containing the pickle key
 * @param ciphertext Base64 encoded encrypted message
 * 
 * @return IOSDecryptResult containing:
 *         - plaintext: The decrypted message (JSON string)
 *         - error: Error message if operation failed
 * 
 * @note Caller must free all non-NULL fields using ios_free_result()
 * 
 * @example
 * ```swift
 * let pickleKey: [UInt8] = ... // Your 32-byte pickle key
 * let pickledSession = "..." // Pickled session from storage
 * let ciphertext = "..." // Base64 encrypted message
 * 
 * let result = ios_decrypt_event(
 *     pickledSession,
 *     pickleKey,
 *     ciphertext
 * )
 * 
 * if result.error == nil {
 *     let plaintext = String(cString: result.plaintext!)
 *     print("Decrypted: \(plaintext)")
 * } else {
 *     let error = String(cString: result.error!)
 *     print("Operation failed: \(error)")
 * }
 * 
 * ios_free_result(result)
 * ```
 */
IOSDecryptResult ios_decrypt_event(
    const char* pickled_session,
    const uint8_t pickle_key[32],
    const char* ciphertext
);

/**
 * Free a string allocated by this library.
 * 
 * @param s String to free (can be NULL)
 */
void ios_free_string(char* s);

/**
 * Free an IOSDecryptResult structure and all its fields.
 * 
 * @param result Result structure to free
 */
void ios_free_result(IOSDecryptResult result);

#ifdef __cplusplus
}
#endif

#endif /* VODOZEMAC_IOS_FFI_BINDINGS_H */
