//
//  CustomCollectionViewCell.swift
//  Wattpad Life
//
//  Created by Rajul Arora on 2014-09-26.
//  Copyright (c) 2014 HonghaoZ. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var avatarName: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureCell(url:NSURL, name:NSString) {
        avatarImage.setImageWithURL(url)
        avatarImage.layer.cornerRadius = avatarImage.frame.size.width/2.0
        avatarImage.clipsToBounds = true
        avatarImage.layer.borderWidth = 3.0
        avatarImage.layer.borderColor = UIColor.whiteColor().CGColor
        avatarImage.setTranslatesAutoresizingMaskIntoConstraints(false)
        avatarName.setTranslatesAutoresizingMaskIntoConstraints(false)
        avatarName.text = name
        avatarName.adjustsFontSizeToFitWidth = true
    }
    
}
