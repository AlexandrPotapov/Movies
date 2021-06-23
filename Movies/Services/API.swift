//
//  API.swift
//  Movies
//
//  Created by Александр on 17.06.2021.
//

import Foundation

struct API {
    static let scheme = "https"
    static let host = "api.themoviedb.org"
    static let version = 3

    static let popular = "/movie/popular"
    static let top = "/movie/top_rated"
    static let search = "/search/movie"
}
