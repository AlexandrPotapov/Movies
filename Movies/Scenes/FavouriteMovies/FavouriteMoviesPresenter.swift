//
//  FavouriteMoviesPresenter.swift
//  Movies
//
//  Created by Александр on 21.06.2021.
//

import Foundation

protocol FavouriteMoviesViewProtocol: AnyObject {
  func reloadData()
}

protocol FavouriteMoviesViewPresenterProtocol {
  var movies: [MovieModel] { get }
  func getFavouriteMovies()
  func movie(atIndex indexPath: IndexPath) -> MovieModel?
  func clickFavouriteButton(indexPath: IndexPath)
}

class FavouriteMoviesPresenter: FavouriteMoviesViewPresenterProtocol {
  weak var view: FavouriteMoviesViewProtocol?
  
  var movies = [MovieModel]()

  private var pageCount = 1
  private var totalPages = 0
  
  private let localStorage: MoviesStoreProtocol!
  
  required init(view: FavouriteMoviesViewProtocol, localStorage: MoviesStoreProtocol) {
    self.view = view
    self.localStorage = localStorage
  }

  func clickFavouriteButton(indexPath: IndexPath) {
    localStorage.deleteMovie(id: movies[indexPath.row].movie.id) { (movie: () throws ->()?) in
          }
    getFavouriteMovies()
  }
  
  
  func getFavouriteMovies() {
    self.movies.removeAll()
    localStorage.fetchMovies { (movies: () throws -> [Movie]) in
      do {
        let movies = try movies()
        for movie in movies {
          self.movies.append(MovieModel(movie: movie, isFavourite: true))
        }
        self.view?.reloadData()
      } catch let error {
        print(error.localizedDescription)
      }
    }
  }
  
  func movie(atIndex indexPath: IndexPath) -> MovieModel? {
    if movies.indices.contains(indexPath.row) {
      return movies[indexPath.row]
    } else {
      return nil
    }
    
  }
  
}

