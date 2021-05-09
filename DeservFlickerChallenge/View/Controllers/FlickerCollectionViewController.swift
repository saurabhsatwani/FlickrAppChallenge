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
    private var dict = [Int:UIImage]()
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    private var isLoading = false
    private var searchText = ""
    private var dataSourceArray = [Photo]()
    private var pageIndex = 1
    private var imageCache = ImageCache()

    
    var viewModel = FlickrViewModel()
    var loadingView: CollectionReusableView?

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        registerCells()
        bindViewModel()
    }
    
    override func didReceiveMemoryWarning() {
        print("warning recieved")
    }
    
    fileprivate func registerCells() {
        let loadingReusableNib = UINib(nibName: "CollectionReusableView", bundle: nil)
        collectionView.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loadingResusableView")
    }
    
    fileprivate func setupNavigationBar() {
        navigationController?.view.backgroundColor = UIColor.white
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
        
        
        viewModel.retrievedPhotos.bind { [weak self] resultArray in
            self?.dataSourceArray += resultArray
            self?.isLoading = false
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        }
        
        
        viewModel.flickrImage.bind { [weak self] (flickrImage) in
            
            guard let photoObj = flickrImage.photoObject else {return}
            
            guard let data = flickrImage.imageData else {
                return
            }
            
            guard let image = UIImage(data: data),
                  let photoURL = photoObj.flickrImageURL
            else {return}
            
            self?.imageCache.insertImage(image, for: photoURL)
                        
            DispatchQueue.main.async {
                let index = self?.dataSourceArray.firstIndex(where: {$0 === photoObj})
                self?.collectionView.reloadItems(at: [IndexPath(item: index ?? 0, section: 0)])
            }
        }
        
        viewModel.onShowError = { [weak self] alert in
            self?.imageCache.removeAllImages()
            DispatchQueue.main.async {
                self?.presentSingleButtonDialog(alert: alert)
            }
        }
        
        viewModel.onResetView = { [weak self] in
            self?.pageIndex = 1
            self?.dataSourceArray.removeAll()
            self?.imageCache.removeAllImages()
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
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
        
        searchText = text
        viewModel.resetAll()
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
        return dataSourceArray.count
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
        
        
        if indexPath.row == dataSourceArray.count-10 && !self.isLoading {
            self.isLoading = true
            viewModel.getflickrImages(for: searchText, pageIndex: pageIndex+1)
        }
        
        
        guard let cell = cell as? FlickrPhotoCell else { return }
        let photoObj = dataSourceArray[indexPath.item]

        if let imageURL = photoObj.flickrImageURL, let image = imageCache.image(for: imageURL) {
            print("Using a cached image for item: \(photoObj)")
            cell.imageView.image = image
        }
    else {
            utilityQueue.async {
                self.viewModel.loadImage(for: photoObj)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.isLoading {
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: 55)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "loadingResusableView", for: indexPath) as! CollectionReusableView
            loadingView = aFooterView
            loadingView?.backgroundColor = UIColor.clear
            return aFooterView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if dataSourceArray.count > 0 && elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.activityIndicatorView.startAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.activityIndicatorView.stopAnimating()
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
