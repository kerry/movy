//
//  SortOrderEnum.swift
//  Movy
//
//  Created by Prateek Grover on 27/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation

enum SortOrder : String {
    case popularity = "Popularity"
    case rating = "Top Rated"
    
    static var count: Int { return SortOrder.rating.hashValue + 1}
}
