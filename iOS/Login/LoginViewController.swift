//
//  LoginViewController.swift
//  iOS
//
//  Created by Nil Puig on 16/11/2018.
//  Copyright © 2018 Nil Puig. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UIViewControllerTransitioningDelegate, RegistrationDelegate {

  let bubbleAnimation = BubbleAnimation()
  let validateForm = ValidateForm()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupViews()

    self.hideKeyboardOnTap()

    let notifier = NotificationCenter.default
    notifier.addObserver(self,
                         selector: #selector(moveKeyboardIfOverlap),
                         name: UIWindow.keyboardWillShowNotification,
                         object: nil)
    notifier.addObserver(self,
                         selector: #selector(moveKeyboardIfOverlap),
                         name: UIWindow.keyboardWillHideNotification,
                         object: nil)

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    UIApplication.shared.statusBarStyle = .default
    initialAnimation()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
  }


  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
  }

  // Reset login form
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    usernameTextField.text = ""
    passwordTextField.text = ""
  }

  func RegistrationResult(isSuccess: Bool) {
    if(isSuccess) {
      showAlertWith(title: "Welcome", message: "Please login to start using the app")
    }
  }

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    bubbleAnimation.transitionMode = .present
    bubbleAnimation.startingPoint = signupButton.center
    bubbleAnimation.circleColor = signupButton.backgroundColor!

    return bubbleAnimation
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    bubbleAnimation.transitionMode = .dismiss
    bubbleAnimation.startingPoint = signupButton.center
    bubbleAnimation.circleColor = signupButton.backgroundColor!

    return bubbleAnimation
  }


  // MARK: Keyboard events

  @objc func moveKeyboardIfOverlap(notification: NSNotification) {

    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {

      let isKeyboardShowing = (notification.name == UIResponder.keyboardWillShowNotification)
      if isKeyboardShowing {
        if(keyboardFrame.intersects(self.loginButton.frame)) {
          let buffer = self.loginButton.frame.maxY - keyboardFrame.minY
          self.view.frame.origin.y = -buffer
        }
      }
      else  {
        self.view.frame.origin.y = 0
      }
    }
  }

  // MARK: Login / Sign up actions

  @objc private func onLoginPressed() {
    let username: String = usernameTextField.text ?? ""
    let password: String = passwordTextField.text ?? ""

    if(validateForm.checkUserInput(username: username, password: password, viewController: self)) {
      Auth.auth().signIn(withEmail: username, password: password) {
        (user, error) in
        if error == nil && user != nil {
          self.goToChatViewController()
        } else if let error = error {
          let description = error.localizedDescription
          let networkError = "Network error"
          let passwordError = "The password is invalid"
          let noUserError = "no user record"

          if description.contains(networkError) {
            self.showAlertWith(title: networkError, message: "The Internet connection appears to be offline.")
          } else if description.contains(passwordError) {
            self.showAlertWith(title: passwordError, message: "Make sure you have entered the correct password.")
          } else if description.contains(noUserError) {
            self.showAlertWith(title: "Account doesn't exist", message: "There is no user record corresponding to this username.")
          }  else {
            self.showAlertWith(title: "Login Error", message: "Unable to Login to your account. Please try again later.")
          }
        } else {
          self.showAlertWith(title: "Login Error", message: "Unable to Login to your account. Please try again later.")
        }
      }
    }
  }


  @objc private func onSignupPressed() {
    let signUpVC = SignUpViewController()
    signUpVC.delegate = self
    signUpVC.transitioningDelegate = self
    signUpVC.modalPresentationStyle = .custom
    self.present(signUpVC, animated: true, completion: nil)
  }

  func goToChatViewController() {
    let chatViewController = UINavigationController(rootViewController: ChatViewController())
    self.present(chatViewController, animated: true, completion: nil)
  }

  // MARK: Animation

  private func initialAnimation() {
    titleLabel.alpha = 0
    usernameContainer.alpha = 0
    usernameTextField.alpha = 0
    passwordContainer.alpha = 0
    passwordTextField.alpha = 0
    loginButton.alpha = 0
    signupButton.alpha = 0

    let myTransform: CGAffineTransform = CGAffineTransform(translationX: 0, y: 40)
    titleLabel.transform = myTransform
    usernameContainer.transform = myTransform
    usernameTextField.transform = myTransform
    passwordContainer.transform = myTransform
    passwordTextField.transform = myTransform
    loginButton.transform = myTransform
    signupButton.transform = CGAffineTransform(scaleX: 0, y: 0)

    UIView.animate(withDuration: 1) {
      self.titleLabel.alpha = 1
      self.usernameContainer.alpha = 1
      self.usernameTextField.alpha = 1
      self.passwordContainer.alpha = 1
      self.passwordTextField.alpha = 1
      self.loginButton.alpha = 1
      self.signupButton.alpha = 1

      self.titleLabel.transform = .identity
      self.usernameContainer.transform = .identity
      self.usernameTextField.transform = .identity
      self.passwordContainer.transform = .identity
      self.passwordTextField.transform = .identity
      self.loginButton.transform = .identity
      self.signupButton.transform = .identity
    }
  }

  // MARK: UI elements

  var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Clerkie"
    label.adjustsFontSizeToFitWidth = true
    label.textAlignment = .center
    label.font = UIFont(name: "Helvetica-Bold", size: 40)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .black
    return label
  }()

  var usernameContainer: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  var usernameTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Username"
    textField.textAlignment = .center
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.font = UIFont(name: "Helvetica-Bold", size: 15)
    textField.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
    textField.layer.cornerRadius = 20

    textField.dropShadow()
    return textField
  }()

  var passwordContainer: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  var passwordTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Password"
    textField.textAlignment = .center
    textField.isSecureTextEntry = true
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.textContentType = UITextContentType.password
    textField.font = UIFont(name: "Helvetica-Bold", size: 15)
    textField.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
    textField.layer.cornerRadius = 20
    textField.dropShadow()
    return textField
  }()

  var loginButton: UIButton = {
    let button = UIButton()
    button.setTitle("Login", for: .normal)
    button.titleLabel?.font =  UIFont(name: "Helvetica-Bold", size: 20)
    button.setTitleColor(UIColor.white, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false

    button.layer.cornerRadius = 20
    button.backgroundColor = UIColor.main
    button.dropShadow()
    button.addTarget(self, action: #selector(onLoginPressed), for: .touchUpInside)
    return button
  }()

  var signupButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = UIColor.main
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("+", for: .normal)
    button.titleLabel?.font =  UIFont(name: "Helvetica-Bold", size: 20)

    button.layer.cornerRadius = 20
    button.dropLongShadow()

    button.addTarget(self, action: #selector(onSignupPressed), for: .touchUpInside)
    return button
  }()


  // MARK: Set up views

  private func setupViews() {
    view.backgroundColor = UIColor.white

    setupPasswordTextField()

    setupUsernameTextField()

    setupTitle()

    setupLoginButton()

    setupSignupButton()
  }

  private func setupUsernameTextField() {
    view.addSubview(usernameContainer)
    usernameContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    usernameContainer.bottomAnchor.constraint(equalTo: passwordContainer.topAnchor, constant: -10).isActive = true
    usernameContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
    usernameContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

    usernameContainer.addSubview(usernameTextField)
    usernameTextField.heightAnchor.constraint(equalTo: usernameContainer.heightAnchor, multiplier: 0.8).isActive = true
    usernameTextField.widthAnchor.constraint(equalTo: usernameContainer.widthAnchor, multiplier: 0.8).isActive = true
    usernameTextField.centerXAnchor.constraint(equalTo: usernameContainer.centerXAnchor).isActive = true
    usernameTextField.centerYAnchor.constraint(equalTo: usernameContainer.centerYAnchor).isActive = true
  }


  private func setupPasswordTextField() {
    view.addSubview(passwordContainer)
    passwordContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    passwordContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    passwordContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
    passwordContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

    passwordContainer.addSubview(passwordTextField)
    passwordTextField.heightAnchor.constraint(equalTo: passwordContainer.heightAnchor, multiplier: 0.8).isActive = true
    passwordTextField.widthAnchor.constraint(equalTo: passwordContainer.widthAnchor, multiplier: 0.8).isActive = true
    passwordTextField.centerXAnchor.constraint(equalTo: passwordContainer.centerXAnchor).isActive = true
    passwordTextField.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor).isActive = true
  }

  private func setupTitle() {
    view.addSubview(titleLabel)
    titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    titleLabel.bottomAnchor.constraint(equalTo: usernameContainer.topAnchor, constant: -30).isActive = true
    titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
  }

  private func setupLoginButton() {
    view.addSubview(loginButton)
    loginButton.topAnchor.constraint(equalTo: passwordContainer.bottomAnchor, constant: 24).isActive = true
    loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true // 0.7
    loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
  }


  private func setupSignupButton() {
    view.addSubview(signupButton)
    signupButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
    signupButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    signupButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -35).isActive = true
    signupButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 55).isActive = true
  }

}

