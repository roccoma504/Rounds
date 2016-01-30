//
//  InfoViewController.swift
//  round
//
//  Created by Matthew Rocco on 1/29/16.
//  Copyright © 2016 Matthew Rocco. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var drinkText: UITextField!
    
    private var documentsPath : String!
    private let defaults = NSUserDefaults.standardUserDefaults()
    private var drink : String!


    override func viewDidLoad() {
        super.viewDidLoad()
        documentsPath = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true)[0] + "/"
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        print(documentsPath)
        
        let userObj = objectRetrieve(managedContext, name: defaults.stringForKey("name")!, entity: "User")
        print(userObj)
        drink = userObj.valueForKey("drink") as! String
        updateUI()
    }
    
    
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueDestVC = segue.destinationViewController
        let destVC = segueDestVC as! LandingViewController
        destVC.transFromLobby = true
    }
}
