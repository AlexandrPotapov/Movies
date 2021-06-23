//
//  TopConfigurator.swift
//  Movies
//
//  Created by Александр on 19.06.2021.
//

import Foundation

protocol TopConfiguratorProtocol: AnyObject {
    func configure(with viewController: TopCollectionViewController, dataFetcher: DataFetcher, localStorage: MoviesStoreProtocol)
}

class TopConfigurator: TopConfiguratorProtocol {
    func configure(with viewController:TopCollectionViewController, dataFetcher: DataFetcher, localStorage: MoviesStoreProtocol) {
      let presenter = TopPresenter(view: viewController, dataFetcher: dataFetcher, localStorage: localStorage)
        viewController.presenter = presenter
    }
}
