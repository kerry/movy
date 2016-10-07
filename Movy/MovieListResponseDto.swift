//
//  MovieListResponseDTO.swift
//  Movy
//
//  Created by Prateek Grover on 25/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 "page": 1,
 "results": [
 {
 "poster_path": "/5N20rQURev5CNDcMjHVUZhpoCNC.jpg",
 "adult": false,
 "overview": "Following the events of Age of Ultron, the collective governments of the world pass an act designed to regulate all superhuman activity. This polarizes opinion amongst the Avengers, causing two factions to side with Iron Man or Captain America, which causes an epic battle between former allies.",
 "release_date": "2016-04-27",
 "genre_ids": [
 28,
 53,
 878
 ],
 "id": 271110,
 "original_title": "Captain America: Civil War",
 "original_language": "en",
 "title": "Captain America: Civil War",
 "backdrop_path": "/rqAHkvXldb9tHlnbQDwOzRi0yVD.jpg",
 "popularity": 38.221894,
 "vote_count": 2984,
 "video": false,
 "vote_average": 6.83
 },
 */

class MovieListResponseDto : Mappable{
    var page : Int?
    var movieItemList : [MovieItem]?
    
    required init?(map: Map){
        
    }
    
    init() {}
    
    func mapping(map: Map){
        page <- map["page"]
        movieItemList <- map["results"]
    }
}
