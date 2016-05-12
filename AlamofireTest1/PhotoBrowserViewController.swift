//
//  PhotoBrowserViewController.swift
//  AlamofireTest1
//
//  Created by alun on 16/5/9.
//  Copyright © 2016年 cascade. All rights reserved.
//

import UIKit
import Alamofire

class PhotoBrowserViewController: UIViewController, UIScrollViewDelegate {

    var photoId: Int = 0
    var photoInfo: PhotoInfo?
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    let imageView = UIImageView()
    //let scrollView = UIScrollView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var singleTap: UITapGestureRecognizer!
    @IBOutlet var doubleTap: UITapGestureRecognizer!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.spinner.center = CGPointMake(self.view.center.x, self.view.center.y - self.view.bounds.origin.y / 2.0)
        self.spinner.hidesWhenStopped = true
        self.spinner.startAnimating()
        self.scrollView.addSubview(self.spinner)
        
//        self.automaticallyAdjustsScrollViewInsets = false
        
//        scrollView.frame = view.bounds
//        scrollView.delegate = self
//        scrollView.minimumZoomScale = 1.0
//        scrollView.maximumZoomScale = 3.0
//        scrollView.zoomScale = 1.0
//        scrollView.backgroundColor = UIColor.blackColor()
//        view.addSubview(scrollView)
        
        imageView.contentMode = .ScaleAspectFill
        scrollView.addSubview(imageView)
        
        singleTap.requireGestureRecognizerToFail(doubleTap)
        
//        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoBrowserViewController.handleDoubleTap(_:)))
//        doubleTapRecognizer.numberOfTapsRequired = 2
//        doubleTapRecognizer.numberOfTouchesRequired = 1
//        scrollView.addGestureRecognizer(doubleTapRecognizer)
//        
//        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoBrowserViewController.handleSingleTap))
//        singleTapRecognizer.numberOfTapsRequired = 1
//        singleTapRecognizer.numberOfTouchesRequired = 1
//        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
//        scrollView.addGestureRecognizer(singleTapRecognizer)
        
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
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ context in
            
            }, completion: { finished in
                
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetails" {
            let toViewController = segue.destinationViewController as! PhotoDetailsViewController
            toViewController.photoInfo = self.photoInfo
        } else if segue.identifier == "showComments" {
            let toViewController = segue.destinationViewController as! PhotoCommentsViewController
            toViewController.photoId = self.photoId
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func handleSingleTap() {
        let hidden = navigationController?.navigationBar.hidden ?? false
        navigationController?.setNavigationBarHidden(!hidden, animated: true)
        navigationController?.setToolbarHidden(!hidden, animated: true)
        //UIApplication.sharedApplication().setStatusBarHidden(!hidden, withAnimation: .Slide)
    }
    
    @IBAction func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(self.imageView)
        self.zoomInZoomOut(pointInView)
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
        items.append(barButtonItemWithImageNamed("hamburger", title: nil, action: #selector(PhotoBrowserViewController.showDetails)))
        
        if photoInfo?.commentsCount > 0 {
            items.append(barButtonItemWithImageNamed("bubble", title: "\(photoInfo?.commentsCount ?? 0)", action: #selector(PhotoBrowserViewController.showComments)))
        }
        
        items.append(flexibleSpace)
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(PhotoBrowserViewController.showActions)))
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
    
    func showDetails() {
        performSegueWithIdentifier("showDetails", sender: nil)
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
        Alamofire.request(modelFor500px.Router.PhotoInfo(photoInfo!.id, .XLarge)).validate().responseJSON() {
            response in
            guard response.result.error == nil else { return }
            let dict = response.result.value as! NSDictionary
            let imageURL = dict.valueForKeyPath("photo.image_url") as! String
            let destination: (NSURL, NSHTTPURLResponse) -> (NSURL) = { temporaryURL, response in
                let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let pathComponent = response.suggestedFilename
                
                return directoryURL.URLByAppendingPathComponent("\(self.photoInfo!.id).\(pathComponent)")
                
            }
            Alamofire.download(.GET, imageURL, destination: destination)
                .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.progressView.hidden = false
                        self.progressView.setProgress(Float(totalBytesRead) / Float(totalBytesExpectedToRead), animated: true)
                        
                        if totalBytesRead == totalBytesExpectedToRead {
                            self.progressView.hidden = true
                        }
                    }
                
                }.response { _, _, _, error in
                    //self.progressView.progress = 0.0
                    self.progressView.hidden = true
            }
        }
    }
    
    func loadPhoto() {
        Alamofire.request(modelFor500px.Router.PhotoInfo(self.photoId, .Large))
            .validate()
            .responseObject() { (response: Response<PhotoInfo, NSError>) in
                
                guard response.result.error == nil else { return }
                
                self.photoInfo = response.result.value
                dispatch_async(dispatch_get_main_queue()) {
                    self.addBottomBar()
                    self.title = self.photoInfo!.name
                }
                
                Alamofire.request(.GET, self.photoInfo!.url)
                    .responseImage() { response in
                      
                        guard response.result.error == nil && response.result.value != nil else { return }
                        self.imageView.image = response.result.value
                        self.imageView.frame = self.centerFrameFromImage(response.result.value)
                        self.centerScrollViewContents()
                        self.spinner.stopAnimating()
                }
        }
    }
}
