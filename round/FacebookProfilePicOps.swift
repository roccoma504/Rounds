//
//  FacebookProfilePicOps.swift
//  rounds
//
//  Created by Matthew Rocco on 1/10/16.
//  Copyright © 2016 Matthew Rocco. All rights reserved.
//

import UIKit

class FacebookProfilePicOps {
    
    //MARK: - Private
    private var errorMessage : String!
    private var isError : Bool = false
    private var pictureURL : String!
    private var profilePic : UIImage!
    private var userID : String!
    
    init(userID : String) {
        self.userID = userID
        pictureURL = "https://graph.facebook.com/"+(userID)+"/picture?type=large"
    }
    
    /**
     Retrieves the user's profile picture.
     */
    func profilePic(completion: (result: Bool) -> Void) {
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: NSURL(string: pictureURL)!)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            // Check if there is an error with the request.
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                self.errorMessage = "There was an error with your request."
                self.isError = true
                completion(result: true)
                return
            }
            self.downloadImage(NSURL(string: self.pictureURL)!, completion: {
                (result) -> Void in
                completion(result: true)
            })
        }
        task.resume()
    }
    
    /**
     Downloads an image from a given URL.
     - Parameters:
     - url - URL where we want to download the image
     */
    private func downloadImage(url: NSURL, completion: (result: Bool) -> Void)  {
        getDataFromUrl(url) { (data, response, error)  in
            guard let data = data where error == nil else {
                print("error downloading picture")
                return }
            self.profilePic = UIImage(data: data)!
            completion(result: true)
        }
    }
    
    /** Downloads the data from the URL.
     - Parameters:
     - url - URL where we want to download the image
     */
    private func getDataFromUrl(url:NSURL,
        completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
            NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
                completion(data: data, response: response, error: error)
                }.resume()
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
    
    /** Returns the profile picture.
     - Returns: the profile pic
     */
    func profilePicture() -> UIImage {
        return profilePic
    }
    
}
