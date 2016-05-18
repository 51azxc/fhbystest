//
//  RxPhotoViewController.swift
//  AlamofireTest1
//
//  Created by alun on 16/5/17.
//  Copyright © 2016年 cascade. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa

class RxPhotoViewController: UIViewController, UIScrollViewDelegate {

    var photoId: Int = 0
    var photoInfo: PhotoInfo?
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    let imageView = UIImageView()
    let scrollView = UIScrollView()
    let disposeBag = DisposeBag()
    let vm = PhotoBrowserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.spinner.center = CGPointMake(self.view.center.x, self.view.center.y - self.view.bounds.origin.y / 2.0)
        self.spinner.hidesWhenStopped = true
        self.spinner.startAnimating()
        self.scrollView.addSubview(self.spinner)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 1.0
        scrollView.backgroundColor = UIColor.blackColor()
        view.addSubview(scrollView)

        imageView.contentMode = .ScaleAspectFill
        scrollView.addSubview(imageView)
        
        let doubleTapRecognizer = UITapGestureRecognizer()
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        
        doubleTapRecognizer.rx_event.subscribeNext { [unowned self]recognizer in
            let pointInView = recognizer.locationInView(self.imageView)
            self.zoomInZoomOut(pointInView)
        }.addDisposableTo(disposeBag)
        
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        let singleTapRecognizer = UITapGestureRecognizer()
        singleTapRecognizer.rx_event.subscribeNext { [unowned self]recognizer in
            let hidden = self.navigationController?.navigationBar.hidden ?? false
            self.navigationController?.setNavigationBarHidden(!hidden, animated: true)
            self.navigationController?.setToolbarHidden(!hidden, animated: true)
        }.addDisposableTo(disposeBag)
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.numberOfTouchesRequired = 1
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        scrollView.addGestureRecognizer(singleTapRecognizer)
        
        loadPhoto()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.photoInfo != nil {
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showComments" {
            let toViewController = segue.destinationViewController as! RxPhotoCommentsViewController
            toViewController.photoId = self.photoId
        }
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.centerScrollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    

    func centerScrollViewContents() {
        let boundsSize = scrollView.frame
        var contentsFrame = self.imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - scrollView.scrollIndicatorInsets.top - scrollView.scrollIndicatorInsets.bottom - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        self.imageView.frame = contentsFrame
    }
    
    func centerFrameFromImage(image: UIImage?) -> CGRect {
        if image == nil {
            return CGRectZero
        }
        
        let scaleFactor = scrollView.frame.size.width / image!.size.width
        let newHeight = image!.size.height * scaleFactor
        
        var newImageSize = CGSize(width: scrollView.frame.size.width, height: newHeight)
        
        newImageSize.height = min(scrollView.frame.size.height, newImageSize.height)
        
        let centerFrame = CGRect(x: 0.0, y: scrollView.frame.size.height/2 - newImageSize.height/2, width: newImageSize.width, height: newImageSize.height)
        
        return centerFrame
    }
    
    func zoomInZoomOut(point: CGPoint!) {
        let newZoomScale = self.scrollView.zoomScale > (self.scrollView.maximumZoomScale/2) ? self.scrollView.minimumZoomScale : self.scrollView.maximumZoomScale
        
        let scrollViewSize = self.scrollView.bounds.size
        
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let x = point.x - (width / 2.0)
        let y = point.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: x, y: y, width: width, height: height)
        
        self.scrollView.zoomToRect(rectToZoom, animated: true)
    }
    
    func addBottomBar() {
        var items = [UIBarButtonItem]()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        items.append(barButtonItemWithImageNamed("hamburger", title: nil, action: nil))
        
        if photoInfo?.commentsCount > 0 {
            items.append(barButtonItemWithImageNamed("bubble", title: "\(photoInfo?.commentsCount ?? 0)", action: #selector(RxPhotoViewController.showComments)))
        }
        
        items.append(flexibleSpace)
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(RxPhotoViewController.showActions)))
        items.append(flexibleSpace)
        
        items.append(barButtonItemWithImageNamed("like", title: "\(photoInfo?.votesCount ?? 0)"))
        items.append(barButtonItemWithImageNamed("heart", title: "\(photoInfo?.favoritesCount ?? 0)"))
        
        self.setToolbarItems(items, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func barButtonItemWithImageNamed(imageName: String?, title: String?, action: Selector? = nil) -> UIBarButtonItem {
        let button = UIButton(type: .Custom) as UIButton
        
        if imageName != nil {
            button.setImage(UIImage(named: imageName!)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        
        if title != nil {
            button.setTitle(title, forState: .Normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
            
            let font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
            button.titleLabel?.font = font
        }
        
        let size = button.sizeThatFits(CGSize(width: 90.0, height: 30.0))
        button.frame.size = CGSize(width: min(size.width + 10.0, 60), height: size.height)
        
        if action != nil {
            button.addTarget(self, action: action!, forControlEvents: .TouchUpInside)
        }
        
        let barButton = UIBarButtonItem(customView: button)
        
        return barButton
    }
    
    func showComments() {
        performSegueWithIdentifier("showComments", sender: nil)
    }
    
    func showActions() {
        let actionSheet = UIAlertController.init(title: "Download", message: "Download Photo", preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction.init(title: "Confirm", style: .Destructive, handler: { action in
            self.downloadPhoto()
        }))
        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func downloadPhoto() {
        vm.getPhotoUrl(photoInfo!.id).subscribeNext { [unowned self](imageURL, destination) in
            let progressIndicatorView = UIProgressView(frame: CGRect(x: 0.0, y: 66, width: self.view.bounds.width, height: 10.0))
            self.view.addSubview(progressIndicatorView)
            
            Alamofire.download(.GET, imageURL, destination: destination)
                .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let progress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
                        progressIndicatorView.setProgress(progress, animated: true)
                        
                        if totalBytesRead == totalBytesExpectedToRead {
                            progressIndicatorView.removeFromSuperview()
                        }
                    }
                    
                }.response { _, _, _, error in
                    progressIndicatorView.removeFromSuperview()
            }
            
        }.addDisposableTo(disposeBag)
    }
    
    func loadPhoto() {
        let photoSubject = PublishSubject<String>()
        vm.getPhoto(self.photoId, imageSize: .Large)
            .observeOn(SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .map { object in
                object as! PhotoInfo
            }
            .observeOn(MainScheduler.instance)
            .subscribeNext { [unowned self]photoInfo in
                self.photoInfo = photoInfo
                self.addBottomBar()
                self.title = self.photoInfo!.name
                photoSubject.on(.Next(photoInfo.url))
        }.addDisposableTo(disposeBag)
        
        photoSubject.flatMap { [unowned self]url in
            self.vm.getImage(url)
            }.map { object in
                object as! UIImage
            }.subscribeNext { [unowned self]image in
                self.imageView.image = image
                self.imageView.frame = self.centerFrameFromImage(image)
                self.centerScrollViewContents()
                self.spinner.stopAnimating()
        }.addDisposableTo(disposeBag)
    }
}
