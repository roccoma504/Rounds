//
//  User.swift
//  rounds
//
//  Created by Matthew Rocco on 1/10/16.
//  Copyright © 2016 Matthew Rocco. All rights reserved.
//

import CoreData
import UIKit

class User: NSManagedObject {
    
    //MARK: - Private
    private var name : String!
    private var id : String!
    private var facebookId: String!
    private var inLobby : Bool!
    private var lobbyNumber : String!
    private var favoriteDrink : String!
    private var errorMessage : String!
    private var isError : Bool = false
    private var place : Int!
    private var parseObjId : String!
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    convenience init(name: String,
        id: String,
        facebookId: String,
        favoriteDrink: String,
        inLobby: Bool,
        lobbyNumber: String,
        place: Int) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext

            let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)!
            self.init(entity: entity, insertIntoManagedObjectContext: managedContext)
            
            self.name = name
            self.id = id
            self.facebookId = facebookId
            self.favoriteDrink = favoriteDrink
            self.inLobby = inLobby
            self.lobbyNumber = lobbyNumber
            self.place = place
    }
    
    /**
     This function saves the new user to Parse.
     */
    func saveToParse (completion: (result: Bool) -> Void) {
        
        let userInfo = PFObject(className:"UserInfo")
        userInfo["drink"] = favoriteDrink
        userInfo["objId"] = id
        userInfo["facebookId"] = facebookId
        userInfo["name"] = name
        userInfo["inLobby"] = inLobby
        userInfo["lobbyNumber"] = lobbyNumber
        userInfo["place"] = place
        
        
        userInfo.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("uploaded")
            } else {
                self.isError = true
                self.errorMessage = "The network appears to be offline."
            }
            completion(result: true)
        }
    }
    
    func parseId(completion: (result: Bool) -> Void) {
        
        let query = PFQuery(className:"UserInfo")
        query.whereKey("objId", equalTo:id)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        self.parseObjId = object.objectId
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
                self.isError = true
                self.errorMessage = "The network appears to be offline."
            }
            completion(result: true)
        }
    }
    
    func updateParse (completion: (result: Bool) -> Void) {
        
        let query = PFQuery(className:"UserInfo")
        query.getObjectInBackgroundWithId(parseObjId) {
            (user: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print("error here")
                print(error)
                self.isError = true
                self.errorMessage = "Lobby could not be made. Check your connection."
            } else if let user = user {
                user["inLobby"] = self.inLobby
                user["lobbyNumber"] = self.lobbyNumber
                user["place"] = self.place
                user["drink"] = self.favoriteDrink
                user.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                    if succeeded {
                        print("Save successful")
                    } else {
                        print("Save unsuccessful: \(error?.userInfo)")
                    }
                    completion(result: true)
                })
            }
        }
    }
    
    
    /** Returns a flag noting if there was an error.
     - Returns: error flag
     */
    func errorPresent() -> Bool {
        return isError
    }
    
    /** Returns an error message. Will be nil if there is no error.
     - Returns: the error message
     */
    func errorText() -> String {
        return errorMessage
    }
}
