//
//  FlickrViewModel.swift
//  DeservFlickerChallenge
//
//  Created by Saurabh Satwani on 5/8/21.
//  Copyright © 2021 personal. All rights reserved.
//

import Foundation

class FlickrViewModel {
        
    let showLoadingHud: Bindable = Bindable(false)
    let searches = Bindable(FlickrSearchResults(searchTerm: nil, searchResults: nil))
    let flickrImage = Bindable(FlickrImage(imageIndex:nil, imageData: nil))
    var onShowError: ((_ alert: SingleButtonAlert) -> Void)?
    
    let appServerClient: AppService
    
    init(appServerClient: AppService = AppService()) {
        self.appServerClient = appServerClient
    }
    
    func getflickrImages(for text: String) {
        showLoadingHud.value = true
        
        
        appServerClient.searchFlickr(for: text) { [weak self] searchResults in
            self?.showLoadingHud.value = false
            
            switch searchResults {
            case .failure(let error) :
                print("Error Searching: \(error)")
                let okAlert = SingleButtonAlert(
                    title: "Error",
                    message: error.rawValue,
                    action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                )
                self?.onShowError?(okAlert)
            case .success(let results):
                if results.searchResults?.count == 0 {
                    let okAlert = SingleButtonAlert(
                        title: "Please try again",
                        message: "Could not find any entry for \(results.searchTerm ?? "")",
                        action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                    )
                    self?.onShowError?(okAlert)
                }
                self?.searches.value = results
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




