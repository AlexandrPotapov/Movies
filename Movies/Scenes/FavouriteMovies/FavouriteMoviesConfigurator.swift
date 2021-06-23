//
//  FavouriteMoviesConfigurator.swift
//  Movies
//
//  Created by Александр on 21.06.2021.
//

import Foundation

protocol FavouriteMoviesConfiguratorProtocol: AnyObject {
    func configure(with viewController: FavouriteMoviesCollectionViewController, localStorage: MoviesStoreProtocol)
}

class FavouriteMoviesConfigurator: FavouriteMoviesConfiguratorProtocol {
    func configure(with viewController:FavouriteMoviesCollectionViewController, localStorage: MoviesStoreProtocol) {
      let presenter = FavouriteMoviesPresenter(view: viewController, localStorage: localStorage)
        viewController.presenter = presenter
    }
}
