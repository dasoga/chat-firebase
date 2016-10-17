//
//  NewMessageController.swift
//  ChatRealTime
//
//  Created by Dante Solorio on 7/8/16.
//  Copyright © 2016 Dante Solorio. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    
    var users = [User]()
    
    var messagesController: MessagesController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    func fetchUser(){
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                DispatchQueue.main.async(execute: { 
                    self.tableView.reloadData()
                })
            }
            
            
            }, withCancel: nil)
    }
    
    func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[(indexPath as NSIndexPath).item]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            
//            let url = NSURL(string: profileImageUrl)
//            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
//                
//                if error != nil{
//                    print(error)
//                    return
//                }
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    cell.profileImageView.image = UIImage(data: data!)
//                })
//            }).resume()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { 
            let user = self.users[(indexPath as NSIndexPath).item]
            self.messagesController?.showChatControllerForUser(user)
        }
    }

}


