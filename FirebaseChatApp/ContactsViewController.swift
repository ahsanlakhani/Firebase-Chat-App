//
//  ContactsViewController.swift
//  FirebaseChatApp
//
//  Created by Admin on 03/08/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

var currentUserName:String!


class ContactsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var ref :DatabaseReference!
    var contacts : [Contacts] = []
    var selectedContact: Contacts!
    


    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        getContacts()
        setNavigationItemTitle()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ContactsTableViewCell
        
        cell.nameLabel.text = contacts[indexPath.row].name
        cell.emailLabel.text = contacts[indexPath.row].email
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedContact = self.contacts[indexPath.row]
        performSegue(withIdentifier: "GoToChatVC", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ChatViewController
        destination.participant = selectedContact
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedPost = self.posts[indexPath.row]
//        performSegue(withIdentifier: "GoToAppliedStudentsVC", sender: self)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let destination = segue.destination as! AppliedStudentsViewController
//        destination.applicationKey = selectedPost.key
//    }
    
    func getContacts()
    {
        if let contactsref = ref?.child("user") {
            print(ref)
        _ = contactsref.observe(DataEventType.childAdded, with: { (snapshot) in
           let contactsDict = snapshot.value as? [String : AnyObject] ?? [:]
            print(contactsDict)
            let name = contactsDict["name"] as! String
            let email = contactsDict["email"] as! String
            let key = snapshot.key
            
            let contact = Contacts(name: name, email: email, id: key )
            if contact.id != Auth.auth().currentUser!.uid
            {
                self.contacts.append(contact)
                self.tableView.reloadData()
            }
           
            // ...
        })
        
        }
    }
    
    
    func setNavigationItemTitle()
    {
        if Auth.auth().currentUser?.uid != nil
        {
        let uid = Auth.auth().currentUser?.uid
        ref.child("user").child(uid!).observeSingleEvent(of: .value, with:
            { (snapshot) in
            
            if let dict = snapshot.value as? [String : AnyObject]
                {
                    let name = dict["name"] as! String
                    self.navigationItem.title = name
                    currentUserName = name
                }
            
            }, withCancel: nil)
        }
    }
    
    
    @IBAction func signOutTapped(_ sender: Any) {
        try! Auth.auth().signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "firstNavigationController") as! UINavigationController
            self.present(vc, animated: false, completion: nil)
        }

    }
    
   

}
