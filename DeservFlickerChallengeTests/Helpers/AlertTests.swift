//
//  AlertTests.swift
//  DeservFlickerChallengeTests
//
//  Created by Saurabh Satwani on 5/8/21.
//  Copyright © 2021 personal. All rights reserved.
//


import XCTest
@testable import DeservFlickerChallenge

class AlertTests: XCTestCase {
    
    func testAlert() {
        let expectAlertActionHandlerCall = expectation(description: "Alert action handler called")

        let alert = SingleButtonAlert(
            title: "",
            message: "",
            action: AlertAction(buttonTitle: "", handler: {
                expectAlertActionHandlerCall.fulfill()
            })
        )

        alert.action.handler!()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

}
