//
//  WebImageView.swift
//  Movies
//
//  Created by Александр on 18.06.2021.
//

import UIKit

class WebImageView: UIImageView {
  
  private var currentUrlString: String?
  
  func set(filePath: String) {
    
    let baseUrl = "https://image.tmdb.org/t/p/"
    let fileSize = "w300"
    let imageURL = baseUrl + fileSize + filePath
    currentUrlString = imageURL
    guard let url = URL(string: imageURL) else { return }
    
    if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
      self.image = UIImage(data: cachedResponse.data)
      return
    }
    
    
    let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
      DispatchQueue.main.async {
        if let data = data, let response = response {
          self?.handleLoadedImage(data: data, response: response)
        }
      }
    }
    dataTask.resume()
  }
  
  private func handleLoadedImage(data: Data, response: URLResponse) {
    guard let responseURL = response.url else { return }
    let cashedResponse = CachedURLResponse.init(response: response, data: data)
    URLCache.shared.storeCachedResponse(cashedResponse, for: URLRequest(url: responseURL))
    
    if responseURL.absoluteString == currentUrlString {
      self.image = UIImage(data: data)
    }
  }
}
