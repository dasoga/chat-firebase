//
//  ChatMessageCell.swift
//  ChatRealTime
//
//  Created by Dante Solorio on 7/22/16.
//  Copyright © 2016 Dante Solorio. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    var message: Message?
    
    var chatLogController: ChatLogController?
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .System)
        button.setImage(UIImage(named: "play"), forState: .Normal)
        button.tintColor = .whiteColor()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlay), forControlEvents: .TouchUpInside)
        return button
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
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
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .ScaleAspectFill
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
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
        
        bubbleView.addSubview(playButton)
        playButton.centerXAnchor.constraintEqualToAnchor(bubbleView.centerXAnchor).active = true
        playButton.centerYAnchor.constraintEqualToAnchor(bubbleView.centerYAnchor).active = true
        playButton.widthAnchor.constraintEqualToConstant(50).active = true
        playButton.heightAnchor.constraintEqualToConstant(50).active = true
        
        bubbleView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraintEqualToAnchor(bubbleView.centerXAnchor).active = true
        activityIndicatorView.centerYAnchor.constraintEqualToAnchor(bubbleView.centerYAnchor).active = true
        activityIndicatorView.widthAnchor.constraintEqualToConstant(50).active = true
        activityIndicatorView.heightAnchor.constraintEqualToConstant(50).active = true
        
        
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
    
    // MARK: - Handles functions
    func handleZoomTap(tapGesture: UITapGestureRecognizer){
        if message?.videoUrl != nil{
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView{
            self.chatLogController?.performZoomInForStartingImageView(imageView)
        }
    }
    
    func handlePlay(){
        if let videoUrlString = message?.videoUrl, url = NSURL(string: videoUrlString){
            player = AVPlayer(URL: url)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.hidden = true
            print("play video...")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
}
