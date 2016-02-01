//
//  RoundTableViewController.swift
//  round
//
//  Created by Matthew Rocco on 1/19/16.
//  Copyright © 2016 Matthew Rocco. All rights reserved.
//

import CoreData
import UIKit

class RoundTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buyRoundButton: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var changeButton: UIBarButtonItem!
    @IBOutlet weak var leaveButton: UIBarButtonItem!
    @IBOutlet weak var progressBar: UIProgressView!
    
    private var profilesReady = false
    private var names: [String]!
    private var drinks: [String]!
    private var ids: [String]!
    private var next: [Int]!
    private var timer: NSTimer!
    private var progressTimer: NSTimer!
    private var tableUserArray: [TableUser] = []
    private var photoCount = 0
    private var progress : Float = 0.0
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var refreshControl:UIRefreshControl!
    var receivedRoomID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     Everytime the view apears we want to set up the table and start
     the refresh timer.
     */
    override func viewDidAppear(animated: Bool) {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle =
            NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:",
            forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.addSubview(refreshControl)
        tableView.dataSource = self
        tableView.delegate = self
        
        idLabel.textColor = UIColor .whiteColor()
        idLabel.text = "Invite your friends to " + receivedRoomID
        
        buyRoundButton.layer.cornerRadius = 5
        buyRoundButton.layer.borderWidth = 1
        buyRoundButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        progressBar.setProgress(progress, animated: true)
        
        lobbyMembers()
        startTimers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        progressTimer.invalidate()
    }
    
    private func startTimers() {
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(
            5.0, target:self,
            selector: Selector("updateProgress:"),
            userInfo: nil,
            repeats: true)
        
    }
    
    func refresh(sender:AnyObject) {
        progressTimer.invalidate()
        progress = 0.0
        dispatch_async(dispatch_get_main_queue(),{
            self.progressBar.setProgress(self.progress, animated: true)
        })
        names = []
        drinks = []
        ids = []
        next = []
        tableUserArray = []
        profilesReady = false
        photoCount = 0
        reloadTable()
        startTimers()
    }
    
    func updateProgress(sender:AnyObject) {
        progress = progress + 0.1
        dispatch_async(dispatch_get_main_queue(),{
            self.progressBar.setProgress(self.progress, animated: true)
        })
        print(progress)
        if progress > 1.1 {
            refresh(self)
        }
    }
    
    private func lobbyMembers() {
        activity(true)
        let parseNetworkOps = ParseNetworkOps(roomId: receivedRoomID)
        parseNetworkOps.getLobbyMembers { (result) -> Void in
            if parseNetworkOps.errorPresent() {
                self.activity(false)
                self.showAlert(parseNetworkOps.errorText())
            }
            else {
                // These are guarenteed to be in order.
                self.names = parseNetworkOps.userNameArray()
                self.drinks = parseNetworkOps.userDrinkArray()
                self.ids = parseNetworkOps.userfacebookIdArray()
                self.next = parseNetworkOps.placeArray()
                // Here we do some sorting as the image may not come back in the
                // order we request them in.
                for id in self.ids {
                    let facebookPicture = FacebookProfilePicOps(userID: id)
                    facebookPicture.profilePic({ (result) -> Void in
                        if !(facebookPicture.errorPresent()) {
                            let tempIndex = self.ids.indexOf(id)!
                            
                            let tempUser = TableUser(
                                name: self.names[tempIndex],
                                drink: self.drinks[tempIndex],
                                place: self.next[tempIndex],
                                image: facebookPicture.profilePicture())
                            
                            if id == self.defaults.stringForKey("facebookId") {
                                self.defaults.setInteger(self.next[tempIndex], forKey: "place")
                            }
                            
                            self.photoCount += 1
                            self.tableUserArray.append(tempUser)
                            
                            if self.photoCount == self.names.count {
                                self.tableUserArray = self.tableUserArray.sort({$0 < $1})
                                self.profilesReady = true
                                self.reloadTable()
                            }
                        }
                        else {
                            self.activity(false)
                            self.showAlert(parseNetworkOps.errorText())
                        }
                        self.activity(false)
                    })
                }
            }
        }
    }
    
    private func reloadTable() {
        dispatch_async(dispatch_get_main_queue(),{
            self.activity(true)
            self.buyRoundButton.hidden = true
            if self.defaults.integerForKey("place") == 0 {
                self.buyRoundButton.hidden = false
            }
            self.lobbyMembers()
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.activity(false)
        })
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if profilesReady {
            count = names.count
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RoundTableViewCell
        
        if profilesReady {
            cell.friendImage.image = tableUserArray[indexPath.row].userImage()
            cell.nameLabel.text = tableUserArray[indexPath.row].userName()
            cell.drinkLabel.text = tableUserArray[indexPath.row].userDrink()
            cell.nextLabel.text = String(tableUserArray[indexPath.row].userPlace())
            
            if tableUserArray[indexPath.row].userPlace() == 0 {
                cell.nextLabel.text = "Next"
            }
            
            cell.nameLabel.textColor = UIColor .whiteColor()
            cell.drinkLabel.textColor = UIColor .whiteColor()
            cell.nextLabel.textColor = UIColor .whiteColor()
            
            cell.friendImage.layer.borderColor = UIColor.whiteColor().CGColor
            cell.friendImage.layer.borderWidth = 1.0
            cell.friendImage.layer.cornerRadius = cell.friendImage.frame.height/2
            cell.friendImage.layer.masksToBounds = false
            cell.friendImage.clipsToBounds = true
        }
        return cell
    }
    
    /**
     This subprogram generates an alert for the user based upon conditions
     in the application. This view controller can generate different
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
     This subprogram generates an alert for the user based upon conditions
     in the application. This view controller can generate different
     alerts so this is here only for reuseability.
     */
    private func showAlert(title: String!, message : String) {
        dispatch_async(dispatch_get_main_queue(),{
            let alertController = UIAlertController(title: title, message:
                message, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss",
                style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController,animated: true,completion: nil)
        })
    }
    
    private func updateDrink(newDrink : String) {
        activity(true)
        if !(newDrink == "") {
            
            let newUser = User(
                name: defaults.stringForKey("name")!,
                id: defaults.stringForKey("objId")!,
                facebookId: defaults.stringForKey("facebookId")!,
                favoriteDrink: newDrink,
                inLobby: true,
                lobbyNumber: receivedRoomID,
                place: defaults.integerForKey("place"))
            
            newUser.parseId { (result) -> Void in
                if !(newUser.errorPresent()) {
                    newUser.updateParse({ (result) -> Void in
                        if !(newUser.errorPresent()) {
                            self.defaults.setValue(newDrink, forKey: "drink")
                            self.save(newDrink)
                            self.refresh(self)
                        }
                        else {
                            self.showAlert(newUser.errorText())
                        }
                        self.activity(false)
                    })
                }
                else {
                    self.activity(false)
                    self.showAlert(newUser.errorText())
                }
            }
        }
        else {
            self.activity(false)
            showAlert("Your entry was invalid, no changes were made.")
        }
    }
    
    @IBAction func leaveRound(sender: AnyObject) {
        activity(true)
        let newUser = User(
            name: defaults.stringForKey("name")!,
            id: defaults.stringForKey("objId")!,
            facebookId: defaults.stringForKey("facebookId")!,
            favoriteDrink: defaults.stringForKey("drink")!,
            inLobby: false,
            lobbyNumber: "",
            place: 0)
        /**
        When a user laeves we need to do some work in removing him from
        the lobby. Ideally this would all be done in server code on the
        backend but thats not what this class is about. Loop through all
        of the users in the lobby and check if their place is behind
        the place of the person leaving. If so, decrease their place value. We
        are essentially deleting an element from a queue here.
        */
        newUser.parseId { (result) -> Void in
            if !(newUser.errorPresent()) {
                newUser.updateParse({ (result) -> Void in
                    if !(newUser.errorPresent()) {
                        
                        dispatch_async(dispatch_get_main_queue(),{
                            let parseNetwork = ParseNetworkOps(
                                roomId: self.receivedRoomID)
                            
                            parseNetwork.getLobbyMembers { (result) -> Void in
                                parseNetwork.getLobbyCount({ (result) -> Void in
                                    
                                    let objIds = parseNetwork.userObjID()
                                    
                                    for id in objIds {
                                        
                                        if objIds.indexOf(id)! > objIds.indexOf(
                                            self.defaults.stringForKey("objId")!) {
                                                let updateUser = UpdateUser(
                                                    id: id,
                                                    place: objIds.indexOf(id)! ,
                                                    userCount: parseNetwork.userCount())
                                                updateUser.updatePlace({ (result) -> Void in
                                                })
                                        }
                                    }
                                })
                            }
                            self.activity(false)
                            self.performSegueWithIdentifier("roundToLobby", sender: self)
                        })
                    }
                    else {
                        self.activity(false)
                        self.showAlert(newUser.errorText())
                    }
                })
            }
            else {
                self.activity(false)
                self.showAlert(newUser.errorText())
            }
        }
        
    }
    
    @IBAction func changeDrink(sender: AnyObject) {
        var drinkTextField: UITextField?
        let alertController = UIAlertController(
            title: "Change Drink",
            message: "Enter your new drink below.", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Change", style: .Default, handler: { (action) -> Void in
            self.updateDrink(drinkTextField!.text!)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
        }
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            drinkTextField = textField
        }
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func buyRound(sender: AnyObject) {
        activity(true)
        
        let parseNetwork = ParseNetworkOps(roomId: receivedRoomID)
        
        /**
        Similar to leaving the round, here the user who is buying the round
        modifies every else's place (including their own). Again this would
        be done ideally in server side code. Loop around all of the memebers
        of the lobby. Essentially the head of the queue becomes the tail
        and each element shifts by one.
        */
        parseNetwork.getLobbyMembers { (result) -> Void in
            if parseNetwork.errorPresent() {
                self.showAlert(parseNetwork.errorText())
                self.activity(false)
            }
            else {
                parseNetwork.getLobbyCount({ (result) -> Void in
                    
                    if parseNetwork.errorPresent() {
                        self.showAlert(parseNetwork.errorText())
                        self.activity(false)
                    }
                    else {
                        let objIds = parseNetwork.userObjID()
                        let places = parseNetwork.placeArray()
                        
                        var userCount = 0
                        var newPlaceSet = false
                        
                        for id in objIds {
                            let updateUser = UpdateUser(
                                id: id,
                                place: places[objIds.indexOf(id)!],
                                userCount: parseNetwork.userCount())
                            updateUser.updatePlace({ (result) -> Void in
                                if updateUser.errorPresent() {
                                    self.showAlert(updateUser.errorText())
                                }
                                else {
                                    if (objIds.indexOf(id)! == self.defaults.integerForKey("place")) && !newPlaceSet {
                                        self.defaults.setInteger(updateUser.newPlace(), forKey: "place")
                                        newPlaceSet = true
                                    }
                                    userCount = userCount + 1
                                    if userCount == parseNetwork.userCount() {
                                        self.refresh(self)
                                    }
                                }
                            })
                        }
                    }
                    self.activity(false)
                })
            }
        }
    }
    
    /**
     This function saves a new drink to Core DAta.
     */
    private func save(newDrink : String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        do {
            let userObj = objectRetrieve(managedContext, name: defaults.stringForKey("name")!, entity: "User") as! User
            userObj.setValue(newDrink, forKey: "drink")
            try managedContext.save()
        }
        catch {
            showAlert("Error saving to Core Data. Your changes were not saved")
        }
    }
    
    private func activity(start : Bool) {
        dispatch_async(dispatch_get_main_queue(),{
            if start {
                self.activityView.startAnimating()
                self.view.alpha = 0.8
            }
            else {
                self.activityView.stopAnimating()
                self.view.alpha = 1.0
            }
        })
    }
    
}
