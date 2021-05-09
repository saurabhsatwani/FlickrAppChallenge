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
        
        let expection = expectation(description: "Get Flickr API is called")
        viewModel?.getflickrImages(for: "test")
        expection.fulfill()


        let photoArray = viewModel?.retrievedPhotos.value
        
        XCTAssertEqual(photoArray?.count, 1)
        XCTAssertEqual(photoArray?.first?.owner, "8740272@N04")
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testLoadImage() {
        
        let photoModel = Photo.createFromJSON()

        let expection = expectation(description: "Load Image is called")
        viewModel?.loadImage(for: photoModel)
        expection.fulfill()
        
        XCTAssertNotNil(viewModel?.flickrImage.value.imageData)
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testResetAllEntries() {
        viewModel?.resetAll()
        XCTAssertNil(viewModel?.searches.value.searchResults)
    }
}


private final class MockAppServerClient: AppService {
    
    override  func searchFlickr(for searchTerm: String, pageIndex: Int, completion: @escaping (Result<FlickrSearchResults, FlickrError>) -> Void)  {
        completion(.success(FlickrSearchResults(searchTerm: "Test", searchResults: [Photo.createFromJSON()!])))
    }
}

extension Photo {
    
    static func createFromJSON(_ fileName: String = "MockPhoto") -> Photo? {
        var data = Data()
        let url = Bundle.main.url(forResource: fileName, withExtension: "json")
        do {
            data = try Data(contentsOf: url!)
            return try? JSONDecoder().decode(Photo.self, from: data)
        } catch let error {
            debugPrint(error)
            return nil
        }
    }
}



