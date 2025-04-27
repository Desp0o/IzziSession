//
//  DefaultRefreshRequestModel.swift
//  IzziAuth
//
//  Created by Despo on 01.04.25.
//


struct DefaultRefreshRequestModel: Codable {
  let refresh: String
}

struct DefaultTokenResponseModel: Codable {
  let access: String
}