//
//  FlickerCollectionViewController.swift
//  DeservFlickerChallenge
//
//  Created by Saurabh Satwani on 5/8/21.
//  Copyright © 2021 personal. All rights reserved.
//

import UIKit


final class FlickerCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        }
    }
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private let reuseIdentifier = "FlickrCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let itemsPerRow: CGFloat = 3
    var viewModel = FlickrViewModel()
    
    private let cache = NSCache<NSNumber, UIImage>()
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.view.backgroundColor = UIColor.white
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.showLoadingHud.bind { [weak self] visible in
            DispatchQueue.main.async {
                visible ? self?.activityIndicatorView.startAnimating() : self?.activityIndicatorView.stopAnimating()
            }
        }
        
        viewModel.searches.bind { [weak self] resultArray in
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        }
        
        viewModel.flickrImage.bind { [weak self] (flickrImage) in
            
            guard let index = flickrImage.imageIndex else {return}
            
            guard let data = flickrImage.imageData else {
                let image = UIImage(named: "placeholder") ?? UIImage()
                self?.cache.removeObject(forKey: index)
                self?.cache.setObject(image, forKey: index)
                return
            }
            
            guard let image = UIImage(data: data) else {return}
            self?.cache.removeObject(forKey: index)
            self?.cache.setObject(image, forKey: index)
            
            DispatchQueue.main.async {
                self?.collectionView.reloadItems(at: [IndexPath(item: Int(truncating: index), section: 0)])
            }
        }
        
        viewModel.onShowError = { [weak self] alert in
            DispatchQueue.main.async {
                self?.presentSingleButtonDialog(alert: alert)
            }
        }
    }
    
    func presentSingleButtonDialog(alert: SingleButtonAlert) {
        let alertController = UIAlertController(title: alert.title,
                                                message: alert.message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: alert.action.buttonTitle,
                                                style: .default,
                                                handler: { _ in alert.action.handler?() }))
        self.present(alertController, animated: true, completion: nil)
    }

}

// MARK: - UITextFieldDelegate
extension FlickerCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard
            let text = textField.text,
            !text.isEmpty
            else { return true }
        
        viewModel.deleteAllEntries()
        cache.removeAllObjects()
        
        viewModel.getflickrImages(for: text) 
        
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}


// MARK: - UICollectionViewDataSource
extension FlickerCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.searches.value.searchResults?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCell", for: indexPath) as? FlickrPhotoCell
        return cell ?? UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate
extension FlickerCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? FlickrPhotoCell else { return }
        let itemNumber = NSNumber(value: indexPath.item)
        
        if let cachedImage = self.cache.object(forKey: itemNumber) {
            print("Using a cached image for item: \(itemNumber)")
            cell.imageView.image = cachedImage
        } else {
            let photo = self.viewModel.searches.value.searchResults?[indexPath.row]
            utilityQueue.async {
                self.viewModel.loadImage(at: itemNumber, for: photo?.flickrImageURLString)
            }
        }
    }
    
}

// MARK: - Collection View Flow Layout Delegate
extension FlickerCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return sectionInsets.left
    }
}
