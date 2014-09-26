//
//  DetailUserViewController.swift
//  Wattpad Life
//
//  Created by Rajul Arora on 2014-09-26.
//  Copyright (c) 2014 HonghaoZ. All rights reserved.
//

import UIKit

class DetailUserViewController: UIViewController {
    
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var avatarName: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var exitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var selectedPeople = People.sharedPeople.people[People.sharedPeople.currentIndex]
        jobTitle.text = selectedPeople.title
        avatarName.text = selectedPeople.name
        avatarImage.setImageWithURL(selectedPeople.avatarURL)
        avatarImage.layer.cornerRadius = avatarImage.frame.size.width/8.0
        avatarImage.clipsToBounds = true
        avatarName.adjustsFontSizeToFitWidth = true
        jobTitle.adjustsFontSizeToFitWidth = true

    }
    
    @IBAction func exitButtonTapped(sender: AnyObject) {
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }
}
