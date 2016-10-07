//
//  MovieViewModel.swift
//  Movy
//
//  Created by Prateek Grover on 06/10/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation

class MovieViewModel{
    
    let restService = RestService.sharedInstance
    
    var movieListToDisplay:[MovieItem] = []
    fileprivate var movieListFiltered:[MovieItem] = []
    fileprivate var fullMovieList:[MovieItem] = []
    
    static let onErrorLoadingMovies = Notification.Name("on-error-loading-movies")
    static let onEmptyMoviesListFound = Notification.Name("on-empty-movies-found")
    static let onNoMatchingMoviesFound = Notification.Name("on-no-matching-movies-found")
    
    internal struct MovieListState {
        var currentSortOrder:SortOrder
        var currentPage:Int
    }
    
    var currentMovieListState:MovieListState = MovieListState(currentSortOrder: SortOrder.popularity, currentPage: 1)
    
    init(){
        ApplicationSettings.resetScreenSizeConstants()
    }
    
    func updateMovies(shouldFilter:Bool, queryText:String?, fetchSuccess:@escaping (Bool) -> Void){
        self.fetchMovies(movieListState: self.currentMovieListState) {[weak self] (movieItemList:[MovieItem]?, error:Error?) in
            if let strongSelf = self{
                if error == nil && movieItemList != nil{
                    //notify about more movies loaded
                    if strongSelf.currentMovieListState.currentPage == 1{
                        //this means that it should be a fresh search
                        strongSelf.fullMovieList = []
                    }
                    
                    if movieItemList!.count == 0{
                        //empty list retrieved
                        NotificationCenter.default.post(name: MovieViewModel.onEmptyMoviesListFound, object: nil)
                        return
                    }
                    
                    strongSelf.currentMovieListState.currentPage += 1
                    
                    strongSelf.fullMovieList.append(contentsOf: movieItemList!)
                    
                    if shouldFilter{
                        strongSelf.movieListToDisplay = strongSelf.filterMovieList(queryText: queryText, movieListToFilter: strongSelf.fullMovieList)!
                    }else{
                        strongSelf.movieListToDisplay = strongSelf.fullMovieList
                    }
                    
                    if strongSelf.movieListToDisplay.count == 0{
                        //empty list retrieved
                        NotificationCenter.default.post(name: MovieViewModel.onNoMatchingMoviesFound, object: nil)
                        return
                    }
                    
                    fetchSuccess(true)
                }else{
                    //show error in view that movie items could not be fetched
                    fetchSuccess(false)
                }
            }
        }
    }
    
    func updateFilteredMovieList(queryText:String?){
        let filteredMovieList = filterMovieList(queryText: queryText, movieListToFilter: self.fullMovieList)
        
        if filteredMovieList != nil{
            self.movieListToDisplay = filteredMovieList!
        }
    }
    
    func getImage(forPath posterImagePath:String, completionHandler:@escaping (MovyUIImage) -> Void) -> MovyUIImage?{
        let cachedImage = ImageService.sharedInstance.checkCache(path: posterImagePath)
        if cachedImage != nil{
            return cachedImage
        }
        ImageService.sharedInstance.downloadImage(path: posterImagePath) { (downloadedImage:MovyUIImage?) in
            
            if downloadedImage != nil {
                completionHandler(downloadedImage!)
            }
        }
        return nil
    }
    
    fileprivate func filterMovieList(queryText:String?, movieListToFilter:[MovieItem]?) -> [MovieItem]?{
        
        guard let movieList = movieListToFilter else {
            return nil
        }
        
        guard let queryString = queryText else {
            return movieList
        }
        
        if !queryString.isEmpty{
            if !movieList.isEmpty{
                return movieList.filter() { ($0.originalTitle?.lowercased().contains(queryString))! }
            }else{
                return movieList
            }
        }
        
        return movieList
    }
    
    fileprivate func fetchMovies(movieListState:MovieListState, completionHandler:@escaping ([MovieItem]?, Error?) -> Void){
        
        restService.getMovieListByPopularity(sortOrder: movieListState.currentSortOrder,
                                             page: movieListState.currentPage) {(movieListResponse:MovieListResponseDto?, error:Error?) in
            
            if error == nil && movieListResponse != nil{
                completionHandler(movieListResponse!.movieItemList!, nil)
            }else{
                completionHandler(nil, error)
            }
        }
    }
}
