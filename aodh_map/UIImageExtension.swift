//
//  UIImageExtension.swift
//  aodh_map
//
//  Created by 海崎惇志 on 2018/07/22.
//  Copyright © 2018年 宮川奈々. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
