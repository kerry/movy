//
//  RestService.swift
//  Movy
//
//  Created by Prateek Grover on 25/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class RestService{
    
    static let sharedInstance = RestService()
    
    let MOVIE_DB_API_KEY = Bundle.main.object(forInfoDictionaryKey: "MovieDBAPIKey")!
    
    func getMovieListByPopularity(sortOrder: SortOrder, page:Int,completionHandler:@escaping (MovieListResponseDto?, Error?) -> Void){
        
        let sortOrderString = SortOrder.popularity == sortOrder ? "popular" : "top_rated"
        
        let URL = "https://api.themoviedb.org/3/movie/\(sortOrderString)?api_key=\(MOVIE_DB_API_KEY)&page=\(page)"
        Alamofire.request(URL).responseObject { (response: DataResponse<MovieListResponseDto>) in
            let movieListResponse = response.result.value
            if movieListResponse?.page != nil{
                //result is nil or some error occured
                completionHandler(movieListResponse, nil)
            }else{
                completionHandler(nil, nil)
            }
        }
    }
}
