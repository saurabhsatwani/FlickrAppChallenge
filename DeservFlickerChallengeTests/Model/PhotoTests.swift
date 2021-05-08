//
//  PhotoTests.swift
//  DeservFlickerChallengeTests
//
//  Created by Saurabh Satwani on 5/8/21.
//  Copyright © 2021 personal. All rights reserved.
//

import XCTest
@testable import DeservFlickerChallenge

class PhotoTests: XCTestCase {
    
    func testSuccessfulInit() {
        let testSuccessfulJSON: JSON = ["id": "1",
                                        "owner": "Saurabh",
                                        "secret": "secret",
                                        "farm": 29,
                                        "server": "server",
                                        "title": "title",
                                        "ispublic": 12,
                                        "isfriend": 12,
                                        "isfamily": 12
        ]
        
        let decoder = JSONDecoder()
        
        if let data = try? JSONSerialization.data(withJSONObject: testSuccessfulJSON, options: .prettyPrinted) {
        let testPhoto = try! decoder.decode(Photo.self, from: data)
        XCTAssertNotNil(testPhoto)
    }
}
}

