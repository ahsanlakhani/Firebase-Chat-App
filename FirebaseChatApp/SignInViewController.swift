//
//  SignInViewController.swift
//  FirebaseChatApp
//
//  Created by Admin on 03/08/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import JSQMessagesViewController

class SignInViewController: UIViewController {
    

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ref = Database.database().reference()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isLoggedIn()
        {
            performSegue(withIdentifier: "GoToTabBar", sender: self)
        }
        self.navigationController?.navigationBar.isHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false

    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        if (!Validator.validateTextFields(textFields: [self.emailTextField,self.passwordTextField])){
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
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error != nil
                {
                    let alert = UIAlertController(title: "Error signing up", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    self.performSegue(withIdentifier: "GoToTabBar", sender: self)
                }
            })
        }
        
        
    }
    
    func isLoggedIn() -> Bool
    {
        if Auth.auth().currentUser != nil
        {
            return true
        }
        return false
    }
    
    
}
extension UIViewController
{
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension JSQMessagesViewController
{
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
