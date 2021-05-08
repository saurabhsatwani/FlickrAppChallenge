//
//  Alert.swift
//  DeservFlickerChallenge
//
//  Created by Saurabh Satwani on 5/8/21.
//  Copyright © 2021 personal. All rights reserved.
//

import Foundation

struct AlertAction {
    let buttonTitle: String
    let handler: (() -> Void)?
}

struct SingleButtonAlert {
    let title: String
    let message: String?
    let action: AlertAction
}
