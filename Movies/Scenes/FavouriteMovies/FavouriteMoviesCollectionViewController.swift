//
//  FavouriteMoviesCollectionViewController.swift
//  Movies
//
//  Created by Александр on 21.06.2021.
//

import UIKit

class FavouriteMoviesCollectionViewController: UICollectionViewController {
  
  
  var presenter: FavouriteMoviesViewPresenterProtocol!
  
  private var localStorage = FavouriteMoviesCoreDataStore.instance

  private let configurator: FavouriteMoviesConfiguratorProtocol = FavouriteMoviesConfigurator()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //Register Item Cell
    let posterCollectionViewCell = UINib(nibName: "PosterCollectionViewCell", bundle: nil)
    self.collectionView.register(posterCollectionViewCell, forCellWithReuseIdentifier: PosterCollectionViewCell.reuseId)
    configurator.configure(with: self, localStorage: localStorage)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    presenter.getFavouriteMovies()
  }
  
  
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return presenter.movies.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.reuseId, for: indexPath) as! PosterCollectionViewCell
    
    guard let movieModel = presenter.movie(atIndex: indexPath)  else { return UICollectionViewCell() }
    cell.set(movieModel: movieModel)
    cell.onClickCallback = {
      self.presenter.clickFavouriteButton(indexPath: indexPath)
      
    }
    return cell
  }
}

// MARK: FavouriteMoviesViewProtocol
extension FavouriteMoviesCollectionViewController: FavouriteMoviesViewProtocol {
  
  func reloadData() {
    DispatchQueue.main.async {
      self.collectionView.reloadData()
    }
  }
}

