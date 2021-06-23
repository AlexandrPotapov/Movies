//
//  NetworkDataFetcher.swift
//  Movies
//
//  Created by Александр on 17.06.2021.
//

import Foundation

protocol DataFetcher {
  func getPopularResponse(page: String, response: @escaping (Response?) -> Void)
  func getTopResponse(page: String, response: @escaping (Response?) -> Void)
  func getSearchResponse(page: String, query: String, response: @escaping (Response?) -> Void)
}

class NetworkDataFetcher: DataFetcher {
  
  private let networking : NetworkingProtocol
  
  
  init(networking: NetworkingProtocol = NetworkService()) {
      self.networking = networking
  }
  
  func getPopularResponse(page: String, response: @escaping (Response?) -> Void) {
    let params = ["page" : page]
    networking.request(path: API.popular, params: params) { (data, error) in
      if let error = error {
        print("Error received requesting data: \(error.localizedDescription)")
        response(nil)
      }
      guard let data = data else { return }
      
      let decoded = self.decodeJSON(type: Response.self, from: data)
      response(decoded)
    }
  }
  
  func getTopResponse(page: String, response: @escaping (Response?) -> Void) {
    let params = ["page" : page]
    networking.request(path: API.top, params: params) { (data, error) in
      if let error = error {
        print("Error received requesting data: \(error.localizedDescription)")
        response(nil)
      }
      guard let data = data else { return }
      
      let decoded = self.decodeJSON(type: Response.self, from: data)
      response(decoded)
    }
  }
  
  func getSearchResponse(page: String, query: String, response: @escaping (Response?) -> Void) {
    let params = ["page" : page, "query" : query]
    networking.request(path: API.search, params: params) { (data, error) in
      if let error = error {
        print("Error received requesting data: \(error.localizedDescription)")
        response(nil)
      }
      guard let data = data else { return }
      
      let decoded = self.decodeJSON(type: Response.self, from: data)
      response(decoded)
    }
  }
  
  private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    guard let data = from, let response = try? decoder.decode(type.self, from: data) else { return nil }
    return response
  }
  
}
