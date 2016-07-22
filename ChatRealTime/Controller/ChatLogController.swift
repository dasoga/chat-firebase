//
//  ChatLogController.swift
//  ChatRealTime
//
//  Created by Dante Solorio on 7/11/16.
//  Copyright © 2016 Dante Solorio. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var inputMessageTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter message..."
        textField.delegate = self
        return textField
    }()

    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    let cellId = "cellId"
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .whiteColor()
        collectionView?.registerClass(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupInputComponents()
    }
    
    func setupInputComponents(){
        let containterView = UIView()
        containterView.backgroundColor = .whiteColor()
        containterView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containterView)
        
        // Container inputs contraints
        containterView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        containterView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        containterView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        containterView.heightAnchor.constraintEqualToConstant(50).active = true
        
        let sendButton = UIButton(type: .System)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.addTarget(self, action: #selector(handleSend), forControlEvents: .TouchUpInside)
        containterView.addSubview(sendButton)
        
        // Send button constraints
        sendButton.rightAnchor.constraintEqualToAnchor(containterView.rightAnchor).active = true
        sendButton.bottomAnchor.constraintEqualToAnchor(containterView.bottomAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(80).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(containterView.heightAnchor).active = true
        
        containterView.addSubview(inputMessageTextField)
        
        // Input message textfield constraints
        inputMessageTextField.leftAnchor.constraintEqualToAnchor(containterView.leftAnchor, constant: 8).active = true
        inputMessageTextField.centerYAnchor.constraintEqualToAnchor(containterView.centerYAnchor).active = true
        inputMessageTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active = true
        inputMessageTextField.heightAnchor.constraintEqualToAnchor(containterView.heightAnchor).active = true
        
        let separatorLineView = UIView()
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        
        containterView.addSubview(separatorLineView)
        
        // Separator view constraints
        separatorLineView.leftAnchor.constraintEqualToAnchor(containterView.leftAnchor).active = true
        separatorLineView.topAnchor.constraintEqualToAnchor(containterView.topAnchor).active = true
        separatorLineView.widthAnchor.constraintEqualToAnchor(containterView.widthAnchor).active = true
        separatorLineView.heightAnchor.constraintEqualToConstant(1).active = true
    }
    
    func handleSend(){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        let values = ["text": inputMessageTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp]
//        childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            
            self.inputMessageTextField.text = nil
            
             let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromId)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipientUserMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId)
            recipientUserMessageRef.updateChildValues([messageId: 1])
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    func observeMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:AnyObject] else{
                    return
                }
                
                let message = Message()
                message.setValuesForKeysWithDictionary(dictionary)
                
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView?.reloadData()
                    })
                }
                
                
                
                }, withCancelBlock: nil)
            
            
            }, withCancelBlock: nil)
    }
    
    
    // MARK: - Collection view methods
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
}
