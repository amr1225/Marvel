//
//  UIImageExtension.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/5/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import UIKit

extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) -> UIImage {
        let rect = CGRect.init(x:0.0,
                               y:0.0,
                               width:size.width,
                               height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
