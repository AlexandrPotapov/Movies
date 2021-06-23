//
//  FavouriteMoviesStore.swift
//  Movies
//
//  Created by Александр on 21.06.2021.
//

import Foundation
import CoreData

class FavouriteMoviesCoreDataStore: MoviesStoreProtocol {
    
    static let instance = FavouriteMoviesCoreDataStore()
    
    
    // MARK: - Managed object contexts
    
    static private var _mainManagedObjectContext: NSManagedObjectContext?
    static var mainManagedObjectContext: NSManagedObjectContext
    {
        get
        {
            if _mainManagedObjectContext == nil {
                _mainManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            }
            return _mainManagedObjectContext!
        }
        set
        {
            _mainManagedObjectContext = newValue
        }
    }
    
    // MARK: - Object lifecycle
    
    init()
    {
        guard let modelURL = Bundle.main.url(forResource: "Movies", withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        FavouriteMoviesCoreDataStore.mainManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        FavouriteMoviesCoreDataStore.mainManagedObjectContext.persistentStoreCoordinator = psc
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]

        let storeURL = docURL.appendingPathComponent("Movies.sqlite")
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }
    
    deinit
    {
        do {
            try FavouriteMoviesCoreDataStore.mainManagedObjectContext.save()
        } catch {
            fatalError("Error deinitializing main managed object context")
        }
    }
    
    // MARK: - CRUD operations - Optional error
    
    func fetchMovies(completionHandler: @escaping (() throws -> [Movie]) -> Void)
    {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavouriteMovie")
            let results = try FavouriteMoviesCoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [FavouriteMovie]
            var movies = [Movie]()
            for favouriteMovie in results {
              movies.append(Movie(id: Int(favouriteMovie.id), title: favouriteMovie.title! , posterPath: favouriteMovie.posterPath))
            }
            DispatchQueue.main.async {
                completionHandler { return movies}
            }
        } catch {
            DispatchQueue.main.async {
                completionHandler { throw MoviesStoreError.CannotFetch("Cannot fetch movies") }
            }
        }
    }
        
    
    func createMovie(movieToCreate: Movie, completionHandler: @escaping (() throws -> Movie?) -> Void)
    {
        do {
            let favouriteMovie = NSEntityDescription.insertNewObject(forEntityName: "FavouriteMovie", into: FavouriteMoviesCoreDataStore.mainManagedObjectContext) as! FavouriteMovie
          let movie = movieToCreate
            
          favouriteMovie.id = Int64(movie.id)
          favouriteMovie.title = movie.title
          favouriteMovie.posterPath = movie.posterPath
            try FavouriteMoviesCoreDataStore.mainManagedObjectContext.save()
            completionHandler {return movie }
        } catch {
            DispatchQueue.main.async {
                completionHandler { throw MoviesStoreError.CannotCreate("Cannot create movie with title \(String(describing: movieToCreate.title))") }
            }
        }
    }
    
    func deleteMovie(id: Int, completionHandler: @escaping (() throws -> ()?) -> Void)
    {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavouriteMovie")
            fetchRequest.predicate = NSPredicate(format: "id == %d", Int64(id))
            let results = try FavouriteMoviesCoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [FavouriteMovie]
            if let favouriteMovie = results.first {
              FavouriteMoviesCoreDataStore.mainManagedObjectContext.delete(favouriteMovie)
                try FavouriteMoviesCoreDataStore.mainManagedObjectContext.save()
}
        } catch {
            DispatchQueue.main.async {
                completionHandler { throw MoviesStoreError.CannotDelete("Cannot fetch movie with id \(id) to id") }
            }
        }
    }
}

enum MoviesStoreResult<U>
{
    case Success(result: U)
    case Failure(error: MoviesStoreError)
}

// MARK: - Orders store CRUD operation errors

enum MoviesStoreError: Equatable, Error
{
    case CannotFetch(String)
    case CannotCreate(String)
    case CannotDelete(String)
    case CannotUpdate(String)
}

func ==(lhs: MoviesStoreError, rhs: MoviesStoreError) -> Bool
{
    switch (lhs, rhs) {
    case (.CannotFetch(let a), .CannotFetch(let b)) where a == b: return true
    case (.CannotCreate(let a), .CannotCreate(let b)) where a == b: return true
    case (.CannotDelete(let a), .CannotDelete(let b)) where a == b: return true
    default: return false
    }
}


protocol MoviesStoreProtocol
{
    
    func fetchMovies(completionHandler: @escaping (() throws -> [Movie]) -> Void)
    func createMovie(movieToCreate: Movie, completionHandler: @escaping (() throws -> Movie?) -> Void)
    func deleteMovie(id: Int, completionHandler: @escaping (() throws -> ()?) -> Void)
}

