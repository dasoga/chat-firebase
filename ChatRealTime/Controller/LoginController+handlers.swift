//
//  LoginController+handlers.swift
//  ChatRealTime
//
//  Created by Dante Solorio on 7/8/16.
//  Copyright © 2016 Dante Solorio. All rights reserved.
//

import UIKit
import Firebase

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func handleLoginRegister(){
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0{
            handleLogin()
        }else{
            handleRegister()
        }
    }
    
    func handleLogin(){
        guard let email = emailTextField.text, password = passwordTextField.text else{
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if error != nil{
                print(error)
                return
            }
            
            // Successfully logged in our user
            self.messagesController?.fetchUserAndSetupNavBarTtitle()
            
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func handleRegister(){
        guard let email = emailTextField.text, password = passwordTextField.text, name = nameTextField.text else{
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil{
                print(error)
                return
            }
            
            
            guard let uid = user?.uid else{
                return
            }
            
            // Successfully
            let imageName = NSUUID().UUIDString
            let storageRef = FIRStorage.storage().reference().child("profile_imges").child("\(imageName).jpg")
            if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1){
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        self.registerUserIntoDatabaseWithUID(uid, values: values)
                    }
                })
            }

            
            
            
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid:String, values: [String:AnyObject]){
        let ref = FIRDatabase.database().referenceFromURL("https://chatrealtime-1e87d.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                print(err)
                return
            }
            
            self.messagesController?.navigationItem.title = values["name"] as? String
            
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func handleRegisterChange(){
        let title = loginRegisterSegmentedControl.titleForSegmentAtIndex(loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, forState: .Normal)
        
        // Change height of inputContainerView
        inputContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // Change height of name text field
        nameTextFieldHeightAnchor?.active = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraintEqualToAnchor(inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.active = true
        
        // Change height of email text field
        emailTextFieldHeightAnchor?.active = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraintEqualToAnchor(inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.active = true
        
        // Change height of password text field
        passwordTextFieldHeightAnchor?.active = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraintEqualToAnchor(inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.active = true
    }
    
    func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("Canceled picker")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
           selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
