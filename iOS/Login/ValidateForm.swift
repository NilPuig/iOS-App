//
//  ValidateForm.swift
//  Clerkie
//
//  Created by Nil Puig on 16/11/2018.
//  Copyright © 2018 Nil Puig. All rights reserved.
//


import Foundation
import UIKit

class ValidateForm{

  func checkUserInput(username: String, password: String, viewController: UIViewController) -> Bool {
    if(username.isEmpty || password.isEmpty) {
      viewController.showAlertWith(title: "Empty Input field", message: "Username and password cannot be empty.")
      return false
    }

    let phone = Int(username)
    if let phone = phone {
      if username.count != 10 {
        viewController.showAlertWith(title: "Invalid Phone", message: "Invalid phone number. Please verify")
        return false
      }
      return true
    }
    else if(!isValidEmail(username)) {
      viewController.showAlertWith(title: "Invalid Email", message: "Make sure you enter a valid email")
      return false
    }

    return true
  }

  func isValidEmail(_ testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
  }


}
