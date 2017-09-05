//
//  Contacts.swift
//  FirebaseChatApp
//
//  Created by Admin on 05/08/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class Contacts: NSObject {
    
    var name: String!
    var email: String!
    var id: String!
    
    init(name:String,email:String,id:String)
    {
        self.name=name
        self.email=email
        self.id=id
    }

}
