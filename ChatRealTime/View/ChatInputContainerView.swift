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
            
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
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
        uploadImageView.isUserInteractionEnabled = true
        return uploadImageView
    }()
    
    
    let sendButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: UIControlState())
//        sendButton.addTarget(self, action: #selector(handleSend), forControlEvents: .TouchUpInside)
        addSubview(sendButton)
        
        // Send button constraints
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        addSubview(self.inputMessageTextField)
        
        // Input message textfield constraints
        self.inputMessageTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputMessageTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputMessageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputMessageTextField.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        
        addSubview(separatorLineView)
        
        // Separator view constraints
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSend()
        return true
    }
    
    
}
