//
//  PopularConfigurator.swift
//  Movies
//
//  Created by Александр on 18.06.2021.
//

import Foundation

protocol PopularConfiguratorProtocol: AnyObject {
  func configure(with viewController:PopularCollectionViewController, dataFetcher: DataFetcher, localStorage: MoviesStoreProtocol)
}

class PopularConfigurator: PopularConfiguratorProtocol {
    func configure(with viewController:PopularCollectionViewController, dataFetcher: DataFetcher, localStorage: MoviesStoreProtocol) {
      let presenter = PopularPresenter(view: viewController, dataFetcher: dataFetcher, localStorage: localStorage)
        viewController.presenter = presenter
    }
}
