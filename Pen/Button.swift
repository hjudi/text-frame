//
//  Button.swift
//  Pen
//
//  Created by Hazim Judi on 2016-05-09.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit

class Button: UIView {
	
	var ball : UIView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.ball = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 70, height: 70)))
		self.ball.backgroundColor = UIColor(white: 0.96, alpha: 0.95)
		self.ball.layer.cornerRadius = self.ball.frame.width/2
		self.ball.layer.masksToBounds = false
		self.ball.layer.shadowRadius = 4
		self.ball.layer.shadowColor = UIColor(white: 0, alpha: 1).CGColor
		self.ball.layer.shadowOffset = CGSize(width: 0,height: 2)
		self.ball.layer.shadowOpacity = 0.3
		self.addSubview(self.ball)
		
		//This sublayer I add is because for some odd reason, you can't have a single CALayer have a corner radius, mask to bounds, AND have a shadow. But we need clipping for the layer that has a border, as seen below, so we delegate the shadow the above layer which has no clipping. Fun stuff! 
		
		let sl = CALayer()
		sl.frame = CGRect(origin: CGPointZero, size: self.ball.frame.size)
		sl.backgroundColor = UIColor.clearColor().CGColor
		
		sl.cornerRadius = self.ball.frame.width/2
		sl.masksToBounds = true
		sl.borderColor = UIColor.whiteColor().CGColor
		sl.borderWidth = 4
		
		self.ball.layer.addSublayer(sl)
		
	}
	
	func revert() {
		
		UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: {
			
			self.ball.layer.transform = CATransform3DMakeScale(1, 1, 1)
			
			}, completion: nil)
	}
	
	//Very primitive functions we override to know when a finger touches, moves, and releases from this class's frame.
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesBegan(touches, withEvent: event)
		
		UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: {
			
			self.ball.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.3)
			
			}, completion: nil)
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesMoved(touches, withEvent: event)
		
		
	}
	
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		super.touchesCancelled(touches, withEvent: event)
		
		self.revert()
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesEnded(touches, withEvent: event)
		
		self.revert()
		appDelegate.main.evaluateIfShouldSelect()
	}
	
	
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}
