_Introduction_
Swift Project written in MVVM Architecture which fetches images from Flickr API.

_Installation_
Create an account or grab a new API key from Flickr API
Replace the api key in AppService class, set your app key against appKey variable.
Build and run!

_Dependecies_
To minimize code and highlight the MVVM structure, no third party dependencies were used.

_Project Overview

**Network**
AppService.swift - Handles the GET Request to Fetch Image object from FlickrAPI.

**Model**
Photo.Swift- Core model object which will be used for parsing FlickrAPI data.
FlickerSearchResults.swift - Helper models used for encapsulating data used by FlickrViewModel.

**ViewModel**
FlickrViewModel.swift - Takes in text inpur from view controller and formats the image data to be displayed in the views. This class will be responsible for handling all business logic.

**View**
FlickerCollectionViewController.swift: View class which will pass inputs to view model for processing data, will update the view components through view model bindings.
FlickrPhotoCell.swift: Custom collection view cell to display the images downloaded from Flickr.
