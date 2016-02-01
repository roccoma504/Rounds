//
//  DrinkViewController.swift
//  round
//
//  Created by Matthew Rocco on 1/18/16.
//  Copyright © 2016 Matthew Rocco. All rights reserved.
//

import CoreData
import UIKit

class DrinkViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Private
    private let defaults = NSUserDefaults.standardUserDefaults()
    private var documentsPath : String!
    private var imagePicker = UIImagePickerController()
    
    //MARK: - Outlets
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var drinkText: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var continueButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIButton!
    
    /**
     On load set up the view to not allow the user to do anything until
     we load. Begin fetching the facebook profile picture.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        documentsPath = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true)[0] + "/"
        
        //Looks for single or multiple taps to dismiss a text field.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
            action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        continueButton.enabled = false
        
        drinkText.hidden = true
        drinkText.delegate = self
        
        messageText.text = "Firing off electrons to load your profile..."
        messageText.textColor = UIColor .whiteColor()
        messageText.textAlignment = .Center
        
        getProfilePic()
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
    
    @IBAction func picturePress(sender: AnyObject) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Defines a function that is invoked when the cancel button is pressed.
    @IBAction func cancelButtonPress(sender: AnyObject) {
        performSegueWithIdentifier("cancelPressSegue", sender: nil)
    }
    
    //# MARK: Image picker functions.
    
    // Defines a function that is called when the user picks an image.
    // If the image is good set it to the image view and enable the share
    // button. Dismiss the view either way.
    func imagePickerController(picker: UIImagePickerController!,
        didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
            if let selectedImage : UIImage = image {
                profilePicture.image = selectedImage
                profilePicture.contentMode = .ScaleAspectFill
            }
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Defines a function that is called when the user cancels the pick.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     This subprogram generates an alert for the user based upon conditions
     in the application. This view controller can generate two different
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
     This helper function wraps the call to retrieve the users profile
     picture.
     */
    private func getProfilePic() {
        let photoOps = FacebookProfilePicOps(userID: defaults.stringForKey("facebookId")!)
        photoOps.profilePic { (result) -> Void in
            
            // If there was an error present it to the user.
            if photoOps.errorPresent() {
                self.showAlert(photoOps.errorText())
            }
                // If everything went well, update the profile picture and store.
            else {
                // Update the UI.
                dispatch_async(dispatch_get_main_queue(),{
                    self.setProfile(photoOps.profilePicture())
                    self.activityView.stopAnimating()
                    
                    // Convert the image to data for storage.
                    let imageData: NSData =
                    UIImageJPEGRepresentation(photoOps.profilePicture(), 1.0)!
                    let filePath = self.documentsPath.stringByAppendingString("profile_pic.jpg")
                    let success = imageData.writeToFile(filePath, atomically: true)
                    if !success {
                        self.showAlert("Could not save image. Your storage may be full. Free some space and try again.")
                    }
                    self.defaults.setValue("profile_pic.jpg", forKey: "picturePath")
                })
            }
        }
    }
    
    /**
     Set the users profile including the image and the welcoming message.
     */
    private func setProfile(image: UIImage) {
        dispatch_async(dispatch_get_main_queue(),{
            self.profilePicture.image = image
            self.profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
            self.profilePicture.layer.borderWidth = 1.0;
            self.profilePicture.layer.cornerRadius = 5.0;
            self.profilePicture.layer.masksToBounds = true;
            self.activityView.stopAnimating()
            self.drinkText.hidden = false
            self.editButton.hidden = false
            self.messageText.text = "Hey there " + self.defaults.stringForKey("firstName")! + " and welcome to Rounds. If you don't like the picture we found, click on it to change it to one in your library. Next enter your go to drink. This will be your default drink when you enter a new Round."
            self.messageText.textColor = UIColor .whiteColor()            
        })
    }
    
    func saveUser() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("User",
            inManagedObjectContext:managedContext)
        let user = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)        
        
        // Set all of the managed object values/
        
        /**
        Try to save the values to Core Data. If succssful update the data
        in Parse. If everything went well, transition to the next view.
        */
        do {
            user.setValue(drinkText.text, forKey: "drink")
            user.setValue(defaults.stringForKey("id"), forKey: "id")
            user.setValue(defaults.stringForKey("name"), forKey: "name")
            user.setValue(false, forKey: "inLobby")
            user.setValue("null", forKey: "lobbyNumber")
            
            try managedContext.save()
            defaults.setBool(true, forKey: "setupDone")
            
            let newUser = User(
                name: defaults.stringForKey("name")!,
                id: defaults.stringForKey("objId")!,
                facebookId: defaults.valueForKey("facebookId") as! String,
                favoriteDrink: drinkText.text!,
                inLobby: false,
                lobbyNumber: "null",
                place: 0)
            
            newUser.saveToParse({ (result) -> Void in
                if newUser.errorPresent() {
                    self.showAlert(newUser.errorText())
                }
                else {
                    self.defaults.setValue(self.drinkText.text, forKey: "drink")
                    self.defaults.setBool(true, forKey: "setupDone")
                    self.performSegueWithIdentifier("drinkToSwitcher", sender: self)
                }
            })
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    /**
     When the user his continue check the input. Only proceed if there is
     something there.
     */
    @IBAction func continueButton(sender: AnyObject) {
        if (drinkText.text != "") {
            defaults.setBool(true, forKey: "setup")
            saveUser()
            performSegueWithIdentifier("drinkToLobby", sender: self)
        }
        else {
            showAlert("Opps. Looks like you didn't enter a drink.")
            continueButton.enabled = false
        }
    }
    
    /**
     When we begin editing, enable the continue button.
     */
    @IBAction func drinkFieldBegin(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(),{
            self.continueButton.enabled = true
        })
    }
    
}
