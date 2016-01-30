//
//  LobbyViewController.swift
//  round
//
//  Created by Matthew Rocco on 1/19/16.
//  Copyright © 2016 Matthew Rocco. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController {
    
    //MARK: - Private
    private let defaults = NSUserDefaults.standardUserDefaults()
    private var randomRoundID : String!
    
    //MARK: - Outlets
    @IBOutlet weak var newRound: UIButton!
    @IBOutlet weak var joinRound: UIButton!
    @IBOutlet weak var roomIdTextField: UITextField!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        newRound.layer.cornerRadius = 10
        newRound.layer.borderWidth = 1
        newRound.layer.borderColor = UIColor.whiteColor().CGColor
        joinRound.layer.cornerRadius = 10
        joinRound.layer.borderWidth = 1
        joinRound.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    /**
     This action creates a new round.
     */
    @IBAction func newRound(sender: AnyObject) {
        activity(true)
        randomRoundID = randomString()
        
        // Create a new user instances with the user defaults.
        let newUser = User(
            name: defaults.stringForKey("name")!,
            id: defaults.stringForKey("objId")!,
            facebookId: defaults.stringForKey("facebookId")!,
            favoriteDrink: defaults.stringForKey("drink")!,
            inLobby: true,
            lobbyNumber: randomRoundID,
            place: 0)
        
        defaults.setInteger(0, forKey: "place")
        
        newUser.parseId { (result) -> Void in
            newUser.updateParse({ (result) -> Void in
                if newUser.errorPresent() {
                    self.showAlert(newUser.errorText())
                }
                else {
                    self.performSegueWithIdentifier("lobbyToRound", sender: self)
                }
                self.activity(false)
            })
        }
    }
    
    /**
     This action joins an already existing round.
     */
    @IBAction func joinRound(sender: AnyObject) {
        activity(true)
        if !(roomIdTextField.text == nil) {
            let parseNetworkOps = ParseNetworkOps(roomId: roomIdTextField.text!)
            
            // Retrieve the number of users in the lobby. This allows us
            // to put the user at the end of the queue.
            parseNetworkOps.getLobbyCount({ (result) -> Void in
                
                // Set the new user place which is the count of the users
                // in the round (end of queue).
                self.defaults.setInteger(parseNetworkOps.userCount(), forKey: "place")
                
                let newUser = User(
                    name: self.defaults.stringForKey("name")!,
                    id: self.defaults.stringForKey("objId")!,
                    facebookId: self.defaults.stringForKey("facebookId")!,
                    favoriteDrink: self.defaults.stringForKey("drink")!,
                    inLobby: true,
                    lobbyNumber: self.roomIdTextField.text!,
                    place: parseNetworkOps.userCount())
                
                // If everything went well, transition to the lobby view.
                newUser.parseId({ (result) -> Void in
                    newUser.updateParse({ (result) -> Void in
                        if newUser.errorPresent() {
                            self.showAlert(newUser.errorText())
                        }
                        else {
                            self.randomRoundID = self.roomIdTextField.text
                            self.performSegueWithIdentifier("lobbyToRound", sender: self)
                        }
                        self.activity(false)
                    })
                })
            })
        }
        else {
            showAlert("That room is invalid!")
            self.activity(false)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "logout" {
            let segueDestVC = segue.destinationViewController
            let destVC = segueDestVC as! RoundTableViewController
            destVC.receivedRoomID = randomRoundID
        }
            
        else {
            let segueDestVC = segue.destinationViewController
            let destVC = segueDestVC as! LandingViewController
            destVC.transFromLobby = true
        }
    }
    
    @IBAction func logout(sender: AnyObject) {
        self.performSegueWithIdentifier("logout", sender: self)
    }
    
    /**
     This subprogram generates an alert for the user based upon conditions
     in the application. This view controller can generate different
     alerts so this is here only for reuseability.
     */
    private func showAlert(message : String) {
        dispatch_async(dispatch_get_main_queue(),{
            let alertController = UIAlertController(title: "Error!", message:
                message, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss",
                style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController,animated: true,completion: nil)
        })
    }
    
    /**
     Helper functions that wraps UI changes when the view is loading
     or no longer loading.
     */
    private func activity(start : Bool) {
        dispatch_async(dispatch_get_main_queue(),{
            if start {
                self.activityView.startAnimating()
                self.newRound.alpha = 0.8
                self.joinRound.alpha = 0.8
                self.roomIdTextField.alpha = 0.8
                self.view.alpha = 0.8
            }
            else {
                self.activityView.stopAnimating()
                self.newRound.alpha = 1.0
                self.joinRound.alpha = 1.0
                self.roomIdTextField.alpha = 1.0
                self.view.alpha = 1.0
            }
        })
    }
    
}
