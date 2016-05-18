//
//  PhotoCommentsViewController.swift
//  AlamofireTest1
//
//  Created by alun on 16/5/12.
//  Copyright © 2016年 cascade. All rights reserved.
//

import UIKit
import Alamofire

class PhotoCommentsViewController: UITableViewController {
    
    var photoId = 0
    var comments: [Comment]?
    var loadingView: LoadingView2!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        loadingView = LoadingView2(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        loadingView.center = CGPointMake(self.view.center.x, self.view.center.y - self.view.bounds.origin.y / 2.0)
        view.addSubview(loadingView)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        title = "Comments"
        
        Alamofire.request(modelFor500px.Router.Comments(photoId, 1)).validate().responseCollection() {
            (response: Response<[Comment], NSError>) in
            
            guard response.result.error == nil else { return }
            self.comments = response.result.value
            self.tableView.reloadData()
            self.loadingView.removeFromSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! PhotoCommentTableViewCell
        
        cell.username.text = comments![indexPath.row].userFullname
        cell.comment.text = comments![indexPath.row].commentBody
        cell.avatar.image = nil
        
        let imageURL = comments![indexPath.row].userPictureURL
        Alamofire.request(.GET, imageURL).validate().responseImage() { response in
            guard response.result.error == nil && response.result.value != nil else { return }
            if response.request?.URLString == imageURL {
                cell.avatar.image = response.result.value
            }
        }

        return cell
    }

}

class PhotoCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let path = UIBezierPath.init(roundedRect: avatar.frame, cornerRadius: 10)
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = path.CGPath
//        avatar.layer.mask = maskLayer
    }
}
