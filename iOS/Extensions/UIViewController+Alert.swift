//
//  UIViewController+Alert
//  Clerkie
//
//  Created by Nil Puig on 16/11/2018.
//  Copyright © 2018 Nil Puig. All rights reserved.
//

import UIKit


extension UIViewController {
    func showAlertWith(title: String, message: String) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}





