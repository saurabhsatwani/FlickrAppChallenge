//
//  CollectionReusableView.swift
//  DeservFlickerChallenge
//
//  Created by Saurabh Satwani on 5/9/21.
//  Copyright © 2021 personal. All rights reserved.
//

import UIKit

class CollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicatorView.stopAnimating()
        // Initialization code
    }
    
}
