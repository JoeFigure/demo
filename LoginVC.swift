//
//  LoginVC.swift
//  Bok
//
//  Created by Joe Kletz on 04/08/2017.
//  Copyright © 2017 Joe Kletz. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func signIntoFirebase() {
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id,first_name,last_name,email,gender,age_range,name"]).start{
            (collection,result,error) in
            
            let fbDetails = result as! NSDictionary
            
            let accessToken = FBSDKAccessToken.current()
            guard let accessTokenString = accessToken?.tokenString else {return}
            
            let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            
            Auth.auth().signIn(with: credentials, completion: { (user,error) in
                if error != nil{
                    //ERROR
                    return
                }else{
                    self.checkIfNewUser(fbDetails)
                }
            })
        }
    }
    
    func checkIfNewUser(_ fbDetails:NSDictionary) {
        
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild((Auth.auth().currentUser?.uid)!){
                
                self.completeSignIn()
                
            }else{
                
                //User doesnt exist
                let newUser = User(firstName: fbDetails["first_name"] as! String, lastName: fbDetails["last_name"] as! String, email: fbDetails["email"] as! String)
                
                self.addUserToDatabase(user: newUser)
            }
        })
    }
    
    func addUserToDatabase(user:User){

        let usersDbRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        usersDbRef.setValue(user.makeObject()){ (error, ref) -> Void in
            
            //Add account creation date
            let dateJoined = ["accountCreation":Int(NSDate().timeIntervalSince1970)]
            
            usersDbRef.updateChildValues(dateJoined)
            
            self.completeSignIn()
        }
        
    }

    func completeSignIn() {
        
        self.performSegue(withIdentifier: "login", sender: nil)
    }

    
    
    @IBAction func customFBLogin(_ sender: Any) {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email","public_profile"], from: self) { (result, err) in
            
            if err == nil{
                self.signIntoFirebase()
                
            } else{
                print(err.debugDescription)
            }
        }
    }


    
}

