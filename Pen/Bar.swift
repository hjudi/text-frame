//
//  Bar.swift
//  Pen
//
//  Created by Hazim Judi on 2016-05-31.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit

class Bar: UIView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.backgroundColor = UIColor(white: 0.86, alpha: 0.9)
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func revert() {
		
		UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut.union(.AllowUserInteraction), animations: {
			
			self.layer.transform = CATransform3DMakeScale(1, 1, 1)
			
			}, completion: nil)
	}
	
	var firstTouchPoint : CGPoint?
	var currentTouchPoint : CGPoint?
	var timer : NSTimer?
	
	func iterate() {
		
		if self.currentTouchPoint == nil || self.firstTouchPoint == nil { return }
		
		self.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(iterate), userInfo: nil, repeats: false)
		
		let targetY = appDelegate.main.textView.contentOffset.y+(((self.currentTouchPoint!.y / self.firstTouchPoint!.y)-1)*80)
		
		if targetY < 0 || targetY > (appDelegate.main.textView.contentSize.height-appDelegate.window!.frame.height-10) { return }
		
		UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: {
			
			appDelegate.main.textView.setContentOffset(CGPoint(x: 0, y: targetY), animated: false)
			
			}, completion: nil)
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesBegan(touches, withEvent: event)
		
		self.firstTouchPoint = touches.first?.locationInView(self)
		self.currentTouchPoint = self.firstTouchPoint
		
		UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut.union(.AllowUserInteraction), animations: {
			
			self.layer.transform = CATransform3DMakeScale(2, 1, 1)
			
			}, completion: nil)
		
		self.iterate()
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesMoved(touches, withEvent: event)
		
		self.currentTouchPoint = touches.reverse().first?.locationInView(self)
	}
	
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		super.touchesCancelled(touches, withEvent: event)
		
		self.revert()
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesEnded(touches, withEvent: event)
		
		self.timer?.invalidate()
		self.revert()
	}
}
