//
//  ViewController.swift
//  Movy
//
//  Created by Prateek Grover on 25/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import UIKit
import MBProgressHUD

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate{
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var movieCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var sortSegmentControl: UISegmentedControl!
    
    var MOVIE_POSTER_ITEM_SIZE:CGSize?
    var movieSearchController : UISearchController!
    var queryText:String?
    
    let movieViewModel:MovieViewModel = MovieViewModel()
    
    let LOAD_MORE_FOOTER_VIEW_IDENTIFIER = "LoadMoreFooterView"
    let MOVIE_DETAILS_SEGUE_IDENTIFIER = "MoviePosterDetailSegue"
    let MOVIE_POSTER_CELL_IDENTIFIER = "MoviePosterCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeMovieList()
        self.setupSort()
        self.initializeSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        
        if self.queryText != nil && !self.queryText!.isEmpty{
            self.movieSearchController.searchBar.text = self.queryText
            self.movieSearchController.isActive = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.showErrorDialog(notification:)), name: MovieViewModel.onErrorLoadingMovies, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.showErrorDialog(notification:)), name: MovieViewModel.onEmptyMoviesListFound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.showErrorDialog(notification:)), name: MovieViewModel.onNoMatchingMoviesFound, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeMovieList(){
        self.showHUD(message: FETCHING_MOVIES_LOADER_MESSAGE)
        self.movieViewModel.updateMovies(shouldFilter: false, queryText: nil) {[weak self] (success:Bool) in
            self?.hideHUD()
            self?.reloadMoviesCollectionView()
        }
    }
    
    func setupSort(){
        self.sortSegmentControl.addTarget(self, action: #selector(HomeViewController.sortChanged), for: .valueChanged)
    }
    
    func showHUD(message:String){
        DispatchQueue.main.async {
            let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
            loader.mode = MBProgressHUDMode.indeterminate
            loader.label.text = message
        }
    }
    
    func showErrorDialog(notification:NSNotification){
        self.hideHUD()
        
        var message = "";
        switch notification.name {
        case MovieViewModel.onErrorLoadingMovies:
            message = ERROR_LOADING_MOVIES_MESSAGE
        case MovieViewModel.onEmptyMoviesListFound:
            message = NO_MORE_MOVIES_FOUND_MESSAGE
        case MovieViewModel.onNoMatchingMoviesFound:
            message = NO_MATCHING_MOVIES_FOUND_MESSAGE
        default:
            message = ERROR_LOADING_MOVIES_MESSAGE
        }
        
        DispatchQueue.main.async {
            let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
            loader.mode = MBProgressHUDMode.text
            loader.label.text = message
            loader.hide(animated: true, afterDelay: 3)
        }
    }
    
    func hideHUD(){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MovieDetailViewController
        destinationVC.movieItem = self.movieViewModel.movieListToDisplay[(sender as! IndexPath).item]
        destinationVC.movieViewModel = self.movieViewModel
    }
    
    fileprivate func initializeSearchController(){
        self.movieSearchController = UISearchController(searchResultsController:  nil)
        
        self.movieSearchController.searchResultsUpdater = self
        self.movieSearchController.delegate = self
        self.movieSearchController.searchBar.delegate = self
        self.movieSearchController.hidesNavigationBarDuringPresentation = false
        self.movieSearchController.dimsBackgroundDuringPresentation = false
        self.movieSearchController.searchBar.placeholder = MOVIE_SEARCH_BAR_PLACEHOLDER
        
        self.navigationItem.titleView = self.movieSearchController.searchBar
        
        self.definesPresentationContext = true
    }
    
    func reloadMoviesCollectionView(){
        DispatchQueue.main.async {
            self.movieCollectionView.reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movieViewModel.movieListToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let moviePosterCell:MovyCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.MOVIE_POSTER_CELL_IDENTIFIER, for: indexPath) as! MovyCollectionViewCell
        
        let movieItem = self.movieViewModel.movieListToDisplay[indexPath.item]
        moviePosterCell.configureCell(movieTitle: movieItem.originalTitle!, moviePosterImagePath: movieItem.posterPath!, movieViewModel: self.movieViewModel)
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
            footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: self.LOAD_MORE_FOOTER_VIEW_IDENTIFIER, for: indexPath) as! LoadMoreFooterView
            footerView.loadMoreButton.setTitle(LOAD_MORE_BUTTON_TITLE, for: .normal)
            footerView.loadMoreButton.addTarget(self, action: #selector(HomeViewController.loadMoreMovies), for: .touchUpInside)
        }
        
        return footerView;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: self.MOVIE_DETAILS_SEGUE_IDENTIFIER, sender: indexPath)
    }
    
    func loadMoreMovies(){
        self.showHUD(message: FETCHING_MOVIES_LOADER_MESSAGE)
        self.movieViewModel.updateMovies(shouldFilter: true, queryText: self.queryText) {[weak self] (success:Bool) in
            self?.hideHUD()
            self?.reloadMoviesCollectionView()
        }
    }
}

