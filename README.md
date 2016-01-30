# Rounds

## Welcome to Rounds a new way to drink with friends.

## Intro
This project is my submission for the Capstone for the iOS programming with Swift nanodegree program @ Udacity. The point of
this application is to make buying rounds of drinks at bars easier.

## What's Inside
Inside this repo is everything you need to build and run the app in Xcode on the iOS simulator. CocoPods was used
to compile dependancies and the associated Podfile has been committed.

## Running
1. Clone the repo
2. (optional) grab the zipped version from the releases tab
3. Load the project in Xcode using the round.xcworkspace file. Loading any of the project files will not work due to the
Pod dependancies. Speaking of dependancies...


## Dependancies and Other Fun Things
The app relies and/or includes the following 3rd party frameworks/tools.
- Parse (as a BaaS)
- Facebook (for login/auth)

Any keys have been committed with the project to assist the review. 

## Software Tests
Facebook was awesome enough to make some test users for this app. There are 3 tests users that can be used to log into the
app. Their images are kinda boring but they can be changed from the app.

### Will Smith
- Email : will_bovrsby_smith@tfbnw.net 
- Password : password1234

### Scar Jo
- Email : scar_gurxqls_jo@tfbnw.net 
- Password : password1234

### Rick Roll
- Email : rick_ooncjox_roll@tfbnw.net 
- Password : password1234

## Using The App
### Login
The app greets the user with a login screen. Pick any of the three accounts above to login with Facebook.
### Setup
After a successful login, the app will show you the profile picture associted with the app, this can be changed by tapping
the image. The user also prompts for a drink to be used as the default when entering new rooms.
### Lobby
From the lobby the user can either create a new room or join an already existing room.
### Roundtable (heh)
Once in a round the user can see who is in the room and who is up next to buy the round. The user will only have the
"Buy Round" button if they are up in the queue. The user can change their drink at any time. The user can manually
refresh the table if they choose. The table will auto refresh every minute or anytime the view appears (say from a sleep).
If a user leaves the lobby the queue is shifted as needed. Once a round is bought, the queue is also reconfigured. The id
for the room is shown at the top.

This is where having two simulators or a phone and a simualator would be helpful.

## Hardware Tests
The app has been tested on the simulator, an iPhone 6, and an iPad mini.
