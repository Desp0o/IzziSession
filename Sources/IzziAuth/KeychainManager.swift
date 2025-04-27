//
//  KeychainError.swift
//  authTest
//
//  Created by Despo on 01.04.25.
//

import Foundation

@available(macOS 12.0, *)
@available(iOS 16, *)
final class KeychainManager {
  private static let accessTokenKey = "izzi.Auth.accessToken"
  private static let refreshTokenKey = "izzi.Auth.refreshToken"
  
  static func saveTokensToKeychain(accessToken: String, refreshToken: String) throws {
    try saveItemToKeychain(key: accessTokenKey, value: accessToken)
    
    try saveItemToKeychain(key: refreshTokenKey, value: refreshToken)
  }
  
  static func saveAccessToken(token: String) throws {
    try saveItemToKeychain(key: accessTokenKey, value: token)
  }
  
  static func saveRefreshToken(token: String) throws {
    try saveItemToKeychain(key: refreshTokenKey, value: token)
  }
  
  private static func saveItemToKeychain(key: String, value: String) throws {
    try? deleteItemFromKeychain(key: key)
    
    guard let valueData = value.data(using: .utf8) else {
      throw KeychainError.unexpectedData
    }
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecValueData as String: valueData,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
    ]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    
    if status != errSecSuccess {
      throw KeychainError.saveError(status)
    }
  }
  
  static func getTokensFromKeychain() throws -> (accessToken: String, refreshToken: String) {
    let accessToken = try getItemFromKeychain(key: accessTokenKey)
    let refreshToken = try getItemFromKeychain(key: refreshTokenKey)
    
    return (accessToken, refreshToken)
  }
  
  private static func getItemFromKeychain(key: String) throws -> String {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    
    guard status == errSecSuccess else {
      throw KeychainError.readError(status)
    }
    
    guard let data = item as? Data,
          let value = String(data: data, encoding: .utf8) else {
      throw KeychainError.unexpectedData
    }
    
    return value
  }
  
  static func deleteTokensFromKeychain() throws {
    try deleteItemFromKeychain(key: accessTokenKey)
    try deleteItemFromKeychain(key: refreshTokenKey)
  }
  
  private static func deleteItemFromKeychain(key: String) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    
    if status != errSecSuccess && status != errSecItemNotFound {
      throw KeychainError.deleteError(status)
    }
  }
  
  static func getAccessToken() throws -> String {
    return try getItemFromKeychain(key: accessTokenKey)
  }
  
  static func getRefreshToken() throws -> String {
    return try getItemFromKeychain(key: refreshTokenKey)
  }
}
