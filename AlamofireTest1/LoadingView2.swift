//
//  LoadingView2.swift
//  AlamofireTest1
//
//  Created by alun on 16/5/18.
//  Copyright © 2016年 cascade. All rights reserved.
//

import UIKit

class LoadingView2: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.bounds = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        replicatorLayer.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        replicatorLayer.backgroundColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(replicatorLayer)
        
        let circle = CALayer()
        circle.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
        circle.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 - 40)
        circle.cornerRadius = 6
        circle.backgroundColor = UIColor.whiteColor().CGColor
        replicatorLayer.addSublayer(circle)
        
        
        
        replicatorLayer.instanceCount = 12
        let angle = CGFloat(2 * M_PI) / CGFloat(12)
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1
        scale.toValue = 0.1
        scale.duration = 1
        scale.repeatCount = HUGE
        circle.addAnimation(scale, forKey: nil)
        
        replicatorLayer.instanceDelay = 1/12
        circle.transform = CATransform3DMakeScale(0.01, 0.01, 0.01)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
