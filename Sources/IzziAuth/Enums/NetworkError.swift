//
//  NetworkError.swift
//  authTest
//
//  Created by Despo on 01.04.25.
//

enum NetworkError: Error {
    case invalidURL
    case httpResponseError
    case statusCodeError(statusCode: Int)
    case decodeError(error: Error)
    case invalidRequestModel
    case missingTokenInResponse
}
