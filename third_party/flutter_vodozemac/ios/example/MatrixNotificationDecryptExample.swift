import Foundation
import os

/// iOS Matrix Notification Decryption
///
/// See README_NOTIFICATION_DECRYPT.md for setup instructions and prerequisites.

/// Production-ready implementation for decrypting Matrix events in Notification Service Extension
/// assuming matrix-dart-sdk is used to store pickled sessions in a shared app group.
class MatrixNotificationDecryptor {
    
    private let appGroupIdentifier: String
    private let keychainAccessGroup: String
    private let logger = os.Logger(subsystem: "MatrixNotificationDecrypt", category: "decrypt")
    
    /// Initialize with your app's security configuration
    /// - Parameters:
    ///   - appGroupIdentifier: Shared app group (e.g., "group.com.mycompany.myapp")
    ///   - keychainAccessGroup: Keychain access group for shared credentials
    init(appGroupIdentifier: String, keychainAccessGroup: String) {
        self.appGroupIdentifier = appGroupIdentifier
        self.keychainAccessGroup = keychainAccessGroup
    }
    
    // MARK: - Keychain Access
    
    /// Retrieve a value from Keychain
    private func getFromKeychain(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "matrix.vodozemac",
            kSecAttrAccount as String: account,
            kSecAttrAccessGroup as String: keychainAccessGroup,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            logger.error("Could not retrieve \(account) from Keychain")
            return nil
        }
        return value
    }
    
    // MARK: - Database Access
    
    /// Open the shared database
    /// - Note: Requires FMDB dependency
    private func openDatabase() -> FMDatabase? {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            logger.error("Cannot access app group container")
            return nil
        }
        
        let databasePath = containerURL.appendingPathComponent("matrix.sqlite").path
        let database = FMDatabase(path: databasePath)
        
        guard database.open() else {
            logger.error("Failed to open database")
            return nil
        }
        
        // If your database uses SQLCipher encryption, set the key here:
        // database.setKey("your-encryption-key")
        
        return database
    }
    
    /// Retrieve a pickled session from database
    /// - Parameters:
    ///   - database: Open FMDatabase connection
    ///   - sessionId: Session identifier
    /// - Returns: Base64-encoded pickled session, or nil if not found
    private func getPickledSession(
        database: FMDatabase,
        sessionId: String
    ) -> String? {
        do {
            let query = """
            SELECT pickle FROM inbound_group_sessions WHERE session_id = ?
            """
            
            guard let resultSet = try database.executeQuery(
                query,
                values: [sessionId]
            ) else {
                logger.error("Database query failed")
                return nil
            }
            
            if resultSet.next(),
               let pickle = resultSet.string(forColumn: "pickle") {
                return pickle
            }
            
            logger.debug("No session found for session_id: \(sessionId)")
            return nil
        } catch {
            logger.error("Database error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Retrieve pickle key from Keychain
    private func getPickleKey() -> [UInt8]? {
        guard let keyString = getFromKeychain(account: "pickle_key") else {
            logger.error("Pickle key not found in Keychain")
            return nil
        }
        
        // If stored as base64:
        if let data = Data(base64Encoded: keyString),
           data.count == 32 {
            return [UInt8](data)
        }
        
        // If stored as raw bytes
        let bytes = [UInt8](keyString.utf8)
        if bytes.count == 32 {
            return bytes
        }
        
        logger.error("Pickle key is not 32 bytes")
        return nil
    }
    
    // MARK: - Decryption
    
    /// Decrypt a Matrix event
    /// - Parameters:
    ///   - roomId: Room ID (for session lookup)
    ///   - sessionId: Session ID from the encrypted event
    ///   - ciphertext: Base64-encoded ciphertext from the event
    /// - Returns: Decrypted message body, or nil on error
    func decryptEvent(
        roomId: String,
        sessionId: String,
        ciphertext: String
    ) -> String? {
        logger.debug("Starting decryption for room: \(roomId), session: \(sessionId)")
        
        // Get pickle key from Keychain
        guard let pickleKey = getPickleKey() else {
            logger.error("Failed to retrieve pickle key")
            return nil
        }
        
        // Open database and get pickled session
        guard let database = openDatabase() else {
            logger.error("Failed to open database")
            return nil
        }
        defer { database.close() }
        
        guard let pickledSession = getPickledSession(
            database: database,
            sessionId: sessionId
        ) else {
            logger.error("Failed to retrieve pickled session")
            return nil
        }
        
        // Decrypt using vodozemac FFI
        guard let pickledSessionC = pickledSession.cString(using: .utf8),
              let ciphertextC = ciphertext.cString(using: .utf8) else {
            logger.error("Failed to convert strings to C format")
            return nil
        }
        
        let result = ios_decrypt_event(pickledSessionC, pickleKey, ciphertextC)
        defer { ios_free_result(result) }
        
        // Check for decryption errors
        if let error = result.error {
            let errorMessage = String(cString: error)
            logger.error("Decryption failed: \(errorMessage)")
            return nil
        }
        
        guard let plaintextPtr = result.plaintext else {
            logger.error("Decryption returned null plaintext")
            return nil
        }
        
        let plaintext = String(cString: plaintextPtr)
        logger.debug("Decryption successful")
        
        // Extract message body from decrypted JSON
        return extractMessageBody(from: plaintext)
    }
    
    /// Extract message body from decrypted event JSON
    private func extractMessageBody(from plaintext: String) -> String? {
        guard let data = plaintext.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [String: Any],
              let body = content["body"] as? String else {
            logger.error("Failed to parse message body from decrypted plaintext")
            return nil
        }
        return body
    }
}

