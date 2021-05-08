//
//  FlickerSearchResults.swift
//  DeservFlickerChallenge
//
//  Created by Saurabh Satwani on 5/7/21.
//  Copyright © 2021 personal. All rights reserved.
//

import Foundation
import UIKit

struct FlickrSearchResults {
  let searchTerm: String?
  let searchResults: [Photo]?
}

struct FlickrImage {
    let imageIndex: NSNumber?
    let imageData: Data?
}
