//
//  SignUpViewController.swift
//  FirebaseChatApp
//
//  Created by Admin on 03/08/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {

    var ref : DatabaseReference!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
       
    }

    @IBAction func submitTapped(_ sender: Any) {
        
        if (!Validator.validateTextFields(textFields: [self.emailTextField,self.passwordTextField,self.nameTextField])){
            // self.showAlert("Invalid Field", message: "Please fill all the fields")
            let alert = UIAlertController(title: "Invalid Field", message: "Please fill all fields", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
            
        else if (!Validator.validateEmail(email: self.emailTextField.text!)){
            // self.showAlert("Invalid Field", message: "Please fill all the fields")
            let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid email", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if error != nil
            {
                print(error?.localizedDescription)
                let alert = UIAlertController(title: "Error signing up", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                print(Auth.auth().currentUser?.uid)
                var key = self.ref.child("user").child((Auth.auth().currentUser!.uid))
                var user = ["name": self.nameTextField.text,
                            "email": self.emailTextField.text
                               ] as [String : Any]
                print(user)
                
                key.updateChildValues(user)
                self.performSegue(withIdentifier: "GoToTabBar", sender: self)

            }
        })
        }

        
    }
  
}
