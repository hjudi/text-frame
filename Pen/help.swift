//
//  help.swift
//  Pen
//
//  Created by Hazim Judi on 2016-05-10.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

func hexToColor(hex: String) -> UIColor? {
	
	if let hexIntValue = UInt(hex, radix: 16) {
		
		return UIColor(
			red: CGFloat((hexIntValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((hexIntValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(hexIntValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
	
	return nil
}
