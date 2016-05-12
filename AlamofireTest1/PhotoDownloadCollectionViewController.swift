//
//  PhotoDownloadCollectionViewController.swift
//  AlamofireTest1
//
//  Created by alun on 16/5/12.
//  Copyright © 2016年 cascade. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PhotoDownloadCollectionViewController: UICollectionViewController {

    var downloadPhotoURLs: [NSURL]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(PhotoDownloadCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Photomania"
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width, height: 200)
        collectionView?.collectionViewLayout = layout
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        var error: NSError?
        let urls: [AnyObject]?
        
        do {
            urls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: nil, options: [])
        } catch let err as NSError {
            error = err
            urls = nil
        }
        
        guard error == nil else { return }
        downloadPhotoURLs = urls as? [NSURL]
        collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return downloadPhotoURLs?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoDownloadCollectionViewCell
    
        // Configure the cell
        
        let localFileData = NSFileManager.defaultManager().contentsAtPath(downloadPhotoURLs![indexPath.item].path!)
        let image = UIImage(data: localFileData!, scale: UIScreen.mainScreen().scale)
        
        cell.imageView.image = image
    
        return cell
    }

}

class PhotoDownloadCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        imageView.frame = bounds
        imageView.contentMode = .ScaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
}
