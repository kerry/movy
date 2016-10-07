//
//  HomeViewControllerExtension.swift
//  Movy
//
//  Created by Prateek Grover on 26/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation
import UIKit

extension HomeViewController : UISearchResultsUpdating, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SortOrder.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0{
            return SortOrder.popularity.rawValue
        }else{
            return SortOrder.rating.rawValue
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tempSelectedSortOrder = row == 0 ? SortOrder.popularity : SortOrder.rating
    }
    
    func donePicker(){
        self.cancelPicker()
        let tempCurrentState = self.movieViewModel.currentMovieListState
        if tempCurrentState.currentSortOrder != self.tempSelectedSortOrder{
            
            self.movieViewModel.currentMovieListState.currentSortOrder = self.tempSelectedSortOrder
            self.movieViewModel.currentMovieListState.currentPage = 1
            
            self.sortOrderTextField.text = self.tempSelectedSortOrder.rawValue
            //fetch new movies according to new sort order
            self.showHUD(message: FETCHING_MOVIES_LOADER_MESSAGE)
            self.movieViewModel.updateMovies(shouldFilter: true, queryText: self.queryText, fetchSuccess: {[weak self] (success:Bool) in
                
                self?.hideHUD()
                self?.reloadMoviesCollectionView()
            })
        }
    }
    
    func cancelPicker(){
        self.sortOrderTextField.resignFirstResponder()
    }
}
