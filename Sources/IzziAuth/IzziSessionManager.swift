//
//  IzziSession.swift
//
//  Created by Despo on 01.04.25.
//

import Foundation

@available(macOS 12.0, *)
@available(iOS 16, *)
public class IzziSessionManager {
  
  public init() {}
  
  public func saveTokensToKeychain(accessToken: String, refreshToken: String) throws {
    try KeychainManager.saveTokensToKeychain(accessToken: accessToken, refreshToken: refreshToken)
  }
  
  public func saveOnlyAccessToken(token: String) throws {
    try KeychainManager.saveAccessToken(token: token)
  }
  
  public func saveOnlyRefreshToken(token: String) throws {
    try KeychainManager.saveRefreshToken(token: token)
  }
  
  public func getAccessToken() throws -> String {
    return try KeychainManager.getAccessToken()
  }
  
  public func getRefreshToken() throws -> String {
    return try KeychainManager.getRefreshToken()
  }
  
  public func deleteTokensFromKeychain() throws {
    try KeychainManager.deleteTokensFromKeychain()
  }
}

@available(macOS 12.0, *)
@available(iOS 16, *)
extension IzziSessionManager {
  public func verifyTokenValidity<RequestModel: Codable, ResponseModel: Codable>(
    apiEndpoint: String,
    customRequestBuilder: ((String) -> RequestModel),
    tokenExtractor: ((ResponseModel) -> String)
  ) async throws {
    guard let refreshToken = try? KeychainManager.getRefreshToken() else {
      throw KeychainError.itemNotFound
    }
    
    let requestModel = customRequestBuilder(refreshToken)
    
    do {
      let response: ResponseModel = try await postData(urlString: apiEndpoint, body: requestModel)
      
      let newAccessToken = tokenExtractor(response)
      try KeychainManager.saveAccessToken(token: newAccessToken)
      
    } catch {
      throw error
    }
  }
}

@available(macOS 12.0, *)
@available(iOS 16, *)
extension IzziSessionManager {
  public func verifyTokenValidity(
    apiEndpoint: String
  ) async throws {
    try await verifyTokenValidity(
      apiEndpoint: apiEndpoint,
      customRequestBuilder: { refreshToken in DefaultRefreshRequestModel(refresh: refreshToken) },
      tokenExtractor: { (response: DefaultTokenResponseModel) in response.access }
    )
  }
}


@available(macOS 12.0, *)
@available(iOS 16, *)
extension IzziSessionManager {
  private func postData<T: Codable, U: Codable>(
    urlString: String,
    headers: [String: String]? = nil,
    body: T
  ) async throws -> U {
    guard let url = URL(string: urlString) else {
      throw NetworkError.invalidURL
    }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    
    if let headers = headers {
      for (key, value) in headers {
        urlRequest.setValue(value, forHTTPHeaderField: key)
      }
    }
    
    if headers?["Content-Type"] == nil {
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    do {
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(body)
      urlRequest.httpBody = jsonData
    } catch {
      print("Encoding Error: \(error)")
      throw NetworkError.decodeError(error: error)
    }
    
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.httpResponseError
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
      print("HTTP Error: Status code \(httpResponse.statusCode)")
      print("Raw response: \(String(data: data, encoding: .utf8) ?? "No response body")")
      throw NetworkError.statusCodeError(statusCode: httpResponse.statusCode)
    }
    
    do {
      let decoder = JSONDecoder()
      let responseData = try decoder.decode(U.self, from: data)
      return responseData
    } catch {
      print("Decoding Error: \(error)")
      print("Raw response: \(String(data: data, encoding: .utf8) ?? "Invalid response")")
      throw NetworkError.decodeError(error: error)
    }
  }
}


