//
//  ViewController.swift
//  Movy
//
//  Created by Prateek Grover on 25/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchResultsUpdating, UIScrollViewDelegate {
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var movieCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var sortPickerView: UIPickerView!
    
    @IBOutlet weak var sortOrderTextField: UITextField!
    
    var MOVIE_POSTER_ITEM_SIZE:CGSize?
    var movieSearchController : UISearchController!
    var currentPage:Int = 1
    
    var tempNumberOfCells = 10
    
    var loadMoreButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sortPickerView.delegate = self
        self.sortPickerView.dataSource = self
        self.sortOrderTextField.inputView = self.sortPickerView
        ApplicationSettings.resetScreenSizeConstants()
        self.initializeSearchController()
        self.fetchMovies(page: currentPage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initializeSearchController(){
        //initialize searchResultsController where all the results will be shown
        let movieSearchResultsController = self.storyboard?.instantiateViewController(withIdentifier: "MovieSearchResultsTable") as! MovieSearchResultsTableViewController
        
        self.movieSearchController = UISearchController(searchResultsController:  movieSearchResultsController)
        
        self.movieSearchController.searchResultsUpdater = self
        self.movieSearchController.delegate = self
        self.movieSearchController.hidesNavigationBarDuringPresentation = false
        self.movieSearchController.dimsBackgroundDuringPresentation = true
        self.movieSearchController.searchBar.placeholder = "Search movies"
        
        self.navigationItem.titleView = self.movieSearchController.searchBar
        
        self.definesPresentationContext = true
    }
    
    fileprivate func fetchMovies(page:Int){
        RestService.sharedInstance.getMovieListByPopularity(page: page) { (movieListResponse:MovieListResponseDto?, error:Error?) in
            
            if error == nil && movieListResponse != nil{
                self.currentPage += 1
                //reload collection view
            }
        }
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        let searchResultsController = searchController.searchResultsController as! MovieSearchResultsTableViewController
        searchResultsController.tableView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tempNumberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let moviePosterCell:MovyCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCell", for: indexPath) as! MovyCollectionViewCell
        
        moviePosterCell.moviePosterImageView.image = UIImage(named: "fight_club.jpg")
        
        return moviePosterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //reset movie poster size on screen orientation change
        if(self.MOVIE_POSTER_ITEM_SIZE != nil){
            return self.MOVIE_POSTER_ITEM_SIZE!
        }else{
            guard let collectionFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
                return CGSize(width: 50, height: 75)
            }
            
            let widthAvailbleForAllItems =  (collectionView.frame.width - collectionFlowLayout.sectionInset.left - collectionFlowLayout.sectionInset.right)
            
            let widthForOneItem = widthAvailbleForAllItems / CGFloat(ApplicationSettings.NO_COLUMNS) - collectionFlowLayout.minimumInteritemSpacing
            
            self.MOVIE_POSTER_ITEM_SIZE = CGSize(width: CGFloat(widthForOneItem), height: ((CGFloat(widthForOneItem)/(CGFloat(50)))*collectionFlowLayout.itemSize.height))
            
            return MOVIE_POSTER_ITEM_SIZE!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var footerView:LoadMoreFooterView!
        
        if kind == UICollectionElementKindSectionFooter {
            footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "LoadMoreFooterView", for: indexPath) as! LoadMoreFooterView
            
            footerView.loadMoreButton.addTarget(self, action: #selector(HomeViewController.loadMoreMovies), for: .touchUpInside)
        }
        
        return footerView;
    }
    
    func loadMoreMovies(){
        print("fetch")
        self.fetchMovies(page: self.currentPage)
        self.tempNumberOfCells += 10
        self.movieCollectionView.reloadData()
    }
}

