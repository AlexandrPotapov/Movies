//
//  SearchPresenter.swift
//  Movies
//
//  Created by Александр on 19.06.2021.
//
//

import Foundation
protocol SearchViewProtocol: AnyObject {
  func reloadData()
  func hideLoadingView(_ hide: Bool)
  func setImageForFavoriteButton(indexPath: IndexPath)
}

protocol SearchViewPresenterProtocol {
  var movies: [MovieModel] { get }
  func getSearchWith(query: String, getNextPage: Bool)
  func getNextSearchPage()
  func movie(atIndex indexPath: IndexPath) -> MovieModel?
  func cancellSearch()
  func clickFavouriteButton(indexPath: IndexPath)
}

class SearchPresenter: SearchViewPresenterProtocol {
  weak var view: SearchViewProtocol?
  
  var movies = [MovieModel]()
  var searchMovies = [Movie]()

  private var pageCount = 1
  private var totalPages = 0
  private var query = ""
  private var favouriteMovies = [Movie]()
  
  private let dataFetcher: DataFetcher!
  private let searchOperationQueue = OperationQueue()
  private let localStorage: MoviesStoreProtocol!
  
  required init(view: SearchViewProtocol, dataFetcher: DataFetcher, localStorage: MoviesStoreProtocol) {
    self.view = view
    self.dataFetcher = dataFetcher
    self.localStorage = localStorage
  }
  
  // Запрос к БД за списком избранных фильмов
  private func getFavouriteMovies() {
    favouriteMovies.removeAll()
    localStorage.fetchMovies { (movies: () throws -> [Movie]) in
      do {
        self.favouriteMovies = try movies()
      } catch let error {
        print(error.localizedDescription)
      }
    }
  }
  
  func clickFavouriteButton(indexPath: IndexPath) {
    // Если муви не избранно, добавляем его в список избранных
    if !movies[indexPath.row].isFavourite {
      localStorage.createMovie(movieToCreate: movies[indexPath.row].movie) { (movie: () throws -> Movie?) in
        do {
          guard let movie = try movie() else { return }
          self.favouriteMovies.append(movie)
          self.movies[indexPath.row].isFavourite = true
        } catch let error {
          print(error.localizedDescription)
        }
      }
    } else {
      // Если муви было избранно, то удаляем его из списка
      self.movies[indexPath.row].isFavourite = false
      for (index, favouriteMovie) in  favouriteMovies.enumerated() {
        if favouriteMovie.id == movies[indexPath.row].movie.id {
          self.favouriteMovies.remove(at: index)
          localStorage.deleteMovie(id: movies[indexPath.row].movie.id) { (movie: () throws ->()?) in
          }
        }
      }
    }
    // Обновляем ячейку согласно новым данным
    view?.setImageForFavoriteButton(indexPath: indexPath)
  }
  
  func getNextSearchPage() {
    let getNextPage = true
    if self.totalPages < self.pageCount {
      view?.hideLoadingView(true)
      return
    }
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
      self.getSearchWith(query: self.query, getNextPage: getNextPage)
      
    }
  }
  
  func cancellSearch() {
    movies = [MovieModel]()
    view?.reloadData()
  }
  
  
  func getSearchWith(query: String, getNextPage: Bool) {
    // Делаем запрос к БД за списком избранных фильмов
      getFavouriteMovies()

    guard query != "" else { return }
    view?.hideLoadingView(false)
    self.query = query
    searchOperationQueue.cancelAllOperations()
    if !getNextPage {
      self.pageCount = 1
    }
    let searchOperation = SearchOperation(page: "\(pageCount)", query: query) { response in

      guard let response = response else { return }
      let movies = response.results.filter { $0.posterPath != nil }
      self.totalPages = response.totalPages
      if !getNextPage {
        self.searchMovies = movies
      } else {
        self.searchMovies += movies
      }
      self.movies.removeAll()

      for movie in self.searchMovies {
        self.movies.append(MovieModel(movie: movie))
      }
      print(self.movies.count)

      // Меняем значение isFavourite согласно данным из локального хранилища
      if !self.favouriteMovies.isEmpty {
        for (i, movieModel) in self.movies.enumerated() {
          self.movies[i].isFavourite = false
          for (x, favouriteMovie) in self.favouriteMovies.enumerated() {
            if favouriteMovie.id == movieModel.movie.id {
              self.movies[i].isFavourite = true
              self.favouriteMovies[x] = (self.movies[i].movie)
            }
          }
        }
        
      }
      self.view?.reloadData()
    }
    searchOperationQueue.addOperation(searchOperation)
    pageCount += 1
  }
  
  func movie(atIndex indexPath: IndexPath) -> MovieModel? {
    if movies.indices.contains(indexPath.row) {
      return movies[indexPath.row]
    } else {
      return nil
    }
    
  }
  
}
