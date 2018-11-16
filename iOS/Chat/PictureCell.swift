//
//  PictureCell.swift
//  Clerkie
//
//  Created by Nil Puig on 16/11/2018.
//  Copyright © 2018 Nil Puig. All rights reserved.
//

import Foundation
import UIKit

class PictureCell: UICollectionViewCell {
    

    var pictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(pictureImageView)
        pictureImageView.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        pictureImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true
        pictureImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 3).isActive = true
        pictureImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -3).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    
}
