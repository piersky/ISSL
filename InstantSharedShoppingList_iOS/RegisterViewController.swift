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
                    newUser.document(self.emailTextField.text!).setData([
                        "name": self.nameTextField.text!,
                        "email": self.emailTextField.text!,
                        "created": createdAt])
                    
                    self.defaults.set(self.nameTextField.text!, forKey: "user_name")
                    self.defaults.set(self.emailTextField.text!, forKey: "user_email")
                    
                    self.performSegue(withIdentifier: "gotoItems", sender: nil)
                }
            }
        } else {
            showErrorAlert(msg: "Dati inseriti non validi: \(validation)")
        }
    }
    
    func validateForm() -> String {
        var res = ""
        
        if emailTextField.text!.count < 4 {
            res += "Email troppo corta "
        }
        
        if !passwordTextField.text!.elementsEqual(checkPasswordTextField.text!) {
            res += "Password non uguali "
        }
        
        if passwordTextField.text!.count < 4 {
            res += "Password troppo corta"
        }
        
        return res
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
