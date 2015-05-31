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
    
    var photo: UIImage? {
        didSet {
            photoImageView?.image = photo
        }
    }
    
    @IBOutlet weak var photoImageView: UIImageView! {
        didSet {
            photoImageView.image = photo
        }
    }
    
}
