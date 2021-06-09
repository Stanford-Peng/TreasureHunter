# TreasureHunter
This is the final assignment for unit FIT5140 Monash University maintained by Shubin Peng and Kang Hsing
Final Application Project Proposal 
Application Concept
Name: Treasure Hunter


## Architecture Diagram:
The Google Serverless Function helps improve the performance of the mobile app by delegating resource-intensive firebase query task to the cloud function.

![architecture](https://github.com/Stanford-Peng/TreasureHunter/blob/main/architecture%20diagram.png)

## About
As Shakespeare once said “The world is your oyster”. In “Treasure Hunter”, you can find exciting little gems scattered around the world, ranging from tools, hints, player-dropped items/messages, gold, and much more to help you on the journey to find the most sought-after treasure of all, THE PEARL OYSTER!
Players who find the Pearl Oyster prize will receive plane tickets and accommodation to travel around the world to 3 different countries. And get recognition in the in-game global leaderboard.
Developer

## Features
Location-based game
Dig to get hints, messages and items dropped by other players, and useful tools to help you find the final prize. 
Earn points to get recognized on the global leaderboard.
Drop messages and items for other users to pick up when they dig
Chat online with other players and friends
Strengths
Completely free to play with no paywalls or pay-to-progress elements
Can be played anywhere without disadvantage
Party system to hunt together
No Ads
Easy and convenient registration with google sign-in
Weaknesses
No augmented reality graphics

![landingPage](https://user-images.githubusercontent.com/48232605/100333473-bcd68d00-3026-11eb-9a53-8430c9066726.png)
![home](https://user-images.githubusercontent.com/48232605/100333524-ccee6c80-3026-11eb-9ee9-382fe3d4e58e.png)

## Target Audience
Suitable for all ages
Suitable for all genders
Suitable for all nationalities and locations

![Chat](https://user-images.githubusercontent.com/48232605/100333562-d7106b00-3026-11eb-8139-81eca2268f47.png)

## Game Rules
Players can dig (shake their phone for 10 seconds) once every 15 minutes (15 minutes dig cooldown)
All players start with 3000 points
Players can buy game items with points
Players can bury messages or tools for other players to dig up

![setting](https://user-images.githubusercontent.com/48232605/100333639-f3140c80-3026-11eb-86ef-639ac1dd17f3.png)

## Game Items
Bottle of water - Instantly remove dig cooldown
Map Pieces - Collect all 6 pieces to get a treasure map or hint to the approximate location of the pearl oyster prize. (Hints are given in any random language)
Metal Detector - Scans in a 100m radius of the user to pinpoint location of high quality treasures.
Oyster Detector - Scans in a 100m radius of the user to detect whether a Pearl Oyster exists.
Normal Oyster - Grants the user 500 points.
Translator - Translates hints to a chosen language

![bag](https://user-images.githubusercontent.com/48232605/100333578-ded00f80-3026-11eb-9533-628d8e53b839.png)
![shop](https://user-images.githubusercontent.com/48232605/100333608-e7c0e100-3026-11eb-8e3e-69918a3c65dd.png)

# Treasure Hunter App Documentation

## Overall Architecture
This game app contains two main tiers:client and firebase server and you can refer to the below diagram: 

The client is, of course, written in swift combined with a storyboard. No local database is used due to the characteristics of this game. All the game data have to be available to all game players so that we use Firebase Cloud Firestore to store all the game related data. As for the data related to user preferences about the app settings, they are not sensitive data and are stored in User Defaults and can be accessed everywhere in the application.

Firebase Cloud Firestore is a document-oriented database, similar to MongoDB. It is schemaless and data should be stored for query-oriented purposes (Inner Join should be avoided). Therefore, the collections in Firebase Cloud Firestore are mostly self-contained and can give the client enough information independently. Below is a screenshot of 8 collections we use in this application:


Apart from using Firebase to store data, we also use its function feature and delegate heavy calculations to the server side. The client just needs to pass a few parameters to call the function and the server will return the client results after heavy calculation. Any needed user data can be directly fetched from Firestore in the deployed function. This way can greatly reduce the memory and CPU burden of client devices, thus providing users with better experience:

## Libraries

From the architecture diagram, you can see all the external libraries we use in the application:'Firebase/Storage', 'Firebase/Core', 'Firebase/Auth',  'Firebase/Firestore', 'FirebaseFirestoreSwift', 'MessageKit', 'FirebaseUI', 'Firebase/Functions', 'SDWebImageWebPCoder'. 

 'Firebase/Core','Firebase/Firestore', 'Firebase/Storage' and 'FirebaseFirestoreSwift' are used to interact with Firebase Cloud Firestore so that the online data can be created, read, updated and deleted. 

'Firebase/Auth' and 'FirebaseUI' are used to configure the logging via third party:Google since almost all users have a Google account. 

'Firebase/Functions' is used to initialize and deploy functions from local to the Firebase server.

'MessageKit' is used to quickly and conveniently build chatting and chatting room features.

'SDWebImageWebPCoder' is used when loading animated images : webp file. Although gif can be loaded into UIImage.animatedImage, gif always comes with background and is detrimental to the user interface. WebP file is a better option but it is not innately supported by Swift. Therefore this library is installed and used.

Apart from these external libraries, built-in libraries such as UIKit, MapKit and CoreLocation are also used and achieve a lot of good features such as detecting shaking device, map navigation and local notifications.

