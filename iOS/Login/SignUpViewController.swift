//
//  SignUpViewController.swift
//  Clerkie
//
//  Created by Nil Puig on 16/11/2018.
//  Copyright © 2018 Nil Puig. All rights reserved.
//

import UIKit
import FirebaseAuth


protocol RegistrationDelegate {
  func RegistrationResult(isSuccess: Bool)
}


class SignUpViewController: UIViewController {

  let checkInput = ValidateForm()
  var delegate: RegistrationDelegate!

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.main
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
    UIApplication.shared.statusBarStyle = .lightContent
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
  }

  @objc func moveKeyboardIfOverlap(notification: NSNotification) {

    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {

      let isKeyboardShowing = (notification.name == UIResponder.keyboardWillShowNotification)
      if isKeyboardShowing {
        if(keyboardFrame.intersects(self.closeButton.frame)) {
          let buffer = self.closeButton.frame.maxY - keyboardFrame.minY
          self.view.frame.origin.y = -buffer
        }
      }
      else  {
        self.view.frame.origin.y = 0
      }
    }
  }

  @objc func onClosePressed() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc func onRegisterPressed() {
    let username: String! = usernameTextField.text ?? ""
    let password: String!  = passwordTextField.text ?? ""
    let reEnterPassword: String! = reEnterPasswordTextField.text ?? ""

    if(checkInput.checkUserInput(username: username, password: password, viewController: self)) {
      if(password != reEnterPassword) {
        self.showAlertWith(title: "Passwords don't match", message: "Make sure you provided the same password in the 2 fields.")
      }
      else {
        Auth.auth().createUser(withEmail: username, password: password) {
          (user, error) in
          if(error == nil && user != nil) {
            self.signupSuccess()
          }
          else {
            self.showAlertWith(title: "Registration Failed", message: "Unable to register your account. Make sure your password has at least 6 characters and your email is valid")
          }
        }
      }
    }
  }

  private func signupSuccess() {
    self.dismiss(animated: true, completion: nil)
    delegate.RegistrationResult(isSuccess: true)
  }

  var appTitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Welcome"
    label.adjustsFontSizeToFitWidth = true
    label.textAlignment = .center
    label.font = UIFont.boldSystemFont(ofSize: 40)
    label.textColor = .white
    return label
  }()


  var usernameContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .main
    return view
  }()

  var usernameTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "test@clerkie.com"
    textField.textAlignment = .center
    textField.font = UIFont(name: "Helvetica-Bold", size: 15)
    textField.backgroundColor = .white
    textField.layer.cornerRadius = 20
    textField.dropShadow()
    return textField
  }()


  var passwordContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .main
    return view
  }()

  var passwordTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Password"
    textField.textAlignment = .center
    textField.isSecureTextEntry = true
    textField.textContentType = UITextContentType.password
    textField.font = UIFont(name: "Helvetica-Bold", size: 15)
    textField.backgroundColor = .white
    textField.layer.cornerRadius = 20
    textField.dropShadow()
    return textField
  }()

  var reEnterPasswordContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .main
    return view
  }()

  var reEnterPasswordTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Re-type Password"
    textField.textAlignment = .center
    textField.isSecureTextEntry = true
    textField.textContentType = UITextContentType.password
    textField.font = UIFont(name: "Helvetica-Bold", size: 15)
    textField.backgroundColor = .white
    textField.layer.cornerRadius = 20
    textField.dropShadow()
    return textField
  }()


  var signupButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Sign up", for: .normal)
    button.titleLabel?.font =  UIFont(name: "Helvetica-Bold", size: 20)
    button.setTitleColor(.main, for: .normal)
    button.layer.cornerRadius = 20
    button.layer.backgroundColor = UIColor.white.cgColor
    button.dropShadow()

    button.addTarget(self, action: #selector(onRegisterPressed), for: .touchUpInside)
    return button
  }()

  var closeButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = UIColor.white
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("x", for: .normal)
    button.titleLabel?.font =  UIFont(name: "Helvetica-Bold", size: 20)
    button.setTitleColor(.main, for: .normal)
    button.layer.cornerRadius = 20
    button.dropLongShadow()

    button.addTarget(self, action: #selector(onClosePressed), for: .touchUpInside)


    return button
  }()

  private func setupViews() {
    setupPasswordTextField()

    setupUsernameTextField()

    setupRePasswordTextField()

    view.addSubview(appTitleLabel)
    appTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    appTitleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    appTitleLabel.bottomAnchor.constraint(equalTo: usernameContainer.topAnchor, constant: -24).isActive = true

    view.addSubview(signupButton)
    signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    signupButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
    signupButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    signupButton.topAnchor.constraint(equalTo: reEnterPasswordContainer.bottomAnchor, constant: 24).isActive = true

    view.addSubview(closeButton)
    closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 55).isActive = true
    closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -35).isActive = true
    closeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    closeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
  }


  private func setupUsernameTextField() {
    view.addSubview(usernameContainer)
    usernameContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
    usernameContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    usernameContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    usernameContainer.bottomAnchor.constraint(equalTo: passwordContainer.topAnchor, constant: -16).isActive = true

    usernameContainer.addSubview(usernameTextField)
    usernameTextField.heightAnchor.constraint(equalTo: usernameContainer.heightAnchor, multiplier: 0.8).isActive = true
    usernameTextField.widthAnchor.constraint(equalTo: usernameContainer.widthAnchor, multiplier: 0.8).isActive = true
    usernameTextField.centerXAnchor.constraint(equalTo: usernameContainer.centerXAnchor).isActive = true
    usernameTextField.centerYAnchor.constraint(equalTo: usernameContainer.centerYAnchor).isActive = true
  }

  private func setupPasswordTextField() {
    view.addSubview(passwordContainer)
    passwordContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
    passwordContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    passwordContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    passwordContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

    passwordContainer.addSubview(passwordTextField)
    passwordTextField.heightAnchor.constraint(equalTo: passwordContainer.heightAnchor, multiplier: 0.8).isActive = true
    passwordTextField.widthAnchor.constraint(equalTo: passwordContainer.widthAnchor, multiplier: 0.8).isActive = true
    passwordTextField.centerXAnchor.constraint(equalTo: passwordContainer.centerXAnchor).isActive = true
    passwordTextField.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor).isActive = true

  }

  private func setupRePasswordTextField() {
    view.addSubview(reEnterPasswordContainer)
    reEnterPasswordContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
    reEnterPasswordContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    reEnterPasswordContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    reEnterPasswordContainer.topAnchor.constraint(equalTo: passwordContainer.bottomAnchor, constant: 16).isActive = true

    reEnterPasswordContainer.addSubview(reEnterPasswordTextField)
    reEnterPasswordTextField.heightAnchor.constraint(equalTo: reEnterPasswordContainer.heightAnchor, multiplier: 0.8).isActive = true
    reEnterPasswordTextField.widthAnchor.constraint(equalTo: reEnterPasswordContainer.widthAnchor, multiplier: 0.8).isActive = true
    reEnterPasswordTextField.centerXAnchor.constraint(equalTo: reEnterPasswordContainer.centerXAnchor).isActive = true
    reEnterPasswordTextField.centerYAnchor.constraint(equalTo: reEnterPasswordContainer.centerYAnchor).isActive = true
  }


}
