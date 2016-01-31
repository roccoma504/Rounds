//
//  UpdateUser.swift
//  round
//
//  Created by Matthew Rocco on 1/24/16.
//  Copyright © 2016 Matthew Rocco. All rights reserved.
//


class UpdateUser : NSObject {
    
    private var id : String!
    private var place : Int!
    private var errorMessage : String!
    private var isError : Bool = false
    private var userCount : Int!
    
    init(id : String, place : Int, userCount : Int) {
        self.id = id
        self.place = place
        self.userCount = userCount
    }
    
    func updatePlace(completion: (result: Bool) -> Void) {
        
        if place == 0 {
            place = userCount - 1
        }
            
        else {
            place = place - 1
        }
        
        let query = PFQuery(className:"UserInfo")
        query.getObjectInBackgroundWithId(id) {
            (user: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
                self.isError = true
                self.errorMessage = "Cannot connect to the server. Check your connection."
            } else if let user = user {
                user["place"] = self.place
                user.saveInBackground()
            }
            completion(result: true)
        }
    }
    
    func newPlace() -> Int {
        return place
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
