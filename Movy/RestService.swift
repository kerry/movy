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
    
    func getMovieListByPopularity(){
        
        let URL = "https://api.themoviedb.org/3/movie/popular?api_key=ef0311a4195b185865b08825a6ee7dfd"
        
        Alamofire.request(URL).responseObject { (response: DataResponse<MovieListResponseDto>) in
            let movieListResponse = response.result.value
            print(movieListResponse?.page)
        }
    }
}
