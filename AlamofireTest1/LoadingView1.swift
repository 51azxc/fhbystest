//
//  LoadingView1.swift
//  AlamofireTest1
//
//  Created by alun on 16/5/18.
//  Copyright © 2016年 cascade. All rights reserved.
//

import UIKit

class LoadingView1: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addLoadingView1()
        beginLoadingAnimation1()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let loadingViewLayer1: CAShapeLayer = CAShapeLayer()
    
    func addLoadingView1() {
        loadingViewLayer1.strokeColor = UIColor.whiteColor().CGColor
        loadingViewLayer1.fillColor = UIColor.clearColor().CGColor
        loadingViewLayer1.lineWidth = 3
        let ovalRadius = min(self.frame.size.width, self.frame.size.height)/2 * 0.8
        loadingViewLayer1.path = UIBezierPath(ovalInRect: CGRect(x: self.frame.size.width/2 - ovalRadius, y: self.frame.size.height/2 - ovalRadius, width: ovalRadius * 2, height: ovalRadius * 2)).CGPath
        loadingViewLayer1.lineCap = kCALineCapRound
        self.layer.addSublayer(loadingViewLayer1)
    }
    
    func beginLoadingAnimation1() {
        let strokeStartAnimate = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimate.fromValue = -1.5
        strokeStartAnimate.toValue = 1
        
        let strokeEndAnimate = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimate.fromValue = 0
        strokeEndAnimate.toValue = 1
        
        let strokeAnimateGroup = CAAnimationGroup()
        strokeAnimateGroup.duration = 1.5
        strokeAnimateGroup.repeatCount = HUGE
        strokeAnimateGroup.animations = [strokeStartAnimate, strokeEndAnimate]
        loadingViewLayer1.addAnimation(strokeAnimateGroup, forKey: nil)
    }

}
