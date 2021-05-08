//
//  FlickerCollectionViewControllerTests.swift
//  DeservFlickerChallengeTests
//
//  Created by Saurabh Satwani on 5/9/21.
//  Copyright © 2021 personal. All rights reserved.
//

import XCTest
import UIKit
@testable import DeservFlickerChallenge

class FlickerCollectionViewControllerTests: XCTestCase {

    var viewController: FlickerCollectionViewController?
    
    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        viewController = navigationController.topViewController as? FlickerCollectionViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }

    override func tearDown() {
        viewController = nil
    }
    
    
    func testSetup() {
        XCTAssertNotNil(viewController)
        viewController?.viewDidLoad()
        
        XCTAssertNotNil(viewController!.collectionView)
        XCTAssertNotNil(viewController!.searchTextField)
        
        XCTAssertNotNil(viewController?.collectionView.delegate)
        XCTAssertNotNil(viewController?.collectionView.dataSource)
        XCTAssertNotNil(viewController?.searchTextField.delegate)
    }
    
    func testCollectionViewCell() {
        XCTAssertNotNil(viewController)
        guard let cell = viewController?.collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCell", for: IndexPath(item: 0, section: 0)) as? FlickrPhotoCell else { return }
        cell.awakeFromNib()
        XCTAssertNotNil(cell)
        XCTAssertNotNil(cell.imageView)
        cell.prepareForReuse()
        XCTAssertNil(cell.imageView.image)
        XCTAssertTrue(cell.isKind(of: FlickrPhotoCell.self))
    }
    
    func testActivityIndicator() {
        XCTAssertNotNil(viewController)
        viewController?.searchTextField.becomeFirstResponder()
        viewController?.searchTextField.resignFirstResponder()
        XCTAssertNotNil(viewController?.activityIndicatorView)
    }
}
