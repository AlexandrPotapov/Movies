//
//  Movie.swift
//  Movies
//
//  Created by Александр on 17.06.2021.
//

import Foundation

struct Response: Decodable {
  let page: Int
  let results: [Movie]
  let totalPages: Int
  let totalResults: Int
}

struct Movie: Decodable {
  let id: Int
  let title: String
  let posterPath: String?
}

struct MovieModel {
  let movie: Movie
  var isFavourite: Bool = false
}
