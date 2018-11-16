//
//  UIView+Shadow
//  Clerkie
//
//  Created by Nil Puig on 16/11/2018.
//  Copyright © 2018 Nil Puig. All rights reserved.
//

import UIKit


extension UIView {

  func dropShadow() {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.3
    layer.shadowOffset = CGSize(width: 0, height: 2)
    layer.shadowRadius = 3
  }

  func dropLongShadow() {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.35
    layer.shadowOffset = CGSize(width: 0, height: 3)
    layer.shadowRadius = 3
  }
}


