//
//  RegisterViewController.swift
//  InstantSharedShoppingList_iOS
//
//  Created by Pier Luigi Papeschi on 21/07/2019.
//  Copyright © 2019 Pier Luigi Papeschi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class RegisterViewController: UIViewController {
    
    var db: Firestore!
    let defaults = UserDefaults.standard
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var checkPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        let validation = validateForm()
        if validation.isEmpty {
            SVProgressHUD.show()
            
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                
                (user, error) in
                SVProgressHUD.dismiss()
                
                if error != nil {
                    print(error!)
                    self.showErrorAlert(msg: error!.localizedDescription)
                } else {
                    print("Registrazione ok!")
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    let createdAt = dateFormatter.string(from: Date())
                    
                    //Insert personal data in to the database
                    let newUser = self.db.collection("users")
                    
                    newUser
                        .document(self.emailTextField.text!)
                        .setData([
                            "name": self.nameTextField.text!,
                            "email": self.emailTextField.text!,
                            "created": createdAt
                        ])
                    
                    self.defaults.set(self.nameTextField.text!, forKey: K.u_name)
                    self.defaults.set(self.emailTextField.text!, forKey: K.u_mail)
                    
                    self.performSegue(withIdentifier: "gotoItems", sender: nil)
                }
            }
        } else {
            showErrorAlert(msg: NSLocalizedString("Data not valid", comment: "Inserted data") + ": \(validation)")
        }
    }
    
    func validateForm() -> String {
        var res = ""
        
        if emailTextField.text!.count < 4 {
            res += NSLocalizedString("Email short", comment: "Inglese")
        }
        
        if !passwordTextField.text!.elementsEqual(checkPasswordTextField.text!) {
            res += NSLocalizedString("Password not equal", comment: "Inglese")
        }
        
        if passwordTextField.text!.count < 4 {
            res += NSLocalizedString("Password short", comment: "Inglese")
        }
        
        return res
    }
    
    func showErrorAlert(msg: String) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Inglese"), message: msg, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: "Inglese"),
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
