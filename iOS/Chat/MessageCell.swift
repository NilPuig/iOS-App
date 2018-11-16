//
//  MessageCell.swift
//  Clerkie
//
//  Created by Nil Puig on 16/11/2018.
//  Copyright © 2018 Nil Puig. All rights reserved.
//


import Foundation
import UIKit


class MessageCell: UITableViewCell {


  let messageImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 10
    imageView.layer.masksToBounds = true

    return imageView
  }()

  let messageTextView: UITextView = {
    let textView = UITextView()
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.backgroundColor = UIColor.clear
    textView.font = UIFont(name: "Helvetica", size: 15)
    textView.isEditable = false
    textView.isScrollEnabled = false
    return textView
  }()

  let messageView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 15
    view.layer.masksToBounds = true
    return view
  }()

  let timeLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = true
    label.textColor = UIColor.white
    label.text = ""
    label.textAlignment = .right
    return label
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    addSubview(messageView)
    addSubview(messageTextView)
    addSubview(messageImageView)
    addSubview(timeLabel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) not implemented")
  }

}
