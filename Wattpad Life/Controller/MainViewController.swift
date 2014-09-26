//
//  MainViewController.swift
//  Wattpad Life
//
//  Created by Honghao Zhang on 2014-09-25.
//  Copyright (c) 2014 HonghaoZ. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = mainColor
        collectionView.delegate = self
        collectionView.dataSource = self
        People.sharedPeople.getPeople(nil, failure: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh:", name: "DataUpdated", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:CustomCollectionViewCell =  collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as CustomCollectionViewCell
        cell.configureCell(People.sharedPeople.people[indexPath.row].avatarURL, name: People.sharedPeople.people[indexPath.row].name)
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return People.sharedPeople.people.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(80.0, 100.0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        People.sharedPeople.currentIndex = indexPath.row

        var detailViewController:DetailUserViewController = UIViewController.viewControllerInStoryboard("Main", viewControllerName: "detailView") as DetailUserViewController
        
        var formSheet:MZFormSheetController = MZFormSheetController(viewController: detailViewController)
        formSheet.shouldCenterVertically = true
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.transitionStyle = MZFormSheetTransitionStyle.Bounce
        formSheet.cornerRadius = 8.0;
        formSheet.portraitTopInset = 6.0;
        formSheet.landscapeTopInset = 6.0;
        formSheet.presentedFormSheetSize = CGSizeMake(self.view.frame.size.width-40.0, self.view.frame.size.height/2.0);
        
        var backgroundWindow:MZFormSheetBackgroundWindow = MZFormSheetController.sharedBackgroundWindow()
        backgroundWindow.backgroundBlurEffect = true
        backgroundWindow.blurRadius = 5.0
        backgroundWindow.backgroundColor = UIColor.clearColor()
        
        var appearance:AnyObject = MZFormSheetController.appearance()

        self.mz_presentFormSheetController(formSheet, animated: true, completionHandler:nil)
    }
    
    @IBAction func refresh(sender: AnyObject) {
        collectionView.reloadData()
    }
}


