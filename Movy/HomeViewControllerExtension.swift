//
//  HomeViewControllerExtension.swift
//  Movy
//
//  Created by Prateek Grover on 26/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import UIKit

extension HomeViewController : UISearchResultsUpdating, UISearchBarDelegate{
    
    public func updateSearchResults(for searchController: UISearchController) {
        let queryText = searchController.searchBar.text?.lowercased()
        if queryText != nil && queryText!.isEmpty{
            return
        }
        self.queryText = queryText
        self.movieViewModel.updateFilteredMovieList(queryText: self.queryText)
        self.reloadMoviesCollectionView()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.queryText = ""
        self.movieViewModel.updateFilteredMovieList(queryText: self.queryText)
        self.reloadMoviesCollectionView()
    }
    
    func sortChanged(){
        let tempSelectedSortOrder = self.sortSegmentControl.selectedSegmentIndex == 0 ? SortOrder.popularity : SortOrder.rating
        let tempCurrentState = self.movieViewModel.currentMovieListState
        
        if tempCurrentState.currentSortOrder != tempSelectedSortOrder{
            
            self.movieViewModel.currentMovieListState.currentSortOrder = tempSelectedSortOrder
            self.movieViewModel.currentMovieListState.currentPage = 1
            
            //fetch new movies according to new sort order
            self.showDialogService.showHUD(message: FETCHING_MOVIES_LOADER_MESSAGE.localized)
            self.movieViewModel.updateMovies(shouldFilter: true, queryText: self.queryText, fetchSuccess: {[weak self] (success:Bool) in
                if success{
                    self?.showDialogService.hideHUD()
                }
                self?.reloadMoviesCollectionView()
            })
        }
    }
}
