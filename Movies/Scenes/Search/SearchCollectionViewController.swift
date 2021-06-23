//
//  SearchCollectionViewController.swift
//  Movies
//
//  Created by Александр on 19.06.2021.
//

import UIKit

class SearchCollectionViewController: UICollectionViewController {
  
  var presenter: SearchViewPresenterProtocol!
  var loadingView: LoadingReusableView?

  private var networkDataFetcher = NetworkDataFetcher()
  private let configurator: SearchConfiguratorProtocol = SearchConfigurator()
  private let searchController = UISearchController(searchResultsController: nil)
  
  private let localStorage = FavouriteMoviesCoreDataStore.instance

  
  override func viewDidLoad() {
    super.viewDidLoad()
    //Register Item Cell
    let posterCollectionViewCell = UINib(nibName: "PosterCollectionViewCell", bundle: nil)
    self.collectionView.register(posterCollectionViewCell, forCellWithReuseIdentifier: PosterCollectionViewCell.reuseId)
    //Register Loading Reuseable View
    let loadingReusableNib = UINib(nibName: "LoadingReusableView", bundle: nil)
    self.collectionView.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loadingresuableviewid")
    
    title = "Search"
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search"
    definesPresentationContext = false
    navigationItem.searchController = searchController
    searchController.searchBar.delegate = self
    configurator.configure(with: self, dataFetcher: networkDataFetcher, localStorage: localStorage)
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
    
    guard let movie = presenter.movie(atIndex: indexPath)  else { return UICollectionViewCell() }
    cell.set(movieModel: movie)
    cell.onClickCallback = {
      self.presenter.clickFavouriteButton(indexPath: indexPath)
    }
    return cell
  }
  
  
}


// MARK: SearchrViewProtocol
extension SearchCollectionViewController: SearchViewProtocol {
  func setImageForFavoriteButton(indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! PosterCollectionViewCell
    cell.set(movieModel: presenter.movies[indexPath.row])
    DispatchQueue.main.async {
      UIView.performWithoutAnimation {
        self.collectionView.reloadItems(at: [indexPath])
      }
    }
  }
  
  func hideLoadingView(_ hide: Bool) {
    DispatchQueue.main.async {
      self.loadingView?.isHidden = hide
    }
  }
  
  func reloadData() {
    DispatchQueue.main.async {
      self.collectionView.reloadData()
    }
  }
}

// MARK: UISearchDelegate
extension SearchCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
  func updateSearchResults(for searchController: UISearchController) {
    guard let query = searchController.searchBar.text else { return }
    presenter.getSearchWith(query: query, getNextPage: false)
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    presenter.cancellSearch()
  }
}


// MARK: Loading View
extension SearchCollectionViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.bounds.size.width, height: 55)
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionFooter {
      let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "loadingresuableviewid", for: indexPath) as! LoadingReusableView
      loadingView = aFooterView
      loadingView?.backgroundColor = UIColor.clear
      loadingView?.isHidden = true
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
      presenter.getNextSearchPage()
    }
  }
}
