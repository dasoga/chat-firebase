//
//  ChatLogController.swift
//  ChatRealTime
//
//  Created by Dante Solorio on 7/11/16.
//  Copyright © 2016 Dante Solorio. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    


    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    let cellId = "cellId"
    
    var messages = [Message]()
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .whiteColor()
        collectionView?.registerClass(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .Interactive
        
//        setupKeyboardObservers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    lazy var inputContainerView: ChatInputContainerView = {
        
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func setupKeyboardObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func handleKeyboardDidShow(){
        if messages.count > 0{
            let indexPath = NSIndexPath(forItem: messages.count - 1, inSection: 0)
            collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }
    }
    
    func handleKeyboardWillShow(notification: NSNotification){
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let height = keyboardFrame?.height
        
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        // Move the input area up
        containerViewBottomAnchor?.constant = -height!
        UIView.animateWithDuration(keyboardAnimationDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleKeyboardWillHide(notification: NSNotification){
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        containerViewBottomAnchor?.constant = 0
        UIView.animateWithDuration(keyboardAnimationDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleSend(){
        let properties = ["text": inputContainerView.inputMessageTextField.text!]
        sendMessageWithProperties(properties)
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage){
        let properties: [String: AnyObject] = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height]
        sendMessageWithProperties(properties)
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        var values: [String: AnyObject] = ["toId": toId, "fromId": fromId, "timestamp": timestamp]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            
            self.inputContainerView.inputMessageTextField.text = nil
            
            let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipientUserMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessageRef.updateChildValues([messageId: 1])
        }
    }
    
    func handleUploadTap(){
        let imagePickerControlelr = UIImagePickerController()
        imagePickerControlelr.allowsEditing = true
        imagePickerControlelr.delegate = self
        imagePickerControlelr.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        presentViewController(imagePickerControlelr, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL{
            // Selected a Video
            handleVideoSelectedForUrl(videoUrl)
        }else{
            // Selected an Image
            handleImageSelectedForInfo(info)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func handleVideoSelectedForUrl(url: NSURL){
        var fileSize: AnyObject?
        do{
            let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(url.path!)
            fileSize = fileAttributes[NSFileSize]
        }
        catch let err as NSError{
            //error handling
            print("Error getting size ",err)
        }
        
        
        let filename = NSUUID().UUIDString+".mov"
        let uploadTask = FIRStorage.storage().reference().child("message_movies").child(filename).putFile(url, metadata: nil) { (metadata, error) in
            if error != nil{
                print("Failed upload of video",error)
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString{
                print("Video saved ",videoUrl)
                
                
                if let thumbnailImage = self.thumbnailImageForFileUrl(url){
                    
                    self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl,"imageWidth": thumbnailImage.size.width, "imageHeight":thumbnailImage.size.height, "videoUrl": videoUrl]
                        self.sendMessageWithProperties(properties)

                    })
                    
                }
            }
        }
        
        uploadTask.observeStatus(.Progress) { (snapshot) in
            
            if let completedUnitCount = snapshot.progress?.completedUnitCount{
                if let size = fileSize{
                    self.navigationItem.title = String(completedUnitCount) + " of " + String(size)
                }else{
                    self.navigationItem.title = String(completedUnitCount)
                }
            }
        }
        
        uploadTask.observeStatus(.Success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func thumbnailImageForFileUrl(fileUrl: NSURL) -> UIImage?{
        let asset = AVAsset(URL: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do{
            let thumbnailCGImage = try imageGenerator.copyCGImageAtTime(CMTimeMake(1, 60), actualTime: nil)
            return UIImage(CGImage: thumbnailCGImage)
        }catch let err{
            print(err)
        }
        return nil
    }
    
    private func handleImageSelectedForInfo(info: [String: AnyObject]){
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
            })
            
        }
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: (imageUrl: String)-> ()){
        let imageName = NSUUID().UUIDString
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print("Failed to upload image:", error)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString{
                    completion(imageUrl: imageUrl)
                }
            })
        
        }
        
    }
    
    
    func observeMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid, toId = user?.id else{
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:AnyObject] else{
                    return
                }
                
                self.messages.append(Message(dictionary: dictionary))
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView?.reloadData()
                    // Scroll to the last index
                    let indexPath = NSIndexPath(forItem: self.messages.count - 1, inSection: 0)
                    self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                })
                
                }, withCancelBlock: nil)
            
            
            }, withCancelBlock: nil)
    }
    
    private func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
        
        return NSString(string: text).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16)], context: nil)
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message){
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid{
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .whiteColor()
            cell.profileImageView.hidden = true
            cell.bubbleViewRightAnchor?.active = true
            cell.bubbleViewLeftAnchor?.active = false
        }else{
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .blackColor()
            cell.profileImageView.hidden = false
            cell.bubbleViewRightAnchor?.active = false
            cell.bubbleViewLeftAnchor?.active = true
        }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.messageImageView.hidden = false
            cell.bubbleView.backgroundColor = UIColor.clearColor()
        }else{
            cell.messageImageView.hidden = true
        }
        
    }
    
    func performZoomInForStartingImageView(startingImageView: UIImageView){
        self.startingImageView = startingImageView
        self.startingImageView?.hidden = true
        
        startingFrame = startingImageView.superview?.convertRect(startingImageView.frame, toView: nil)
        print(startingFrame)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .redColor()
        zoomingImageView.image = startingImageView.image
        zoomingImageView.userInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.sharedApplication().keyWindow{
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .blackColor()
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                // MAth?
                // h2 / w1 = h1 /w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center

                }, completion: nil)
            }
    }
    
    // MARK: -  Handle functions
    func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomingOutView = tapGesture.view {
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: { 
                zoomingOutView.layer.cornerRadius = 16
                zoomingOutView.clipsToBounds = true
                
                zoomingOutView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
                }, completion: { (completed:Bool) in
                    zoomingOutView.removeFromSuperview()
                    self.startingImageView?.hidden = false
            })
        }
    }
    
    
    // MARK: - Collection view methods
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        
        cell.message = message
        
        cell.textView.text = message.text
        
        setupCell(cell, message: message)
        if let text = message.text{
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
            cell.textView.hidden = false
        }else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.hidden = true
        }
        
        cell.playButton.hidden = message.videoUrl == nil
        //cell.activityIndicatorView.hidden = message.videoUrl == nil
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[indexPath.row]
        if let text = message.text{
            height = estimateFrameForText(text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue, imageHeight = message.imageHeight?.floatValue{
            
            height = CGFloat(imageHeight / imageWidth * 200)
            
        }
        let width = UIScreen.mainScreen().bounds.width
        return CGSize(width: width, height: height)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}
