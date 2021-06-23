//
//  SearchOperation.swift
//  StockMonitoring
//
//  Created by Александр on 30.04.2021.
//

import Foundation
import UIKit

protocol FoundSymbolsString {
  var foundMovies: [Movie]? { get  }
}

class SearchOperation: AsyncOperation {
  private var query: String
  private var page: String
  private let completion: (Response?) -> ()
  
  
  public init(page: String, query: String, completion: @escaping (Response?) -> ()) {
    self.page = page
    self.query = query
    self.completion = completion
    super.init()
  }
  override public func main() {
    if self.isCancelled { return }
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
      if self.isCancelled { return }
      NetworkDataFetcher().getSearchResponse(page: self.page, query: self.query) { [ weak self ] (searchResult) in
        guard let searchResult = searchResult else { return }
        if self?.isCancelled == true { return }
        self?.completion(searchResult)
        self?.state = .finished
      }
    }
  }
}
