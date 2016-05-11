//
//  PhotoDetailsViewController.swift
//  AlamofireTest1
//
//  Created by alun on 16/5/11.
//  Copyright © 2016年 cascade. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var PluseValueLabel: UILabel!
    @IBOutlet weak var HighestValueLabel: UILabel!
    @IBOutlet weak var ViewsValueLabel: UILabel!
    @IBOutlet weak var CameraValueLabel: UILabel!
    @IBOutlet weak var FocusValueLabel: UILabel!
    @IBOutlet weak var ShutterValueLabel: UILabel!
    @IBOutlet weak var ApertureValueLabel: UILabel!
    @IBOutlet weak var ISOValueLabel: UILabel!
    @IBOutlet weak var CategoryValueLabel: UILabel!
    @IBOutlet weak var TakenValueLabel: UILabel!
    @IBOutlet weak var UploadedValueLabel: UILabel!
    @IBOutlet weak var DescriptionValueLabel: UILabel!
    
    var photoInfo: PhotoInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        PluseValueLabel.text = NSString(format: "%.1f", photoInfo?.pulse ?? 0) as String
        HighestValueLabel.text = NSString(format: "%.1f", photoInfo?.highest ?? 0) as String
        ViewsValueLabel.text = "\(photoInfo?.views ?? 0)"
        CameraValueLabel.text = photoInfo?.camera ?? " "
        FocusValueLabel.text = photoInfo?.focalLength ?? " "
        ShutterValueLabel.text = photoInfo?.shutterSpeed ?? " "
        ApertureValueLabel.text = photoInfo?.aperture ?? " "
        ISOValueLabel.text = photoInfo?.iso ?? " "
        CategoryValueLabel.text = photoInfo?.category?.description ?? " "
        TakenValueLabel.text = photoInfo?.taken ?? " "
        UploadedValueLabel.text = photoInfo?.uploaded ?? " "
        DescriptionValueLabel.text = photoInfo?.desc ?? " "
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToViewController(sender: UIStoryboardSegue) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
