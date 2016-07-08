//
//  ViewController.swift
//  ChatRealTime
//
//  Created by Dante Solorio on 7/5/16.
//  Copyright © 2016 Dante Solorio. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogout))
        let newMessageIconImage = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageIconImage, style: .Plain, target: self, action: #selector(handleNewMessage))
        checkIfUSerIsLoggedIn()
    }
    
    func checkIfUSerIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil{
            performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        }else{
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    self.navigationItem.title = dictionary["name"] as? String
                }
                
                }, withCancelBlock: nil)
            
        }
   
    }
    
    
    func handleLogout(){
        do{
            try FIRAuth.auth()?.signOut()
        }catch let logoutError{
            print(logoutError)
        }
        
        let loginController = LoginViewController()
        presentViewController(loginController, animated: true, completion: nil)
    }
    
    func handleNewMessage(){
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        presentViewController(navController, animated: true, completion: nil)
    }


}

