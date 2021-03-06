//
//  ParseNetworkOps.swift
//  round
//
//  Created by Matthew Rocco on 1/20/16.
//  Copyright © 2016 Matthew Rocco. All rights reserved.
//

import Foundation

class ParseNetworkOps {
    
    private var roomId : String!
    private var userNames : [String] = []
    private var userDrinks : [String] = []
    private var facebookIds : [String] = []
    private var objIds : [String] = []
    private var places : [Int] = []
    private var count = 0
    private var errorMessage : String!
    private var isError : Bool = false
    
    init(roomId : String){
        self.roomId = roomId
    }
    /**
     Determines the members in the lobby. This needs to be called
     before data is retrieved from this class.
     */
    func getLobbyMembers(completion: (result: Bool) -> Void) {
        // Perform a Parse query for the desired lobby number.
        let query = PFQuery(className:"UserInfo")
        query.whereKey("lobbyNumber", equalTo:roomId)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            // If everything went ok, build the arrays which contain info
            // on the users. Print the error if something bad happened.
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.userNames.append(object["name"] as! String)
                        self.userDrinks.append(object["drink"] as! String)
                        self.facebookIds.append(object["facebookId"] as! String)
                        self.places.append(object["place"] as! Int)
                        self.objIds.append(object.objectId!)
                    }
                }
            } else {
                self.isError = true
                self.errorMessage = "The server could not be reached. Check your connection."
                print("Error: \(error!) \(error!.userInfo)")
            }
            completion(result: true)
        }
    }
    
    /**
     This determines the number of users in the lobby. Print the error
     if something bad happened.
     */
    func getLobbyCount(completion: (result: Bool) -> Void) {
        let query = PFQuery(className:"UserInfo")
        query.whereKey("lobbyNumber", equalTo:roomId)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.count = objects.count
                }
            } else {
                self.isError = true
                self.errorMessage = "The server could not be reached. Check your connection."
                print("Error: \(error!) \(error!.userInfo)")
            }
            completion(result: true)
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
    
    func userNameArray() -> [String]! {
        return userNames
    }
    
    func userDrinkArray() -> [String]! {
        return userDrinks
    }
    
    func userfacebookIdArray() -> [String]! {
        return facebookIds
    }
    
    func placeArray() -> [Int]! {
        return places
    }
    
    func userCount() -> Int {
        return count
    }
    
    func userObjID() -> [String] {
        return objIds
    }
    
}