//
//  FlickerViewModelTests.swift
//  DeservFlickerChallengeTests
//
//  Created by Saurabh Satwani on 5/8/21.
//  Copyright © 2021 personal. All rights reserved.
//

import XCTest
@testable import DeservFlickerChallenge

class FlickrViewModelTests: XCTestCase {
    
    var appServerClient: AppService?
    var viewModel: FlickrViewModel?
    
    override func setUpWithError() throws {
        appServerClient = MockAppServerClient()
        viewModel = FlickrViewModel(appServerClient: appServerClient ?? AppService())
    }
    
    override func tearDownWithError() throws {
        appServerClient = nil
        viewModel = nil
    }
    
    func testGetFlickrImage() {
        viewModel?.getflickrImages(for: "test")
        let searchResult = viewModel?.searches.value
        
        XCTAssertEqual(searchResult?.searchResults?.count, 1)
        XCTAssertEqual(searchResult?.searchResults?.first?.owner, "Saurabh")
        
        return
    }
    
    func testLoadImage() {
        let appServerClient = MockAppServerClient()
        
        let viewModel = FlickrViewModel(appServerClient: appServerClient)
        viewModel.loadImage(at: NSNumber(integerLiteral: 1), for: "https://picsum.photos/200")
        
        let expectListenerCalled = expectation(description: "Load Image is called")
        viewModel.loadImage(at: NSNumber(integerLiteral: 1), for: "https://picsum.photos/200")
        expectListenerCalled.fulfill()
        
        XCTAssertNotNil(viewModel.flickrImage.value.imageData)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testDeleteAllEntries() {
        viewModel?.deleteAllEntries()
        XCTAssertNil(viewModel?.searches.value.searchResults)
    }
}


private final class MockAppServerClient: AppService {
    
    override func searchFlickr(for searchTerm: String, completion: @escaping (Result<FlickrSearchResults, FlickrError>) -> Void) {
        completion(.success(FlickrSearchResults(searchTerm: "Test", searchResults: [Photo(id: nil, owner: "Saurabh", secret: nil, farm: nil, server: nil, title: nil, ispublic: nil, isfriend: nil, isfamily: nil)])))
    }
    
    
}
