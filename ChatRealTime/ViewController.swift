//
//  ViewController.swift
//  ChatRealTime
//
//  Created by Dante Solorio on 7/5/16.
//  Copyright © 2016 Dante Solorio. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogout))
    }
    
    
    func handleLogout(){
        let loginController = LoginViewController()
        presentViewController(loginController, animated: true, completion: nil)
    }


}

