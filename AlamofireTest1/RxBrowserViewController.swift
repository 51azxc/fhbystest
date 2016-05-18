//
//  RxBrowserViewController.swift
//  AlamofireTest1
//
//  Created by alun on 16/5/16.
//  Copyright © 2016年 cascade. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa

class RxBrowserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let reuseIdentifier = "photoCell"
    let footerReuseidentifier = "photoFooterCell"
    let refreshControl = UIRefreshControl()
    let imageCache = NSCache()
    let vm = PhotoBrowserViewModel()
    let disposeBag = DisposeBag()
    
    var data = Variable<[PhotoInfo]>([])
    var populatingPhotos = false
    var currentPage = 1
    var refreshing = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpView()
        populatePhotos()
        
        self.data.asObservable().bindTo(collectionView.rx_itemsWithCellIdentifier(reuseIdentifier, cellType: PhotoBrowserCollectionViewCell.self)) { (index, element, cell) in
            let imageURL = element.url
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
        }.addDisposableTo(disposeBag)
        
        collectionView.rx_contentOffset
            .map{ $0.y }
            .filter{
                $0 + self.view.frame.size.height > self.collectionView.contentSize.height * 0.8
            }
            .distinctUntilChanged()
            .subscribeNext { [unowned self] _ in
                self.refreshing = false
                self.populatePhotos()
        }.addDisposableTo(disposeBag)
        
        collectionView.rx_itemSelected.subscribeNext { [weak self] indexPath in
            self!.performSegueWithIdentifier("showPhoto", sender: self!.data.value[indexPath.item].id)
        }.addDisposableTo(disposeBag)
        
        refreshControl.rx_controlEvent(.ValueChanged)
            .subscribeNext{ [unowned self] _ in
                self.refreshing = true
                self.currentPage = 1
                self.populatePhotos()
            }.addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPhoto" {
            let toViewController = segue.destinationViewController as! RxPhotoViewController
            toViewController.photoId = sender!.integerValue
            toViewController.hidesBottomBarWhenPushed = true
        }
    }
    
    func setUpView() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "RxPhotomania"
        
        let layout = UICollectionViewFlowLayout()
        let width = (view.bounds.size.width / 3)
        layout.itemSize = CGSizeMake(width, width)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        layout.footerReferenceSize = CGSize(width: self.collectionView!.bounds.size.width, height: 100)
        collectionView?.collectionViewLayout = layout
        
        // Register cell classes
        self.collectionView!.registerClass(PhotoBrowserCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        refreshControl.tintColor = UIColor.whiteColor()
        collectionView!.addSubview(refreshControl)
    }
    
    func populatePhotos() {
        if self.populatingPhotos { return }
        self.populatingPhotos = true
        vm.getPhotos(self.currentPage)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [unowned self] photoInfos in
                    if self.refreshing {
                        self.refreshControl.beginRefreshing()
                        self.data.value = (photoInfos as! [PhotoInfo])
                    } else {
                        for photoInfo in (photoInfos as! [AnyObject]) {
                            self.data.value.append(photoInfo as! PhotoInfo)
                        }
                    }
                    self.collectionView.reloadData()
                    self.currentPage += 1
                    self.populatingPhotos = false
                    
                    if self.refreshing {
                        self.refreshControl.endRefreshing()
                    }
                    
                },
                onError:  { error in
                    let err = error as NSError
                    print(err)
                    //self.postError("\(err.code)", message: err.description)
                    self.populatingPhotos = false
            })
            .addDisposableTo(disposeBag)
    }

}
