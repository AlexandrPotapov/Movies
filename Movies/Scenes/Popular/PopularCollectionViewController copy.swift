//
//  PopularCollectionViewController.swift
//  Movies
//
//  Created by Александр on 17.06.2021.
//

import UIKit


class PopularCollectionViewController: UICollectionViewController {
  
  
  var presenter: PopularViewPresenterProtocol!
  
  private var loadingView: LoadingReusableView?
  
  private let networkDataFetcher = NetworkDataFetcher()
  private let localStorage = FavouriteMoviesCoreDataStore.instance
  private let configurator: PopularConfiguratorProtocol = PopularConfigurator()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //Register Item Cell
    let posterCollectionViewCell = UINib(nibName: "PosterCollectionViewCell", bundle: nil)
    self.collectionView.register(posterCollectionViewCell, forCellWithReuseIdentifier: PosterCollectionViewCell.reuseId)
    
    //Register Loading Reuseable View
    let loadingReusableNib = UINib(nibName: "LoadingReusableView", bundle: nil)
    self.collectionView.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loadingresuableviewid")
    
    configurator.configure(with: self, dataFetcher: networkDataFetcher, localStorage: localStorage)
    presenter.getFavouriteMovies()
    presenter.getPopularMovies()

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

// MARK: PopularViewProtocol
extension PopularCollectionViewController: PopularViewProtocol {
  func hideLoadingView() {
    loadingView?.isHidden = true
  }
  
  func setImageForFavoriteButton(indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! PosterCollectionViewCell
    cell.set(movieModel: presenter.movies[indexPath.row])
    DispatchQueue.main.async {
      UIView.performWithoutAnimation {
        self.collectionView.reloadItems(at: [indexPath])
      }
    }
  }
  
  func reloadData() {
    DispatchQueue.main.async {
      self.collectionView.reloadData()
    }
  }  
}

// MARK: Loading View
extension PopularCollectionViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.bounds.size.width, height: 55)
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionFooter {
      let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "loadingresuableviewid", for: indexPath) as! LoadingReusableView
      loadingView = aFooterView
      loadingView?.backgroundColor = UIColor.clear
      return aFooterView
    }
    return UICollectionReusableView()
  }
  
  override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
    if elementKind == UICollectionView.elementKindSectionFooter {
      self.loadingView?.activityIndicator.startAnimating()
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
    if elementKind == UICollectionView.elementKindSectionFooter {
      self.loadingView?.activityIndicator.stopAnimating()
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if indexPath.row == presenter.movies.count - 1  {
      presenter.loadNextPosters()
    }
  }
}
