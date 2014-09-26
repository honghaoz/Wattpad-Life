//
//  MainViewController.swift
//  Wattpad Life
//
//  Created by Honghao Zhang on 2014-09-25.
//  Copyright (c) 2014 HonghaoZ. All rights reserved.
//

import UIKit

let hud:JGProgressHUD = JGProgressHUD()
let searchBar:UISearchBar = UISearchBar()

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = mainColor
        collectionView.delegate = self
        collectionView.dataSource = self
        People.sharedPeople.getPeople(nil, failure: nil)
        
        searchBar.autocorrectionType = UITextAutocorrectionType.No
        searchBar.delegate = self
        searchBar.frame = CGRectMake(0.0,64.0, self.view.frame.size.width, 44)
        searchBar.tintColor = UIColor.whiteColor()
        self.view.addSubview(searchBar)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh:", name: "DataUpdated", object: nil)
        hud.textLabel.text = "Loading"
        hud.showInView(self.view)
    }
    
    override func viewDidAppear(animated: Bool) {
        hud.dismissAfterDelay(0.5)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        hud.dismissAfterDelay(0.5)
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
        return UIEdgeInsetsMake(54.0, 10.0, 10.0, 10.0)
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
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}


