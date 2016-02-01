    //
    //  InfoViewController.swift
    //  round
    //
    //  Created by Matthew Rocco on 1/29/16.
    //  Copyright © 2016 Matthew Rocco. All rights reserved.
    //
    
    import UIKit
    
    class InfoViewController: UIViewController, UITextFieldDelegate {
        
        @IBOutlet weak var image: UIImageView!
        @IBOutlet weak var drinkText: UITextField!
        @IBOutlet weak var textField: UITextView!
        
        private var documentsPath : String!
        private let defaults = NSUserDefaults.standardUserDefaults()
        private var drink : String!
        
        /**
         On load prepare core data elemtns and load the drink and image for the
         user.
         */
        override func viewDidLoad() {
            super.viewDidLoad()
            
            //Looks for single or multiple taps to dismiss a text field.
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                action: "dismissKeyboard")
            view.addGestureRecognizer(tap)
            
            documentsPath = NSSearchPathForDirectoriesInDomains(
                .DocumentDirectory, .UserDomainMask, true)[0] + "/"
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            let userObj = objectRetrieve(managedContext, name: defaults.stringForKey("name")!, entity: "User")
            drink = userObj.valueForKey("drink") as! String
            
            textField.text = "Go ahead and chage your drink! When done, tap the background or hit Done on the keyboard and we'll save it for your next round!"
            textField.textColor = UIColor .whiteColor()
            
            updateUI()
        }
        
        /**
         Update the UI.
         */
        private func updateUI(){
            dispatch_async(dispatch_get_main_queue(),{
                self.image.image = UIImage(contentsOfFile: self.documentsPath+"profile_pic.jpg")
                self.image.layer.borderColor = UIColor.whiteColor().CGColor
                self.image.layer.borderWidth = 1.0;
                self.image.layer.cornerRadius = 5.0;
                self.image.layer.masksToBounds = true;
                self.drinkText.text = self.drink
            })
        }
        
        /**
         When the user is done editing save the changes to Core Data.
         */
        @IBAction func editEnd(sender: AnyObject) {
            if drinkText.text != nil {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                let userObj = objectRetrieve(managedContext, name: defaults.stringForKey("name")!, entity: "User")
                userObj.setValue(drinkText.text, forKey: "drink")
                
                do {
                    try managedContext.save()
                    defaults.setObject(userObj.valueForKey("drink"), forKey: "drink")
                    showAlert("Your drink was saved!", title: "Success!")
                    
                }
                catch {
                    showAlert("There was an error. Your changes were not saved", title: "Error!")
                }
            }
        }
        
        //# MARK Text field subprograms.
        
        // When the keyboard is dismissed end the editing on the field.
        func dismissKeyboard() {
            view.endEditing(true)
        }
        
        // Called when the return key is pressed.
        func textFieldShouldReturn(textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            let segueDestVC = segue.destinationViewController
            let destVC = segueDestVC as! LandingViewController
            destVC.transFromLobby = true
        }
        
        /**
         This subprogram generates an alert for the user based upon conditions
         in the application.
         */
        private func showAlert(message : String,
            title : String) {
                dispatch_async(dispatch_get_main_queue(),{
                    let alertController = UIAlertController(title: title, message:
                        message, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss",
                        style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController,animated: true,completion: nil)
                })
        }
        
        
    }
