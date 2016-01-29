//
//  LoginViewController.swift
//  rounds
//
//  Created by Matthew Rocco on 1/7/16.
//  Copyright © 2016 Matthew Rocco. All rights reserved.
//
//

import UIKit

class LoginViewController: PFLogInViewController{
    
    //MARK: - Private
    private var background : UIImageView!;
    private var finalPosArray : [CGFloat]!;
    private var viewArray: [UIView!]!;
    
    /**
     On appear we want the present the login view controller if there is
     no user logged in. If there is a user logged in we want to present
     the landing page.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Set the background image, size, and scale.
        background = UIImageView(image: UIImage(named: "login_bg"))
        background.contentMode = UIViewContentMode.ScaleAspectFill
        background.frame = CGRectMake( 0,  0,  logInView!.frame.width,  logInView!.frame.height)
        logInView!.insertSubview(background, atIndex: 1)
        
        /**
         Because we implemented the Parse login view controller, we need to
         override the base attributes. Here we override the logo with the
         app name and set the color, font, and aspect.
         */
        let mainLogo = UILabel()
        mainLogo.text = "R O U N D S"
        mainLogo.textColor = UIColor.whiteColor()
        mainLogo.font = UIFont(name: "OpenSans-Light", size: 50)
        logInView?.logo = mainLogo
        logInView!.logo!.sizeToFit()
        
        /**
        Set the attributes of the Facebook button. This is part of the Parse
        login view.
        */
        logInView?.facebookButton!.setBackgroundImage(nil, forState: .Normal)
        logInView?.facebookButton!.backgroundColor = UIColor.clearColor()
        logInView?.facebookButton!.layer.cornerRadius = 5
        logInView?.facebookButton!.layer.borderWidth = 1
        logInView?.facebookButton!.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Set the array of views.
        viewArray = [self.logInView?.facebookButton, self.logInView?.logo]
    }
    
    /**
     Here we figure out where all of the views are. This happens right after
     we initialize all of the views. The array of positions are used during the
     animation. Once we have all the initial positions, we move the views up.
     */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        background.frame = CGRectMake( 0,  0,  logInView!.frame.width,  logInView!.frame.height)
        finalPosArray = [CGFloat]();
        // Loop over every view to get the final desired position.
        for viewToAnimate in viewArray {
            let currentFrame = viewToAnimate.frame
            finalPosArray.append(currentFrame.origin.y)
            viewToAnimate.frame = CGRectMake(
                currentFrame.origin.x,
                self.view.frame.height + currentFrame.origin.y,
                currentFrame.width,
                currentFrame.height)
        }
        
        // Animate the moving of the views up the view.
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            options: .CurveEaseInOut,
            animations: { () -> Void in
                for viewToAnimate in self.viewArray {
                    let currentFrame = viewToAnimate.frame
                    viewToAnimate.frame = CGRectMake(
                        currentFrame.origin.x,
                        self.finalPosArray.removeAtIndex(0),
                        currentFrame.width,
                        currentFrame.height)
                }
            }, completion: nil)
    }
}

