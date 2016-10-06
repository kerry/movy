//
//  MovyCollectionViewCell.swift
//  Movy
//
//  Created by Prateek Grover on 25/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import UIKit

class MovyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    var movieViewModel:MovieViewModel!
    var posterImagePath:String?
    
    func configureCell(movieTitle:String, moviePosterImagePath:String, movieViewModel:MovieViewModel){
        self.movieViewModel = movieViewModel
        
        self.movieTitleLabel.text = movieTitle
        self.posterImagePath = moviePosterImagePath
        self.moviePosterImageView.image = self.movieViewModel.getImage(forPath: moviePosterImagePath, completionHandler: { [weak self](posterImage:MovyUIImage) in
            if let strongSelf = self{
                if posterImage.urlPath == strongSelf.posterImagePath{
                    strongSelf.moviePosterImageView.image = posterImage
                }
            }
        })
        self.optimizeCellRendering()
    }
    
    fileprivate func optimizeCellRendering(){
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
