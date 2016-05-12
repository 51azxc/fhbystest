//
//  PhotoBrowserCollectionViewController.swift
//  AlamofireTest1
//
//  Created by alun on 16/5/6.
//  Copyright © 2016年 cascade. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "Cell"

class PhotoBrowserCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var photos = NSMutableOrderedSet()
    
    let footerReuseidentifier = "FooterCell"
    let refreshControl = UIRefreshControl()
    let imageCache = NSCache()
    
    var populatingPhotos = false
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        
        setUpView()
        populatePhotos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoBrowserCollectionViewCell
    
        // Configure the cell
        
        let imageURL = (photos[indexPath.row] as! PhotoInfo).url
        
        if cell.request?.request?.URLString != imageURL {
            cell.request?.cancel()
        }
        
        if let image = self.imageCache.objectForKey(imageURL) as? UIImage {
            cell.imageView.image = image
        } else {
            cell.imageView.image = nil
            
            cell.request = Alamofire.request(.GET, imageURL).validate(contentType:["image/*"]).responseImage() {
                response in
                guard response.result.error == nil && response.result.value != nil else { return }
                guard response.request?.URLString == cell.request?.request?.URLString else { return }
                self.imageCache.setObject(response.result.value!, forKey: (response.request?.URLString)!)
                cell.imageView.image = response.result.value
            }
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: footerReuseidentifier, forIndexPath: indexPath) as UICollectionReusableView
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowPhoto", sender: (self.photos.objectAtIndex(indexPath.item) as! PhotoInfo).id)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + self.view.frame.size.height > scrollView.contentSize.height * 0.8 {
            populatePhotos()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPhoto" {
            (segue.destinationViewController as! PhotoBrowserViewController).photoId = sender!.integerValue
            (segue.destinationViewController as! PhotoBrowserViewController).hidesBottomBarWhenPushed = true
        }
    }
    
    func setUpView() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "Photomania"
        
        let layout = UICollectionViewFlowLayout()
        let width = (self.view.bounds.size.width / 3) - 1
        layout.itemSize = CGSizeMake(width, width)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        layout.footerReferenceSize = CGSize(width: self.collectionView!.bounds.size.width, height: 100)
        collectionView?.collectionViewLayout = layout
        
        // Register cell classes
        self.collectionView!.registerClass(PhotoBrowserCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.registerClass(PhotoBrowserCollectionViewLoadingCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerReuseidentifier)
        
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: #selector(PhotoBrowserCollectionViewController.handleRefresh), forControlEvents: .ValueChanged)
        collectionView!.addSubview(refreshControl)
    }
    
    func populatePhotos() {
        if self.populatingPhotos { return }
        
        self.populatingPhotos = true
        
        Alamofire.request(modelFor500px.Router.PopularPhotos(self.currentPage))
            .responseJSON { response in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    if let JSON = response.result.value {
                        let photoInfos = (JSON.valueForKey("photos") as! [NSDictionary]).filter({ image in
                            (image["nsfw"] as! Bool) == false
                        }).map { photo in
                            PhotoInfo(id: photo["id"] as! Int, url: photo["image_url"] as! String)
                        }
                        let lastItem = self.photos.count
                        self.photos.addObjectsFromArray(photoInfos)
                        let indexPaths = (lastItem..<self.photos.count).map { i in
                            NSIndexPath(forItem: i, inSection: 0)
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                        }
                        self.currentPage += 1
                    }
                }
                self.populatingPhotos = false
        }
    }
    
    func handleRefresh() {
        refreshControl.beginRefreshing()
        self.photos.removeAllObjects()
        self.currentPage = 1
        self.collectionView?.reloadData()
        refreshControl.endRefreshing()
        populatePhotos()
    }

}

class PhotoBrowserCollectionViewCell: UICollectionViewCell {
    var request: Alamofire.Request?
    let imageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        imageView.frame = self.bounds
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
}

class PhotoBrowserCollectionViewLoadingCell: UICollectionReusableView {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        spinner.startAnimating()
        spinner.center = self.center
        self.addSubview(spinner)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
}
