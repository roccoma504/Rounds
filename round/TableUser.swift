//
//  File.swift
//  round
//
//  Created by Matthew Rocco on 1/23/16.
//  Copyright © 2016 Matthew Rocco. All rights reserved.
//

import Foundation

class TableUser : Comparable {
    
    private var name : String!
    private var drink : String!
    private var place: Int!
    private var image: UIImage!
    
    init(name:String, drink: String, place:Int, image: UIImage) {
        self.name = name
        self.drink = drink
        self.place = place
        self.image = image
    }
    
    func userName() -> String {
        return name
    }
    
    func userDrink() -> String {
        return drink
    }
    
    func userPlace() -> Int {
        return place
    }
    
    func userImage() -> UIImage {
        return image
    }
    
}

func ==(lhs: TableUser, rhs: TableUser) -> Bool {
    return(lhs.place == rhs.place)
}

func <(lhs: TableUser, rhs: TableUser) -> Bool{
    return(lhs.place < rhs.place)
}

func >(lhs: TableUser, rhs: TableUser) -> Bool{
    return(lhs.place > rhs.place)
}