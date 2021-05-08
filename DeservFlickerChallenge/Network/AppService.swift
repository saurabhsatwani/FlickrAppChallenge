//
//  AppService.swift
//  DeservFlickerChallenge
//
//  Created by Saurabh Satwani on 5/7/21.
//  Copyright © 2021 personal. All rights reserved.
//

import Foundation
import UIKit

// MARK: - AppService
enum FlickrError: String, Error {
    case unknownAPIResponse = "API is not supported!"
    case generic = "Some error occured, Please try again!"
    case dataFormat = "Data format is corrupt! "
}

class AppService {
    
    let apiKey = "2932ade8b209152a7cbb49b631c4f9b6"
    
    func searchFlickr(for searchTerm: String, completion: @escaping (Result<FlickrSearchResults, FlickrError>) -> Void) {
        
        guard let searchURL = flickrSearchURL(for: searchTerm) else {
            completion(.failure(FlickrError.unknownAPIResponse))
            return
        }
        
        URLSession.shared.dataTask(with: URLRequest(url: searchURL)) { data, response, error in
            if error != nil {
                completion(.failure(FlickrError.generic))
                return
            }
            
            guard
                (response as? HTTPURLResponse) != nil,
                let data = data
                else {
                    completion(.failure(FlickrError.unknownAPIResponse))
                    return
            }
            
            do {
                guard
                    let resultsDictionary = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject],
                    let stat = resultsDictionary["stat"] as? String
                    else {
                        completion(.failure(FlickrError.dataFormat))
                        return
                }
                
                switch stat {
                case "ok":
                    print("Results processed OK")
                case "fail":
                    completion(.failure(FlickrError.generic))
                    return
                default:
                    completion(.failure(FlickrError.unknownAPIResponse))
                    return
                }
                

                let decoder = JSONDecoder()
                do {
                    let flickerPhoto = try decoder.decode(FlickrPhoto.self, from: data)
                    let searchResults = FlickrSearchResults(searchTerm: searchTerm, searchResults: flickerPhoto.photos?.photo)
                    completion(.success(searchResults))
                    print(flickerPhoto)
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(FlickrError.dataFormat))
                }
            } catch {
                completion(.failure(FlickrError.generic))
                return
            }
        }
        .resume()
    }
        
    func flickrSearchURL(for searchTerm: String) -> URL? {
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&format=json&nojsoncallback=1"
        return URL(string: URLString)
    }
}
