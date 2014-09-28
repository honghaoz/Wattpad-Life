//
//  RAActivityIndicatorView.swift
//  Wattpad Life
//
//  Created by Rajul Arora on 2014-09-27.
//  Copyright (c) 2014 HonghaoZ. All rights reserved.
//

import UIKit

class RAActivityIndicatorView: UIActivityIndicatorView {
    
    private var activityIndicatorImage:UIImageView = UIImageView()
    
    func setActivityIndicatorImage(image:UIImageView){
        activityIndicatorImage = image
    }
    
    override func drawRect(rect: CGRect)
    {
        
    }

}
