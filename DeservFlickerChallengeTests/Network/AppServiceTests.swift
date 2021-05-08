//
//  AppServiceTests.swift
//  DeservFlickerChallengeTests
//
//  Created by Saurabh Satwani on 5/8/21.
//  Copyright © 2021 personal. All rights reserved.
//

import XCTest
@testable import DeservFlickerChallenge

class AppServiceTests: XCTestCase {
    
    var appService: AppService?
    
    override func setUpWithError() throws {
        appService = AppService()
    }
    
    override func tearDownWithError() throws {
        appService = nil
    }
    
    func testFlickrSearchUrl() throws {
        
        var statusCode: Int?
        var responseError: Error?
        
        guard let searchURL = appService?.flickrSearchURL(for: "test", pageIndex: 1) else {
            return
        }
        
        let promise = expectation(description: "Flickr Endpoint called")
        
        let dataTask = URLSession.shared.dataTask(with: searchURL) { _, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        dataTask.resume()
        wait(for: [promise], timeout: 5)
        
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
    
    
    func testApiCallCompletes() throws {
        
        var flickrError:FlickrError?
        
        let promise = expectation(description: "Flickr API method called")
        
        appService?.searchFlickr(for: "test", pageIndex: 1, completion: { searchResults in
            switch searchResults {
            case .failure(let error) :
                flickrError = error
            default: break
            }
            promise.fulfill()
        })
        
        wait(for: [promise], timeout: 5)
        
        XCTAssertNil(flickrError)
    }
    
    
    
}
