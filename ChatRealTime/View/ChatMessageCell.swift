//
//  ChatMessageCell.swift
//  ChatRealTime
//
//  Created by Dante Solorio on 7/22/16.
//  Copyright © 2016 Dante Solorio. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let tv = UITextView()
//        tv.text = "SAMPLE TEXT"
        tv.font = UIFont.systemFontOfSize(16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clearColor()
        tv.textColor = .whiteColor()
        tv.editable = false
        return tv
    }()
    
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "nedstark")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        bubbleView.addSubview(messageImageView)
        
        messageImageView.leftAnchor.constraintEqualToAnchor(bubbleView.leftAnchor).active = true
        messageImageView.rightAnchor.constraintEqualToAnchor(bubbleView.rightAnchor).active = true
        messageImageView.topAnchor.constraintEqualToAnchor(bubbleView.topAnchor).active = true
        messageImageView.bottomAnchor.constraintEqualToAnchor(bubbleView.bottomAnchor).active = true
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.active = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8)
        
        bubbleView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraintEqualToConstant(200)
        bubbleWidthAnchor?.active = true
        bubbleView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
        
//        textView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        textView.leftAnchor.constraintEqualToAnchor(bubbleView.leftAnchor, constant: 8).active = true
        textView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        textView.rightAnchor.constraintEqualToAnchor(bubbleView.rightAnchor).active = true
        textView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
        
        profileImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        profileImageView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(32).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(32).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
