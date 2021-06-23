//
//  PosterCollectionViewCell.swift
//  Movies
//
//  Created by Александр on 17.06.2021.
//

import UIKit

class PosterCollectionViewCell: UICollectionViewCell {

  @IBOutlet weak var posterImage: WebImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var favouriteButton: UIButton!
  
  var onClickCallback: (() -> Void)?
  
  var isFavourite = false
  
  func changeImage() {
    if isFavourite {
      favouriteButton.imageView?.image = UIImage(named: "Star")
    } else {
      favouriteButton.imageView?.image = UIImage(named: "STAR")
    }
  }
  
  static let reuseId = "PosterCell"
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  func set(movieModel: MovieModel) {
    guard let filePath = movieModel.movie.posterPath else { return }
    posterImage.set(filePath: filePath)
    titleLabel.text = movieModel.movie.title
    isFavourite = movieModel.isFavourite
    if isFavourite {
      favouriteButton.imageView?.image = UIImage(named: "Star")
    } else {
      favouriteButton.imageView?.image = UIImage(named: "STAR")

    }
  }
  

  @IBAction func favouriteButtonAction(_ sender: UIButton) {
    onClickCallback!()
  }
}
