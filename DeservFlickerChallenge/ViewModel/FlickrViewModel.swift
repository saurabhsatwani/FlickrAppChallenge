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
    let retrievedPhotos = Bindable([Photo]())
    var onResetView: (()->Void)?
    let flickrImage = Bindable(FlickrImage(photoObject:nil, imageData: nil))
    var onShowError: ((_ alert: SingleButtonAlert) -> Void)?
    
    let appServerClient: AppService
    
    init(appServerClient: AppService = AppService()) {
        self.appServerClient = appServerClient
    }
    
    func getflickrImages(for text: String, pageIndex: Int = 1) {
        showLoadingHud.value = true
        
        
        appServerClient.searchFlickr(for: text, pageIndex: pageIndex) { [weak self] searchResults in
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
                self?.retrievedPhotos.value = results.searchResults ?? []
            }
        }
    }
    
    func deleteAllEntries() {
        self.searches.value = FlickrSearchResults(searchTerm: nil, searchResults: nil)
        self.retrievedPhotos.value = []
        self.onResetView?()
    }
    
    func resetAll() {
        self.searches.value = FlickrSearchResults(searchTerm: nil, searchResults: nil)
        self.retrievedPhotos.value = []
        self.onResetView?()
    }
    
    func loadImage(for photoObj: Photo?) {
        
        guard let urlString = photoObj?.flickrImageURLString,
            let url = URL(string: urlString) else {
                self.flickrImage.value = FlickrImage(photoObject: photoObj, imageData: nil)
                return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            self.flickrImage.value = FlickrImage(photoObject: photoObj, imageData: nil)
            return
        }
        
        self.flickrImage.value = FlickrImage(photoObject: photoObj, imageData: data)
    }
}




