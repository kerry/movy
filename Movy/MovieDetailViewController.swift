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
    var movieViewModel:MovieViewModel!

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
        self.setPosterImage()
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
    
    fileprivate func setPosterImage(){
        self.moviePosterImageView.image = self.movieViewModel.getImage(forPath: self.movieItem.posterPath!, completionHandler: { [weak self](posterImage:MovyUIImage) in
            self?.moviePosterImageView.image = posterImage
        })
    }
}
