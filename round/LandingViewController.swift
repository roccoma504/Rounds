//
//  ViewController.swift
//  rounds
//
//  Created by Matthew Rocco on 1/7/16.
//  Copyright © 2016 Matthew Rocco. All rights reserved.
//

import UIKit

//MARK: - Private
private let defaults = NSUserDefaults.standardUserDefaults()

class LandingViewController: UIViewController, PFLogInViewControllerDelegate {
    
    var transFromLobby : Bool = false
    
    /**
     On load we want to check if the user is logged in. If not
     we present the login screen. We then check to see if the user
     has completed their setup process. If not we present the setup.
     Finally if the user is all setup we jump into the app.
     */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "registeredApp:", name:FBSDKProfileDidChangeNotification, object: nil)
        
            if (PFUser.currentUser() == nil) || transFromLobby {
                transFromLobby = false
                
                let loginViewController = LoginViewController()
                loginViewController.delegate = self
                loginViewController.fields =  .Facebook
                
                self.presentViewController(loginViewController,
                    animated: false,
                    completion: nil)
            }
            else if !(defaults.boolForKey("setup")) {
                self.performSegueWithIdentifier("loginToDrink", sender: self)
                
            }
            else {
                self.performSegueWithIdentifier("loginToLobby", sender: self)
            }
        
    }
    
    //MARK: - Facebook login related methods.
    
    /**
    This is the callback when the user logs in.
    */
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     This is the callback when the users profile has successfully
     registered. Here we store the users name and ID for use later.
     - Parameters:
     - notification: the observed notification
     */
    func registeredApp(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(FBSDKProfileDidChangeNotification)
        //Remove the observer and set the relevant user info.
        if FBSDKProfile.currentProfile() != nil {
        defaults.setValue(FBSDKProfile.currentProfile().name, forKey: "name")
        defaults.setValue(FBSDKProfile.currentProfile().firstName, forKey: "firstName")
        defaults.setValue(FBSDKProfile.currentProfile().userID, forKey: "facebookId")
        defaults.setValue(randomString(), forKey: "objId")
        transFromLobby = false
        }
    }
}

