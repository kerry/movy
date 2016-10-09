//
//  MovieViewModelTests.swift
//  Movy
//
//  Created by Prateek Grover on 09/10/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Movy

class MovieViewModelTests: XCTestCase {
    
    var movieViewModel:MovieViewModel!
    var restService:RestService!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.movieViewModel = MovieViewModel()
        self.restService = RestService.sharedInstance
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFilterMovieList(){
        _ = stub(condition: isHost("api.themoviedb.org")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("response.json", type(of: self))!, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        let responseArrived = self.expectation(description: "response of async request has arrived")
        
        self.restService.getMovieListByPopularity(sortOrder: SortOrder.popularity, page: 1) { [weak self](response:MovieListResponseDto?, error:Error?) in
            self?.movieViewModel.fullMovieList = response!.movieItemList!
            responseArrived.fulfill()
        }
        waitForExpectations(timeout: 3) {[weak self] (error:Error?) in
            self?.movieViewModel.updateFilteredMovieList(queryText: nil)
            XCTAssertTrue(self?.movieViewModel.movieListToDisplay.count == self?.movieViewModel.fullMovieList.count, "Querytext nil failed")
            
            self?.movieViewModel.updateFilteredMovieList(queryText: "")
            XCTAssertTrue(self?.movieViewModel.movieListToDisplay.count == self?.movieViewModel.fullMovieList.count, "QueryText empty failed")
            
            self?.movieViewModel.updateFilteredMovieList(queryText: "captain")
            XCTAssertTrue(self?.movieViewModel.movieListToDisplay.count == 1, "QueryText Captain failed")
            
            self?.movieViewModel.updateFilteredMovieList(queryText: "vhgjv")
            XCTAssertTrue(self?.movieViewModel.movieListToDisplay.count == 0, "QueryText No match failed")
        }
        
        OHHTTPStubs.removeAllStubs()
    }
}
