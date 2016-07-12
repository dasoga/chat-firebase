//
//  ChatLogController.swift
//  ChatRealTime
//
//  Created by Dante Solorio on 7/11/16.
//  Copyright © 2016 Dante Solorio. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate {
    
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .whiteColor()
        
        setupInputComponents()
    }
    
    func setupInputComponents(){
        let containterView = UIView()
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
        childRef.updateChildValues(values)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}