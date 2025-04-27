//
//  KeychainError.swift
//  authTest
//
//  Created by Despo on 01.04.25.
//

import Foundation

enum KeychainError: Error {
  case saveError(OSStatus)
  case readError(OSStatus)
  case deleteError(OSStatus)
  case itemNotFound
  case unexpectedData
}
