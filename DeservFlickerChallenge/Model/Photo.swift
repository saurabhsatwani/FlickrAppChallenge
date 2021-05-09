//
//  Photo.swift
//  DeservFlickerChallenge
//
//  Created by Saurabh Satwani on 5/7/21.
//  Copyright © 2021 personal. All rights reserved.
//

import Foundation
import UIKit

struct FlickrPhoto: Codable {
    let photos: PhotoDetail?
    let stat: String?
}

struct PhotoDetail: Codable {
    let page: Int?
    let pages: Int?
    let perpage: Int?
    let total: String?
    let photo: [Photo]?
}

 class Photo: Codable {
    let id: String?
    let owner: String?
    let secret: String?
    let farm: Int?
    let server: String?
    let title: String?
    let ispublic: Int?
    let isfriend: Int?
    let isfamily: Int?
    var isValid: Bool?
    
}

extension Photo {
    @objc
    var flickrImageURLString: String? {
        guard let farm = farm,
            let server = server,
            let id = id,
            let secret = secret else {
                return nil
        }
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
    
    var flickrImageURL: URL? {
        if let urlString = flickrImageURLString {
            return URL(string: urlString)
        }
        return nil
    }
    
}
