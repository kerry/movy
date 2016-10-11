//
//  MovyUITests.swift
//  MovyUITests
//
//  Created by Prateek Grover on 25/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import XCTest
import SBTUITestTunnel

class MovyUITests: XCTestCase {
        
    var app: SBTUITunneledApplication!
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = true
        
        app = SBTUITunneledApplication()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadMoreWorstCase() {
        app.launchTunnel { 
            self.app.stubRequests(matching: SBTRequestMatch.url("(.*)themoviedb(.*)"), return: "no response".data(using: String.Encoding.utf8)!, contentType: "application/json", returnCode: 404, responseTime: 0.5)

        }
        
        app.buttons["Load more"].tap()
        
        XCTAssert(app.staticTexts["Error loading movies"].exists, "HUD not shown")
        
        app.stubRequestsRemoveAll()
    }
    
    func testResetAnotherSortView(){
        let collectionView = app.collectionViews.element(boundBy: 0)

        let filePath = Bundle(for: type(of: self)).path(forResource: "responseSingle", ofType: "json")
        var returnData:Data!
        do{
            returnData = try Data.init(contentsOf: URL(fileURLWithPath: filePath!))
        }catch{
            
        }
        
        app.launchTunnel {
            self.app.stubRequests(matching: SBTRequestMatch.url("(.*)themoviedb.org\\/3\\/movie\\/popular.*"), return: returnData, contentType: "application/json", returnCode: 200, responseTime: 0.5)
            self.app.stubRequests(matching: SBTRequestMatch.url("(.*)themoviedb.org\\/3\\/movie\\/top_rated.*"), return: "no response".data(using: String.Encoding.utf8)!, contentType: "application/json", returnCode: 404, responseTime: 0)
            
        }
        
        XCTAssert(collectionView.cells.count == 1, "More than 1 cell found")
        
        app.buttons["Top Rated"].tap()
        
        XCTAssert(collectionView.cells.count == 0, "cells found even though should not")
        
        app.stubRequestsRemoveAll()
    }
    
    func testCancelSearchButton(){
        let collectionView = app.collectionViews.element(boundBy: 0)
        
        let filePath = Bundle(for: type(of: self)).path(forResource: "responseSingle", ofType: "json")
        var returnData:Data!
        do{
            returnData = try Data.init(contentsOf: URL(fileURLWithPath: filePath!))
        }catch{
            
        }
        
        app.launchTunnel {
            self.app.stubRequests(matching: SBTRequestMatch.url("(.*)themoviedb.org\\/3\\/movie\\/popular.*"), return: returnData, contentType: "application/json", returnCode: 200, responseTime: 0.5)            
        }
        
        let movyHomeviewNavigationBar = app.navigationBars["Movy.HomeView"]
        let searchMoviesSearchField = movyHomeviewNavigationBar.searchFields["Search movies"]
        searchMoviesSearchField.tap()
        searchMoviesSearchField.typeText("captain")
        
        XCTAssert(collectionView.cells.count == 0, "More than 0 cell found")
        
        let cancelButton = movyHomeviewNavigationBar.buttons["Cancel"]
        cancelButton.tap()
        
        XCTAssert(collectionView.cells.count == 1, "More than 1 cell found")
    }
    
}
