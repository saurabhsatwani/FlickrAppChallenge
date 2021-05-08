//
//  FlickrViewModel.swift
//  DeservFlickerChallenge
//
//  Created by Saurabh Satwani on 5/8/21.
//  Copyright © 2021 personal. All rights reserved.
//

import Foundation

class FlickrViewModel {
    
    enum FlickrImageTableViewCellType {
        case normal(cellViewModel: FlickrSearchResults)
        case error(message: String)
        case empty
    }
    
    let showLoadingHud: Bindable = Bindable(false)
    let searches = Bindable(FlickrSearchResults(searchTerm: nil, searchResults: nil))
    let flickrImage = Bindable(FlickrImage(imageIndex:nil, imageData: nil))
    
    let appServerClient: AppService
    
    init(appServerClient: AppService = AppService()) {
        self.appServerClient = appServerClient
    }
    
    func getflickrImages(for text: String) {
        showLoadingHud.value = true
        
        
        appServerClient.searchFlickr(for: text) { searchResults in
            self.showLoadingHud.value = false
            
            switch searchResults {
            case .failure(let error) :
                print("Error Searching: \(error)")
            case .success(let results):
                self.searches.value = results
            }
        }
    }
    
    func deleteAllEntries() {
        self.searches.value = FlickrSearchResults(searchTerm: nil, searchResults: nil)
    }
    
    func loadImage(at index: NSNumber?, for urlString: String?) {
        
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
                self.flickrImage.value = FlickrImage(imageIndex: index, imageData: nil)
                return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            self.flickrImage.value = FlickrImage(imageIndex: index, imageData: nil)
            return
        }
        
        self.flickrImage.value = FlickrImage(imageIndex: index, imageData: data)
    }
}




