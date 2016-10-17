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
        guard let email = emailTextField.text, let password = passwordTextField.text else{
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                print(error)
                return
            }
            
            // Successfully logged in our user
            self.messagesController?.fetchUserAndSetupNavBarTtitle()
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else{
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil{
                print(error)
                return
            }
            
            
            guard let uid = user?.uid else{
                return
            }
            
            // Successfully
            let imageName = UUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_imges").child("\(imageName).jpg")
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                    }
                })
            }

            
            
            
        })
    }
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid:String, values: [String:AnyObject]){
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                print(err)
                return
            }
            
//            self.messagesController?.navigationItem.title = values["name"] as? String
            let user = User()
            user.setValuesForKeys(values)
            self.messagesController?.setupNavBarWithUser(user)
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleRegisterChange(){
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: UIControlState())
        
        // Change height of inputContainerView
        inputContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // Change height of name text field
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        // Change height of email text field
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        // Change height of password text field
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
           selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
