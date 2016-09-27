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
    @IBOutlet weak var sortOrderTextField: UITextField!
    
    var sortPickerView: UIPickerView!
    var MOVIE_POSTER_ITEM_SIZE:CGSize?
    var movieSearchController : UISearchController!
    var currentPage:Int = 1
    var movieListToDisplay:[MovieItem] = []
    var movieListFiltered:[MovieItem] = []
    var fullMovieList:[MovieItem] = []
    var currentSortOrder:SortOrder = SortOrder.popularity
    var queryText:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sortPickerView = UIPickerView()
        self.sortPickerView.delegate = self
        self.sortPickerView.dataSource = self
        self.sortOrderTextField.inputView = self.sortPickerView
        ApplicationSettings.resetScreenSizeConstants()
        self.initializeSearchController()
        self.fetchMovies(sortOrder:self.currentSortOrder, page: currentPage, afresh: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.queryText != nil && !self.queryText!.isEmpty{
            self.movieSearchController.searchBar.text = self.queryText
            self.movieSearchController.isActive = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MovieDetailViewController
        destinationVC.movieItem = self.movieListToDisplay[(sender as! IndexPath).item]
    }
    
    fileprivate func initializeSearchController(){
        self.movieSearchController = UISearchController(searchResultsController:  nil)
        
        self.movieSearchController.searchResultsUpdater = self
        self.movieSearchController.delegate = self
        self.movieSearchController.searchBar.delegate = self
        self.movieSearchController.hidesNavigationBarDuringPresentation = false
        self.movieSearchController.dimsBackgroundDuringPresentation = true
        self.movieSearchController.searchBar.placeholder = "Search movies"
        
        self.navigationItem.titleView = self.movieSearchController.searchBar
        
        self.definesPresentationContext = true
    }
    
    internal func fetchMovies(sortOrder:SortOrder ,page:Int, afresh:Bool){
        if afresh{
            self.fullMovieList = []
        }
        if self.queryText != nil && !self.queryText!.isEmpty{
            self.movieSearchController.searchBar.text = self.queryText
            self.movieSearchController.isActive = true
        }
        
        RestService.sharedInstance.getMovieListByPopularity(sortOrder: sortOrder, page: page) { [weak self](movieListResponse:MovieListResponseDto?, error:Error?) in
            
            if let strongSelf = self{
                if error == nil && movieListResponse != nil{
                    strongSelf.currentPage += 1
                    strongSelf.fullMovieList.append(contentsOf: movieListResponse!.movieItemList!)
                    if strongSelf.queryText != nil && !strongSelf.queryText!.isEmpty {
                        strongSelf.movieListFiltered = strongSelf.fullMovieList.filter() { ($0.originalTitle?.lowercased().contains(strongSelf.queryText!))! }
                        strongSelf.movieListToDisplay = strongSelf.movieListFiltered
                    } else {
                        strongSelf.movieListToDisplay = strongSelf.fullMovieList
                    }
                    DispatchQueue.main.async {
                        //reload collection view
                        strongSelf.movieCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movieListToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let moviePosterCell:MovyCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCell", for: indexPath) as! MovyCollectionViewCell
        
        let movieItem = self.movieListToDisplay[indexPath.item]
        
        moviePosterCell.posterImagePath = movieItem.posterPath!
        moviePosterCell.moviePosterImageView.image = self.downloadImage(path: movieItem.posterPath!, indexPath: indexPath)
        moviePosterCell.movieTitleLabel.text = movieItem.originalTitle
        moviePosterCell.layer.shouldRasterize = true
        moviePosterCell.layer.rasterizationScale = UIScreen.main.scale
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "MoviePosterDetailSegue", sender: indexPath)
    }
    
    func loadMoreMovies(){
        print("fetch")
        self.fetchMovies(sortOrder: self.currentSortOrder, page: self.currentPage, afresh: false)
    }
    
    func downloadImage(path:String, indexPath:IndexPath) -> MovyUIImage?{
        let cachedImage = ImageService.sharedInstance.checkCache(path: path)
        if cachedImage != nil{
            return cachedImage
        }
        ImageService.sharedInstance.downloadImage(path: path, forCell: indexPath) {[weak self] (downloadedImage:MovyUIImage?, cellIndexPath:IndexPath?) in
            
            if downloadedImage != nil && cellIndexPath != nil{
                let collectionViewCell = self?.movieCollectionView.cellForItem(at: cellIndexPath!) as? MovyCollectionViewCell
                DispatchQueue.main.async {
                    if collectionViewCell?.posterImagePath == downloadedImage?.urlPath{
                        collectionViewCell?.moviePosterImageView.image = downloadedImage
                    }
                }
            }
        }
        return nil
    }
}

