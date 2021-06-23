//
//  SearchConfigurator.swift
//  Movies
//
//  Created by Александр on 19.06.2021.
//

import Foundation

protocol SearchConfiguratorProtocol: AnyObject {
  func configure(with viewController: SearchCollectionViewController, dataFetcher: DataFetcher, localStorage: MoviesStoreProtocol)
}

class SearchConfigurator: SearchConfiguratorProtocol {
  func configure(with viewController: SearchCollectionViewController, dataFetcher: DataFetcher, localStorage: MoviesStoreProtocol) {
    let presenter = SearchPresenter(view: viewController, dataFetcher: dataFetcher, localStorage: localStorage)
    viewController.presenter = presenter
  }
}
