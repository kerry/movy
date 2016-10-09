//
//  MovieViewModel.swift
//  Movy
//
//  Created by Prateek Grover on 06/10/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation

class MovieViewModel{
    
    static let onError = Notification.Name("on-error")

    let restService = RestService.sharedInstance
    let reachabilityInstance = ReachabilityWrapper.sharedInstance
    
    var movieListToDisplay:[MovieItem] = []
    var fullMovieList:[MovieItem] = []
    var currentMovieListState:MovieListState = MovieListState(currentSortOrder: SortOrder.popularity, currentPage: 1)
    
    internal struct MovieListState {
        var currentSortOrder:SortOrder
        var currentPage:Int
    }
    
    init(){
        ApplicationSettings.resetScreenSizeConstants()
    }
    
    func updateMovies(shouldFilter:Bool, queryText:String?, fetchSuccess:@escaping (Bool) -> Void){
        
        if !reachabilityInstance.isReachable(){
            NotificationCenter.default.post(name: MovieViewModel.onError, object: nil, userInfo: [ERROR_NOTIFICATION_MESSAGE_KEY:NETWORK_UNAVAILABLE.localized])
            return
        }
        
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
                        NotificationCenter.default.post(name: MovieViewModel.onError, object: nil, userInfo: [ERROR_NOTIFICATION_MESSAGE_KEY:NO_MORE_MOVIES_FOUND_MESSAGE.localized])
                        return
                    }
                    
                    strongSelf.fullMovieList.append(contentsOf: movieItemList!)
                    
                    if shouldFilter{
                        strongSelf.movieListToDisplay = strongSelf.filterMovieList(queryText: queryText, movieListToFilter: strongSelf.fullMovieList)!
                    }else{
                        strongSelf.movieListToDisplay = strongSelf.fullMovieList
                    }
                    
                    if strongSelf.movieListToDisplay.count == 0{
                        //empty list retrieved
                        NotificationCenter.default.post(name: MovieViewModel.onError, object: nil, userInfo: [ERROR_NOTIFICATION_MESSAGE_KEY:NO_MATCHING_MOVIES_FOUND_MESSAGE.localized])
                        return
                    }
                    
                    strongSelf.currentMovieListState.currentPage += 1
                    
                    fetchSuccess(true)
                }else{
                    //show error in view that movie items could not be fetched
                    NotificationCenter.default.post(name: MovieViewModel.onError, object: nil, userInfo: [ERROR_NOTIFICATION_MESSAGE_KEY:ERROR_LOADING_MOVIES_MESSAGE.localized])
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
    
    func getImage(forPath posterImagePath:String, completionHandler:@escaping (MovyUIImage) -> Void){
        let cachedImage = ImageService.sharedInstance.checkCache(path: posterImagePath)
        if cachedImage != nil{
            completionHandler(cachedImage!)
            return
        }
        
        if !reachabilityInstance.isReachable(){
            NotificationCenter.default.post(name: MovieViewModel.onError, object: nil, userInfo: [ERROR_NOTIFICATION_MESSAGE_KEY:NETWORK_UNAVAILABLE.localized])
            return
        }
        
        ImageService.sharedInstance.downloadImage(path: posterImagePath) { (downloadedImage:MovyUIImage?) in
            
            if downloadedImage != nil {
                completionHandler(downloadedImage!)
            }
        }
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
