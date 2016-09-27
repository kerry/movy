//
//  MovieDetailViewController.swift
//  Movy
//
//  Created by Prateek Grover on 25/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    var movieItem:MovieItem!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userRatingLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var plotSynopsisLabel: UILabel!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var imageDownloadingActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = self.movieItem?.originalTitle
        self.userRatingLabel.text = "\((self.movieItem?.voteAverage)!)"
        self.releaseDateLabel.text = self.movieItem?.releaseDate
        self.plotSynopsisLabel.text = self.movieItem?.overview
        self.moviePosterImageView.image = self.downloadImage(path: self.movieItem.posterPath!)
        self.imageDownloadingActivityIndicator.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Details"
    }
    
    func downloadImage(path:String) -> MovyUIImage?{
        let cachedImage = ImageService.sharedInstance.checkCache(path: path)
        if cachedImage != nil{
            self.imageDownloadingActivityIndicator.stopAnimating()
            return cachedImage
        }
        ImageService.sharedInstance.downloadImage(path: path) {[weak self] (downloadedImage:MovyUIImage?) in
            
            if downloadedImage != nil{
                DispatchQueue.main.async {
                    self?.imageDownloadingActivityIndicator.stopAnimating()
                    self?.moviePosterImageView.image = downloadedImage
                }
            }
        }
        return nil
    }
}
