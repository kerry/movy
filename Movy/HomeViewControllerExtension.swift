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
        self.movieListFiltered = self.fullMovieList.filter() { ($0.originalTitle?.lowercased().contains(queryText!))! }
        self.movieListToDisplay = self.movieListFiltered
        self.movieCollectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.queryText = ""
        self.movieListToDisplay = self.fullMovieList
        self.movieCollectionView.reloadData()
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
        print(row)
        self.currentSortOrder = row == 0 ? SortOrder.popularity : SortOrder.rating
        self.sortOrderTextField.text = self.currentSortOrder.rawValue
        self.sortOrderTextField.resignFirstResponder()
        self.currentPage = 1
        self.fetchMovies(sortOrder:self.currentSortOrder, page:self.currentPage, afresh: true)
    }
}
