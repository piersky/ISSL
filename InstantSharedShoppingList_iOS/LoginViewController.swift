//
//  LoginViewController.swift
//  InstantSharedShoppingList_iOS
//
//  Created by Pier Luigi Papeschi on 21/07/2019.
//  Copyright © 2019 Pier Luigi Papeschi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    var db: Firestore!
    let defaults = UserDefaults.standard
    

    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (user, error) in
            
            SVProgressHUD.dismiss()
            if error != nil {
                print(error!)
                
                self.showErrorAlert(msg: error!.localizedDescription)
                
            } else {
                print("Login succesful...")
                
                let usersCollection = self.db.collection("users")
                let query = usersCollection.whereField("email", isEqualTo: self.emailTextField.text!)
                
                query.getDocuments() {(querySnapshot, error) in
                    if let docs = querySnapshot?.documents {
                        print("Nome \(docs[0].data()["name"] as! String)")
                        self.defaults.set((docs[0].data()["name"] as! String), forKey: "user_name")
                        self.defaults.set(self.emailTextField.text!, forKey: "user_email")
                    }
                }
                
                self.performSegue(withIdentifier: "gotoItems", sender: nil)
                
//                if let lID = self.defaults.string(forKey: "ListIdSelected") {
//                    if (lID.isEmpty) {
//                        self.performSegue(withIdentifier: "gotoLists", sender: nil)
//                    } else {
//                        self.performSegue(withIdentifier: "gotoItems", sender: nil)
//                    }
//                } else {
//                    self.performSegue(withIdentifier: "gotoLists", sender: nil)
//                }
            }
        }
    }
    
    func showErrorAlert(msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Retry",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
