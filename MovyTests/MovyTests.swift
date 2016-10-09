//
//  MovyTests.swift
//  MovyTests
//
//  Created by Prateek Grover on 25/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Movy

class MovyTests: XCTestCase {
    
    var movieViewModel:MovieViewModel!
    var restService:RestService!
    var imageService:ImageService!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.movieViewModel = MovieViewModel()
        self.restService = RestService.sharedInstance
        self.imageService = ImageService.sharedInstance
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testGetMovieListGoodCase(){
        _ = stub(condition: isHost("api.themoviedb.org")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("response.json", type(of: self))!, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        let responseArrived = self.expectation(description: "response of async request has arrived")
        self.restService.getMovieListByPopularity(sortOrder: SortOrder.popularity, page: 1) { (response:MovieListResponseDto?, error:Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            responseArrived.fulfill()
        }
        waitForExpectations(timeout: 3) { (error:Error?) in
            XCTAssertNil(error, "\(error)")
        }
        OHHTTPStubs.removeAllStubs()
    }
    
    func testGetMovieListOkCase(){
        _ = stub(condition: isHost("api.themoviedb.org")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("responseOkCase.json", type(of: self))!, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        let responseArrived = self.expectation(description: "response of async request has arrived")
        self.restService.getMovieListByPopularity(sortOrder: SortOrder.popularity, page: 1) { (response:MovieListResponseDto?, error:Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            responseArrived.fulfill()
        }
        waitForExpectations(timeout: 3) { (error:Error?) in
            XCTAssertNil(error, "\(error)")
        }
        OHHTTPStubs.removeAllStubs()
    }
    
    func testGetMovieListBadCase(){
        _ = stub(condition: isHost("api.themoviedb.org")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("responseBadCase.json", type(of: self))!, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        let responseArrived = self.expectation(description: "response of async request has arrived")
        self.restService.getMovieListByPopularity(sortOrder: SortOrder.popularity, page: 1) { (response:MovieListResponseDto?, error:Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            responseArrived.fulfill()
        }
        waitForExpectations(timeout: 3) { (error:Error?) in
            XCTAssertNil(error, "\(error)")
        }
        OHHTTPStubs.removeAllStubs()
    }
    
    func testGetImage(){
        _ = stub(condition: isHost("image.tmdb.org")) { _ in
            
            let bundle = Bundle.init(for: type(of:self))
            var responseData:Data? = nil
            
            if let url  = bundle.url(forResource: "poster", withExtension: "jpg"){
                do{
                    responseData = try Data(contentsOf: url)
                }catch{
                    print("image could not be converted to Data")
                }
            }
            
            return OHHTTPStubsResponse(data: responseData!, statusCode: 200, headers: nil)
        }
        
        let responseArrived = self.expectation(description: "image downloading test")
        
        self.imageService.downloadImage(path: "somepath") { (downloadedImage:MovyUIImage?) in
            if downloadedImage != nil{
                XCTAssertEqual(downloadedImage?.urlPath, "somepath")
                responseArrived.fulfill()
            }
        }
        waitForExpectations(timeout: 3) { (error:Error?) in
            XCTAssertNil(error, "\(error)")
        }
        OHHTTPStubs.removeAllStubs()
    }
}
