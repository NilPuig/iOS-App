//
//  ChatViewController.swift
//  Clerkie
//
//  Created by Nil Puig on 16/11/2018.
//  Copyright © 2018 Nil Puig. All rights reserved.
//

import UIKit
import FirebaseAuth
import AVKit
import AVFoundation

class ChatViewController: UITableViewController, UITextViewDelegate, SelectedImageDelegate {

  fileprivate let cellIdentifier = "cellIdentifier"
  fileprivate let userName = "User"

  private struct Message {
    var isIncoming: Bool?
    var sender: String?
    var content: String?
    var type: MessageType?
    var thumbnail: UIImage?
    var localURL: URL?
    var duration: Float?
  }

  private var conversations = [Message]()

  enum MessageType: Int {
    case text, photo, video
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    welcomeUser()

    setupViews()

    setupNav()

    tableView.register(MessageCell.self, forCellReuseIdentifier: cellIdentifier)
    tableView.separatorStyle = .none
    tableView.keyboardDismissMode = .onDrag
    tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 60, right: 0)


    // Adding Keyboard observers
    self.hideKeyboardOnTap()
    let notifier = NotificationCenter.default
    notifier.addObserver(self,
                         selector: #selector(handleKeyboardNotifications),
                         name: UIWindow.keyboardWillShowNotification,
                         object: nil)
    notifier.addObserver(self,
                         selector: #selector(handleKeyboardNotifications),
                         name: UIWindow.keyboardWillHideNotification,
                         object: nil)
  }


  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)

    if(messageContainerView.isHidden) {
      messageContainerView.alpha = 0
      galleryContainer.alpha = 0
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {

        self.messageContainerView.isHidden = false
        self.galleryContainer.isHidden = false

        self.messageContainerView.alpha = 1
        self.galleryContainer.alpha = 1

      }, completion: nil)
    }
  }


  func setupNav() {
    self.navigationController?.navigationBar.barTintColor = UIColor.mainMedium
    self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
    self.navigationController?.navigationBar.layer.shadowOpacity = 0.2
    self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 3)
    self.navigationController?.navigationBar.layer.shadowRadius = 1

    let logoutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(onLogoutPressed))
    logoutButton.tintColor = UIColor.white
    self.navigationItem.leftBarButtonItem  = logoutButton

    let chartButton = UIBarButtonItem(title: "Analytics", style: .plain, target: self, action: #selector(handleDataAnalyticsTapped))
    chartButton.tintColor = UIColor.white
    self.navigationItem.rightBarButtonItem = chartButton

    arrangeNavTitleViews()
  }



  var baseView: UIView = {
    let baseView = UIView()
    baseView.translatesAutoresizingMaskIntoConstraints = false
    return baseView
  }()

  private func arrangeNavTitleViews() {
    baseView.widthAnchor.constraint(equalToConstant: 60).isActive = true

    navigationItem.titleView = baseView
  }


  func imageUploaded(selectedImage: UIImage) {
    let mediaMessage: Message = Message(isIncoming: false, sender: userName, content: "", type: .photo, thumbnail: selectedImage, localURL: nil, duration: nil)

    addMessageToChat(newMessage: mediaMessage)
    getBotResponse(userMessage: mediaMessage)
  }

  func videoUploaded(thumbnail: UIImage, duration: Float, localURL: URL) {
    let mediaMessage: Message = Message(isIncoming: false, sender: userName, content: "", type: .video, thumbnail: thumbnail, localURL: localURL, duration: duration)

    addMessageToChat(newMessage: mediaMessage)
    getBotResponse(userMessage: mediaMessage)
  }


  // MARK: TableView

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return conversations.count
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.messageBoxTextView.endEditing(true)
    let index = indexPath.row

    if(conversations[index].type == MessageType.video) {
      if let videoURL = conversations[index].localURL {
        let player = AVPlayer(url: videoURL)
        let vc = AVPlayerViewController()
        vc.player = player

        present(vc, animated: true) {
          vc.player?.play()
        }
      }
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageCell
    cell.backgroundColor = UIColor.white
    cell.selectionStyle = .none

    let frameWidth = view.frame.width

    if(conversations[indexPath.row].type == .text) {
      cell.messageImageView.isHidden = true
      cell.messageTextView.isHidden = false
      cell.messageView.isHidden = false
      cell.timeLabel.isHidden = true

      cell.messageTextView.text = conversations[indexPath.row].content


      if let messageText = conversations[indexPath.row].content {
        let size = CGSize(width: 250.0, height: .infinity)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedSize = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)

        if(conversations[indexPath.row].isIncoming)! {
          // Incoming message
          cell.messageView.frame = CGRect(x: 8, y: 5, width: estimatedSize.width + 8 + 16, height: estimatedSize.height + 25)
          cell.messageView.backgroundColor = UIColor(red:0.91, green:0.91, blue:0.91, alpha:1.0)
          cell.messageTextView.frame = CGRect(x: 16, y: 8, width: estimatedSize.width + 16 + 8 - 2, height: estimatedSize.height + 20)
          cell.messageTextView.textColor = UIColor.black
        }
        else {
          // Outgoing message
          cell.messageView.frame = CGRect(x: frameWidth - estimatedSize.width - 8 - 16 - 8, y: 5, width: estimatedSize.width + 8 + 16, height: estimatedSize.height + 25)
          cell.messageView.backgroundColor = UIColor.main
          cell.messageTextView.frame = CGRect(x: frameWidth - estimatedSize.width - 16 - 8 - 2, y: 8, width: estimatedSize.width + 16 + 8, height: estimatedSize.height + 20)
          cell.messageTextView.textColor = UIColor.white
        }
      }
    }


    else {
      cell.messageImageView.isHidden = false
      cell.messageTextView.isHidden = true
      cell.messageView.isHidden = true
      cell.timeLabel.isHidden = true


      let myCellSize: CGFloat = (self.view.frame.height / 3)
      cell.messageImageView.image = self.conversations[indexPath.row].thumbnail


      if(conversations[indexPath.row].isIncoming)!
      {
        // Incoming message
        cell.messageImageView.frame = CGRect(x: 8, y: 5, width: myCellSize + 8, height: myCellSize + 20)
        if(conversations[indexPath.row].type == .video)
        {
          cell.timeLabel.isHidden = false

          cell.timeLabel.text = getMinutesString(seconds: conversations[indexPath.row].duration!)
          cell.timeLabel.frame = CGRect(x: -4, y: myCellSize + 20, width: myCellSize + 8, height: 20)
        }
      }

      else
      {

        // Outgoing message
        let leftMargin = frameWidth - myCellSize - 32.0
        let senderWidth = myCellSize + 24

        cell.messageImageView.frame = CGRect(x: leftMargin, y: 8, width: senderWidth, height: myCellSize + 20)

        if(conversations[indexPath.row].type == .video)
        {
          cell.timeLabel.isHidden = false

          cell.timeLabel.text = getMinutesString(seconds: conversations[indexPath.row].duration!)
          cell.timeLabel.frame = CGRect(x: leftMargin - 8, y: myCellSize, width: senderWidth, height: 20)
        }
      }

    }

    cell.layoutIfNeeded()

    return cell
  }


  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

    if conversations[indexPath.row].type == .text
    {
      if let messageText = conversations[indexPath.row].content {
        let size = CGSize(width: 250.0, height: .infinity)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedSize = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
        return (estimatedSize.height + 30)
      }
    }
    return ((self.view.frame.height / 3) + 30.0)
  }


  @objc private func onLogoutPressed(){
    do{
      try Auth.auth().signOut()
    } catch let error{
      print(error)
    }
    self.dismiss(animated: true, completion: nil)
  }

  @objc private func handleDataAnalyticsTapped()
  {
    messageBoxTextView.endEditing(true)
    messageContainerView.isHidden = true
    galleryContainer.isHidden = true

    let dataAnalyticsVC = AnalyticsViewController()
    self.navigationController?.pushViewController(dataAnalyticsVC, animated: true)
  }

  @objc private func onSendButtonPressed() {
    let message: String! = messageBoxTextView.text ?? ""
    if(!message.isEmpty) {
      let newMessage: Message = Message.init(isIncoming: false, sender: userName, content: message.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines), type: .text, thumbnail: nil, localURL: nil, duration: nil)

      addMessageToChat(newMessage: newMessage)

      resetMessageBox()
      getBotResponse(userMessage: newMessage)
    }
  }

  @objc private func handleKeyboardNotifications(notification: NSNotification)
  {
    if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {

      let isKeyboardShowing = (notification.name == UIResponder.keyboardWillShowNotification)
      let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
      self.messageContainerBottomConstraint?.constant = isKeyboardShowing ? -keyboardSize.height: 0

      UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
        self.navigationController?.view.layoutIfNeeded()
      }, completion: nil)
    }
  }

  @objc private func onGalleryTapped() {
    let galleryViewController = GalleryViewController()
    galleryViewController.imageSelectedDelegate = self
    galleryViewController.view.backgroundColor = UIColor.clear
    galleryViewController.modalPresentationStyle = .overCurrentContext
    self.present(galleryViewController, animated: true, completion: nil)
  }



  private func welcomeUser() {
    let msg: Message = Message.init(isIncoming: true, sender: "Chat Bot", content: "Welcome!", type: .text, thumbnail: nil,localURL: nil, duration: nil)

    conversations.append(msg)

    tableView.reloadData()
  }

  func textViewDidChange(_ textView: UITextView)
  {
    let size = CGSize(width: messageBoxTextView.frame.width, height: .infinity)
    let estimatedSize = messageBoxTextView.sizeThatFits(size)

    if(estimatedSize.height < 85)
    {
      messageBoxTextView.isScrollEnabled = false
      messageContainerHeightConstraint?.constant = estimatedSize.height + 10
    }
    else
    {
      messageBoxTextView.isScrollEnabled = true
    }
  }


  private func addMessageToChat(newMessage: Message)
  {
    conversations.append(newMessage)
    let indexPath = IndexPath(row: self.conversations.count-1, section: 0)
    tableView.insertRows(at: [indexPath], with: .bottom)
    tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
  }



  private func resetMessageBox()
  {
    messageBoxTextView.text = ""
    messageBoxTextView.isScrollEnabled = false

    messageContainerHeightConstraint?.constant = 43
  }


  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    tableView.reloadData()
  }

  private func getBotResponse(userMessage: Message) {
    var response: String = ""

    if(userMessage.type == .text) {
      if let content = userMessage.content {
        if content == "Hello" || content == "Hi" || content == "Hi!"  || content == "Hello!" {
           response = "Hi!"
        } else if content == "How are you?" {
          response = "I'm fine! And you?"
        } else {
          response = "Sorry, I didn't get that"
        }
      }
    }
    else if (userMessage.type == .photo) {
      response = "Nice picture!"
    }
    else if (userMessage.type == .video) {
      response = "Nice Video!"
    }
    else {
       response = "How are you?"
    }

    let newMessage: Message = Message.init(isIncoming: true, sender: "Bot", content: response, type: .text, thumbnail: nil, localURL: nil, duration: nil)

    self.addMessageToChat(newMessage: newMessage)
  }


  private func getMinutesString(seconds: Float) -> String {
    let seconds_int: Int = Int(seconds)
    let minutes = (seconds_int % 3600) / 60
    let seconds = (seconds_int % 3600) % 60

    return seconds < 10 ? "\(minutes):0\(seconds)": "\(minutes):\(seconds)"
  }



  var messageContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.white

    view.layer.cornerRadius = 3
    view.layer.masksToBounds = true
    view.clipsToBounds = false

    return view
  }()


  var messageBoxTextView: UITextView = {
    let textView = UITextView()
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.font = UIFont.systemFont(ofSize: 14)
    textView.layer.cornerRadius = 15
    textView.layer.masksToBounds = true
    textView.layer.borderWidth = 1
    textView.layer.borderColor = UIColor(red:0.77, green:0.77, blue:0.77, alpha:1.0).cgColor

    return textView
  }()

  lazy var sendButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setBackgroundImage(#imageLiteral(resourceName: "send"), for: .normal)

    button.layer.masksToBounds = true
    button.layer.cornerRadius = 16.5

    button.addTarget(self, action: #selector(onSendButtonPressed), for: .touchUpInside)
    return button
  }()


  var galleryContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.clear
    return view
  }()



  lazy var galleryButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(#imageLiteral(resourceName: "gallery"), for: .normal)
    button.addTarget(self, action: #selector(onGalleryTapped), for: .touchUpInside)
    button.layer.masksToBounds = true
    return button
  }()

  var messageContainerHeightConstraint: NSLayoutConstraint?
  var messageContainerBottomConstraint: NSLayoutConstraint?
  var galleryContainerHeightConstraint: NSLayoutConstraint?


  private func setupViews() {

    let myView = self.navigationController?.view

    myView?.addSubview(messageContainerView)
    messageContainerHeightConstraint = messageContainerView.heightAnchor.constraint(equalToConstant: 43)
    messageContainerHeightConstraint?.isActive = true

    messageContainerBottomConstraint = messageContainerView.bottomAnchor.constraint(equalTo: (myView?.bottomAnchor)!, constant: 0)
    messageContainerBottomConstraint?.isActive = true

    messageContainerView.centerXAnchor.constraint(equalTo: (myView?.centerXAnchor)!).isActive = true
    messageContainerView.widthAnchor.constraint(equalTo: (myView?.widthAnchor)!, multiplier: 1).isActive = true

    setupGalleryButtons()

    messageContainerView.addSubview(messageBoxTextView)
    messageBoxTextView.heightAnchor.constraint(equalToConstant: 33).isActive = true

    messageBoxTextView.widthAnchor.constraint(equalTo: messageContainerView.widthAnchor, multiplier: 1, constant: -82).isActive = true
    messageBoxTextView.leftAnchor.constraint(equalTo: galleryButton.rightAnchor, constant: 4).isActive = true
    messageBoxTextView.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 5).isActive = true
    messageBoxTextView.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -5).isActive = true
    messageBoxTextView.delegate = self


    messageContainerView.addSubview(sendButton)
    sendButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
    sendButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
    sendButton.leftAnchor.constraint(equalTo: messageBoxTextView.rightAnchor, constant: 4).isActive = true
    sendButton.rightAnchor.constraint(equalTo: messageContainerView.rightAnchor, constant: -4).isActive = true
    sendButton.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -4).isActive = true
  }


  private func setupGalleryButtons() {
    let myView = self.navigationController?.view

    myView?.addSubview(galleryContainer)
    galleryContainerHeightConstraint = galleryContainer.heightAnchor.constraint(equalToConstant: 43)
    galleryContainerHeightConstraint?.isActive = true

    galleryContainer.widthAnchor.constraint(equalToConstant: 33).isActive = true
    galleryContainer.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor).isActive = true
    galleryContainer.leftAnchor.constraint(equalTo: messageContainerView.leftAnchor, constant: 4).isActive = true


    galleryContainer.addSubview(galleryButton)
    galleryButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
    galleryButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
    galleryButton.centerXAnchor.constraint(equalTo: galleryContainer.centerXAnchor).isActive = true
    galleryButton.bottomAnchor.constraint(equalTo: galleryContainer.bottomAnchor, constant: -4).isActive = true

    galleryContainer.addSubview(galleryButton)
    galleryButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
    galleryButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
    galleryButton.centerXAnchor.constraint(equalTo: galleryContainer.centerXAnchor).isActive = true
    galleryButton.bottomAnchor.constraint(equalTo: galleryContainer.bottomAnchor, constant: -4).isActive = true

    galleryContainer.bringSubviewToFront(galleryButton)
  }


}









