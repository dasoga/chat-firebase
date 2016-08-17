//
//  ChatInputContainerView.swift
//  ChatRealTime
//
//  Created by Dante Solorio on 8/17/16.
//  Copyright © 2016 Dante Solorio. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    var chatLogController: ChatLogController? {
        didSet{
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
            
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), forControlEvents: .TouchUpInside)
        }
    }
    
    lazy var inputMessageTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter message..."
        textField.delegate = self
        return textField
    }()
    
    let uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.userInteractionEnabled = true
        return uploadImageView
    }()
    
    
    let sendButton = UIButton(type: .System)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .whiteColor()
        
        addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        uploadImageView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        uploadImageView.widthAnchor.constraintEqualToConstant(44).active = true
        uploadImageView.heightAnchor.constraintEqualToConstant(44).active = true
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", forState: .Normal)
//        sendButton.addTarget(self, action: #selector(handleSend), forControlEvents: .TouchUpInside)
        addSubview(sendButton)
        
        // Send button constraints
        sendButton.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        sendButton.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(80).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(heightAnchor).active = true
        
        addSubview(self.inputMessageTextField)
        
        // Input message textfield constraints
        self.inputMessageTextField.leftAnchor.constraintEqualToAnchor(uploadImageView.rightAnchor, constant: 8).active = true
        self.inputMessageTextField.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        self.inputMessageTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active = true
        self.inputMessageTextField.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
        
        let separatorLineView = UIView()
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        
        addSubview(separatorLineView)
        
        // Separator view constraints
        separatorLineView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        separatorLineView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        separatorLineView.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
        separatorLineView.heightAnchor.constraintEqualToConstant(1).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        chatLogController?.handleSend()
        return true
    }
    
    
}
