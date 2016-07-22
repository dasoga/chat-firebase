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
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    var cellId = "cellId"

    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogout))
        let newMessageIconImage = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageIconImage, style: .Plain, target: self, action: #selector(handleNewMessage))
     
        checkIfUSerIsLoggedIn()
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)

    }
    
    func observeUserMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let messageId = snapshot.key
            let messageReference = FIRDatabase.database().reference().child("messages").child(messageId)
            messageReference.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let message = Message()
                    message.setValuesForKeysWithDictionary(dictionary)
                    
                    if let chatPartnerId = message.chatPartnerId(){
                        self.messagesDictionary[chatPartnerId] = message
                        
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sortInPlace({ (message1, message2) -> Bool in
                            return message1.timestamp?.intValue > message2.timestamp?.intValue
                        })
                    }
                    
                    self.timer?.invalidate()
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                    
                }
                
                }, withCancelBlock: nil)
            
            
            }, withCancelBlock: nil)
    }
    
    func handleReloadTable(){
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    func checkIfUSerIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil{
            performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        }else{
            fetchUserAndSetupNavBarTtitle()
        }
   
    }
    
    func fetchUserAndSetupNavBarTtitle(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            //for some reason uid = nil
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject]{
                let user = User()
                user.setValuesForKeysWithDictionary(dictionary)
                self.setupNavBarWithUser(user)
                
            }
            
            }, withCancelBlock: nil)
    }
    
    func setupNavBarWithUser(user: User){
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        //self.navigationItem.title = user.name
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .ScaleAspectFill
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        // iOS 9 constraint anchors
        profileImageView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(40).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(40).active = true
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = user.name
        
        containerView.addSubview(nameLabel)
        
        // nameLabel constraints
        nameLabel.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8).active = true
        nameLabel.centerYAnchor.constraintEqualToAnchor(profileImageView.centerYAnchor).active = true
        nameLabel.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        nameLabel.heightAnchor.constraintEqualToAnchor(profileImageView.heightAnchor).active = true
        
        containerView.centerXAnchor.constraintEqualToAnchor(titleView.centerXAnchor).active = true
        containerView.centerYAnchor.constraintEqualToAnchor(titleView.centerYAnchor).active = true
        
        self.navigationItem.titleView = titleView        
    }
    
    func showChatControllerForUser(user: User){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)        
    }
    
    func handleLogout(){
        do{
            try FIRAuth.auth()?.signOut()
        }catch let logoutError{
            print(logoutError)
        }
        
        let loginController = LoginViewController()
        loginController.messagesController = self
        presentViewController(loginController, animated: true, completion: nil)
    }
    
    func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    // MARK: - table view methods 
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UserCell
        
        let message = messages[indexPath.item]        
        cell.message = message
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let dictionary = snapshot.value as? [String:AnyObject] else{
                return
            }
            
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeysWithDictionary(dictionary)
            self.showChatControllerForUser(user)
            
            }, withCancelBlock: nil)
        
    }


}

