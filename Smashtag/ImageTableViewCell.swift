//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Remus Lazar on 31.05.15.
//  Copyright (c) 2015 Remus Lazar. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    // MARK: - Public API
    
    var photoURL: NSURL? {
        didSet {
            spinner.startAnimating()
            if let url = photoURL {
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
                    let data = NSData(contentsOfURL: url)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.spinner.stopAnimating()
                        if data != nil && url == self.photoURL {
                            self.photo = UIImage(data: data!)
                        }
                    }
                }
            }
        }
    }

    private var photo: UIImage? {
        didSet {
            photoImageView?.image = photo
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak private var photoImageView: UIImageView! {
        didSet {
            if photo != nil {
                photoImageView?.image = photo
            }
        }
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
}
