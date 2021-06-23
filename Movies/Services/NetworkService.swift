//
//  NetworkService.swift
//  Movies
//
//  Created by Александр on 17.06.2021.
//

import Foundation

protocol NetworkingProtocol {
  func request(path: String, params: [String: String], completion: @escaping (Data?, Error?) -> Void)
}

class NetworkService: NetworkingProtocol {
  
  private let apiKey = "apiKey"
  
  func request(path: String, params: [String : String], completion: @escaping (Data?, Error?) -> Void) {
    var allParams = params
    allParams["api_key"] = apiKey
    let url = url(from: path, params: allParams)
    let request = URLRequest(url: url)
    let task = createDataTask(from: request, completion: completion)
    task.resume()
  }
  
  private func url(from path: String, params: [String: String]) -> URL {
    var components = URLComponents()
    components.scheme = API.scheme
    components.host = API.host
    components.path = "/\(API.version)" + path
    components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
    return components.url ?? URL(fileURLWithPath: "")
  }
  
  private func createDataTask(from request: URLRequest, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {
    return URLSession.shared.dataTask(with: request) { data, response, error in
      DispatchQueue.main.async {
        completion(data, error)
      }
    }
  }
}
