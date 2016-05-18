//
//  RxPhotoCommentsViewController.swift
//  AlamofireTest1
//
//  Created by alun on 16/5/18.
//  Copyright © 2016年 cascade. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa

class RxPhotoCommentsViewController: UIViewController {

    let disposeBag = DisposeBag()
    let vm = PhotoBrowserViewModel()
    var photoId = 0
    var comments: [Comment]?
    var loadingView: LoadingView2!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadingView = LoadingView2(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        loadingView.center = CGPointMake(self.view.center.x, self.view.center.y - self.view.bounds.origin.y / 2.0)
        view.addSubview(loadingView)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Comments"
        
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        vm.getComments(photoId).bindTo(tableView.rx_itemsWithCellIdentifier("commentCell", cellType: PhotoCommentTableViewCell.self)) { (row, element, cell) in
            
            cell.username.text = element.userFullname
            cell.comment.text = element.commentBody
            cell.avatar.image = nil
            
            let imageURL = element.userPictureURL
            Alamofire.request(.GET, imageURL).validate().responseImage() { response in
                guard response.result.error == nil && response.result.value != nil else { return }
                if response.request?.URLString == imageURL {
                    cell.avatar.image = response.result.value
                }
            }
            
            if self.loadingView.hidden == false {
                self.loadingView.removeFromSuperview()
            }
        }.addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
