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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)

    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)

    }
    
    @IBAction func exitButtonTapped(sender: AnyObject) {
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }
}
