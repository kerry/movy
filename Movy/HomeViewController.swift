//
//  ViewController.swift
//  Movy
//
//  Created by Prateek Grover on 25/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate{
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var movieCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var sortSegmentControl: UISegmentedControl!
    
    var MOVIE_POSTER_ITEM_SIZE:CGSize?
    var movieSearchController : UISearchController!
    var queryText:String?
    
    let movieViewModel:MovieViewModel = MovieViewModel()
    var showDialogService:ShowDialogService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showDialogService = ShowDialogService(context: self.view)
        self.initializeMovieList()
        self.setupSort()
        self.initializeSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showDialogService.addNotificationObservers()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        
        if self.queryText != nil && !self.queryText!.isEmpty{
            self.movieSearchController.searchBar.text = self.queryText
            self.movieSearchController.isActive = true
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.showDialogService.removeNotificationObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeMovieList(){
        self.showDialogService.showHUD(message: FETCHING_MOVIES_LOADER_MESSAGE.localized)
        self.movieViewModel.updateMovies(shouldFilter: false, queryText: nil) {[weak self] (success:Bool) in
            self?.showDialogService.hideHUD()
            self?.reloadMoviesCollectionView()
        }
    }
    
    func setupSort(){
        self.sortSegmentControl.addTarget(self, action: #selector(HomeViewController.sortChanged), for: .valueChanged)
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
        self.movieSearchController.searchBar.placeholder = MOVIE_SEARCH_BAR_PLACEHOLDER.localized
        
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
        
        let moviePosterCell:MovyCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: MOVIE_POSTER_CELL_IDENTIFIER, for: indexPath) as! MovyCollectionViewCell
        
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
            footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LOAD_MORE_FOOTER_VIEW_IDENTIFIER, for: indexPath) as! LoadMoreFooterView
            footerView.loadMoreButton.setTitle(LOAD_MORE_BUTTON_TITLE.localized, for: .normal)
            footerView.loadMoreButton.addTarget(self, action: #selector(HomeViewController.loadMoreMovies), for: .touchUpInside)
        }
        
        return footerView;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: MOVIE_DETAILS_SEGUE_IDENTIFIER, sender: indexPath)
    }
    
    func loadMoreMovies(){
        self.showDialogService.showHUD(message: FETCHING_MOVIES_LOADER_MESSAGE.localized)
        self.movieViewModel.updateMovies(shouldFilter: true, queryText: self.queryText) {[weak self] (success:Bool) in
            self?.showDialogService.hideHUD()
            self?.reloadMoviesCollectionView()
        }
    }
}

