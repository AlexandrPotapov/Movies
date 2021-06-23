//
//  TopPresenter.swift
//  Movies
//
//  Created by Александр on 19.06.2021.
//

import Foundation

protocol TopViewProtocol: AnyObject {
  func reloadData()
  func hideLoadingView()
  func setImageForFavoriteButton(indexPath: IndexPath)
}

protocol TopViewPresenterProtocol {
  var movies: [MovieModel] { get }
  var moviesCount: Int { get }
  func getTopMovies()
  func movie(atIndex indexPath: IndexPath) -> MovieModel?
  func loadNextPosters()
  func clickFavouriteButton(indexPath: IndexPath)
  func getFavouriteMovies()
}

class TopPresenter: TopViewPresenterProtocol {
  weak var view: TopViewProtocol?
  
  var movies = [MovieModel]()
  var moviesCount = 0

  private var pageCount = 1
  private var totalPages = 0
  private var favouriteMovies = [Movie]()
  
  private let dataFetcher: DataFetcher!
  private let localStorage: MoviesStoreProtocol!
  
  required init(view: TopViewProtocol, dataFetcher: DataFetcher, localStorage: MoviesStoreProtocol) {
    self.view = view
    self.dataFetcher = dataFetcher
    self.localStorage = localStorage
  }
  
  // Запрос к БД за списком избранных фильмов
   func getFavouriteMovies() {
    favouriteMovies.removeAll()
    localStorage.fetchMovies { (movies: () throws -> [Movie]) in
      do {
        self.favouriteMovies = try movies()
        self.setFavourireAttribute()
      } catch let error {
        print(error.localizedDescription)
      }
    }
  }
  
  func setFavourireAttribute() {
    // Меняем значение isFavourite согласно данным из локального хранилища
    for (i, movieModel) in self.movies.enumerated() {
      self.movies[i].isFavourite = false
      if !self.favouriteMovies.isEmpty {
        for favouriteMovie in self.favouriteMovies {
          if favouriteMovie.id == movieModel.movie.id {
            self.movies[i].isFavourite = true
          }
        }
      }
      
    }
    self.view?.reloadData()
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
  
  func loadNextPosters() {
    pageCount += 1
    // Если загружена последняя страница прячем LoadingView и возвращаемся
    if self.totalPages < self.pageCount {
      view?.hideLoadingView()
      return
    }
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
      self.getTopMovies()
    }
  }
  
  
  func getTopMovies() {
    // Делаем запрос к БД за списком избранных фильмов
      getFavouriteMovies()
    // Делаем запрос в интернет для получения фильмов
    dataFetcher.getTopResponse(page: "\(pageCount)") { response in
      guard let response = response else { return }
      let movies =  response.results.filter { $0.posterPath != nil }
      self.totalPages = response.totalPages
      
      for movie in movies {
        self.movies.append(MovieModel(movie: movie))
      }
      
      self.setFavourireAttribute()
    }
  }
  
  // Получаем модель для отображения в ячейке
  func movie(atIndex indexPath: IndexPath) -> MovieModel? {
    if movies.indices.contains(indexPath.row) {
      return movies[indexPath.row]
    } else {
      return nil
    }
  }
}
