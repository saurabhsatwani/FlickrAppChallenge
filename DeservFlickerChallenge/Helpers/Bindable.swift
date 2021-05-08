//
//  Bindable.swift
//  DeservFlickerChallenge
//
//  Created by Saurabh Satwani on 5/7/21.
//  Copyright © 2021 personal. All rights reserved.
//

import Foundation

class Bindable<T> {
    typealias Listener = ((T) -> Void)
    var listener: Listener?

    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ v: T) {
        self.value = v
    }

    func bind(_ listener: Listener?) {
        self.listener = listener
    }

    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }

}
