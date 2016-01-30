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
}
