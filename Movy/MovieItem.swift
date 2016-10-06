//
//  MovieItem.swift
//  Movy
//
//  Created by Prateek Grover on 25/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation
import ObjectMapper

/*
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
}*/

class MovieItem : Mappable {
    var posterPath : String?
    var adult : Bool?
    var overview : String?
    var releaseDate : String?
    var genreIds : [Int]?
    var id : Int64?
    var originalTitle : String?
    var originalLanguage : String?
    var title : String?
    var backdropPath : String?
    var popularity : Double?
    var voteCount : Int64?
    var video : Bool?
    var voteAverage : Double?
    
    required init?(map: Map){
        
    }
    
    init() {
        
    }
    
    func mapping(map: Map){
        posterPath <- map["poster_path"]
        adult <- map["adult"]
        overview <- map["overview"]
        releaseDate <- map["release_date"]
        genreIds <- map["genre_ids"]
        id <- map["id"]
        originalTitle <- map["original_title"]
        originalLanguage <- map["original_language"]
        title <- map["title"]
        backdropPath <- map["backdrop_path"]
        popularity <- map["popularity"]
        voteCount <- map["vote_count"]
        video <- map["video"]
        voteAverage <- map["vote_average"]
    }
}
