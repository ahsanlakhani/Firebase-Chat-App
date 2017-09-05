//
//  GroupsViewController.swift
//  FirebaseChatApp
//
//  Created by Ahsan Lakhani on 8/12/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class GroupsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var ref :DatabaseReference!
    var groups : [Groups] = []
    var selectedGroup: Groups!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        getGroups()
        
        // Do any additional setup after loading the view.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = groups[indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedGroup = self.groups[indexPath.row]
        performSegue(withIdentifier: "GoToGroupChatVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! GroupChatViewController
        destination.group = selectedGroup
    }
    
    
    @IBAction func createTapped(_ sender: Any) {
        
        if (!Validator.validateTextFields(textFields: [self.groupNameTextField])){
            let alert = UIAlertController(title: "No Name", message: "Please enter a group name and then press create", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            createGroup()
        }
    
    }
    
    func getGroups()
    {
        let groupref = ref.child("groups")
        
        groupref.observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            let name = snapshot.value as! String
            
            let group = Groups(name: name, id: id)
            self.groups.append(group)
            self.tableView.reloadData()
        })
    }
    
    func createGroup()
    {
        let uuid = UUID().uuidString
        let groupref = ref.child("groups")
        
        let dict = [uuid:groupNameTextField.text]
        
        groupref.updateChildValues(dict)
        
        self.groupNameTextField.text = ""
    }
    
    


}
