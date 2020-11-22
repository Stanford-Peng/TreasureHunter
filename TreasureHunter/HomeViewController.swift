//
//  HomeViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 24/10/20.
//

import UIKit
import MapKit
import FirebaseFirestore
import FirebaseFunctions
import SDWebImage

protocol HomeViewDelegate{
    func resetDigTimer()
    func showAlert(title: String, message: String)
    func showAlertWithImage(title: String, message: String, imageName: String)
    func getTimer() -> Int
    func increaseDigRadius(by: Double)
    func getDigRadius() -> Double
    func showToast(message: String, font: UIFont)
}

//timer reference:
//https://medium.com/ios-os-x-development/build-an-stopwatch-with-swift-3-0-c7040818a10f

//https://docs.mapbox.com/help/tutorials/ios-navigation-sdk/#generate-a-route
class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, HomeViewDelegate{
    func getTimer() -> Int{
        return seconds!
    }
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var functions = Functions.functions()
    var userLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    var seconds:Int? //This variable will hold a starting value of seconds. It could be any amount above 0.
    var timer = Timer()
    var isTimerRunning = false //This will be used to make sure only one timer is created at a time.
    var canDig: Bool?
    var timerReference = Firestore.firestore().collection("Timer")
    var db = Firestore.firestore()
    var itemLocationReference = Firestore.firestore().collection("ItemLocation")
    var userItemReference = Firestore.firestore().collection("UserItems")
    var userReference = Firestore.firestore().collection("User")
    var ItemReference = Firestore.firestore().collection("Item")
    var allExistingItems: [Item] = []
    
    let COOLDOWN = 20
    var shakeCounter = 0
    var digradius = 10.0
    let DEFAULT_DIG_RADIUS = 10.0
    
    var step:Int?
    
    let strokeTextAttributes = [
      NSAttributedString.Key.strokeColor : UIColor.black,
      NSAttributedString.Key.foregroundColor : UIColor.white,
      NSAttributedString.Key.strokeWidth : -2.0,
        NSAttributedString.Key.font : UIFont.monospacedSystemFont(ofSize: 19, weight: UIFont.Weight(rawValue: 20.0))]
      as [NSAttributedString.Key : Any]
    let child = SpinnerViewController()
    @IBOutlet weak var hintButton: UIButton!
    //    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var hasPearl = false
    override func viewDidLoad() {
        super.viewDidLoad()
        createSpinnerView()
        setupTimerLabel(text: "Loading Dig Status")
        configureUI()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        setUpLocationAuthorisation()

        mapView.delegate = self
        setUserMapPreference()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = appDelegate.itemFunctionsController
        vc.homeViewDelegate = self
        getAllExistingItems()
        
        //*** Get seconds from server database and load into SceneDelegate
        //start annotation
       
//        step = 0
//        addAnnotations(sender: nil)
    }
    
    @objc func addAnnotations(sender:Any?){
        switch step{
            case 0:
                let label1 = UILabel(frame: CGRect(x: self.view.frame.width/2 , y: self.view.frame.height/2, width: 224, height: 30))
                
                //let label = UILabel(frame: CGRect(x: 64 , y: 32, width: 200, height: 30))
                label1.numberOfLines = 5
                label1.lineBreakMode = .byWordWrapping
                label1.text = "Welcome to Treasure Hunter! Tap me to start tutorial"
                label1.textColor = .blue
                label1.textAlignment = .center
                label1.sizeToFit()
                label1.center = CGPoint(x: self.view.frame.width/2 , y: self.view.frame.height/2)
                step = step! + 1
                label1.fadeIn(0.5, delay: 0) { (bool) in
                    let labelTapGesture = UITapGestureRecognizer(target:self,action:#selector(self.addAnnotations(sender:)))
                    label1.isUserInteractionEnabled = true
                    label1.addGestureRecognizer(labelTapGesture)
                    self.view.addSubview(label1)
                }
                //addAnnotationView(view:label1,step:nextStep)
                //addAnnotations(step: step)
                //addAnnotationView(view: UIView, step: Int)
                break
            case 1:
                if let gesture = sender as? UITapGestureRecognizer{
                    let viewToBeRemoved = gesture.view!
                    viewToBeRemoved.fadeOut(1, delay: 0) { (bool) in
                        viewToBeRemoved.removeFromSuperview()
                    }
                }
                let label2 = UILabel(frame: CGRect(x: 64 , y: 32, width: 320, height: 30))
                
                label2.numberOfLines = 5
                label2.lineBreakMode = .byWordWrapping
                label2.text = "The below Label shows you whether you can dig! You need to shake three times in a row to dig."
                label2.textColor = .blue
                label2.textAlignment = .center
                label2.sizeToFit()
                label2.center = CGPoint(x: self.view.frame.width/2 , y: self.view.frame.height - 176)
                step = step! + 1
                label2.fadeIn(0.5, delay: 0) { (bool) in

                    let labelTapGesture = UITapGestureRecognizer(target:self,action:#selector(self.addAnnotations(sender:)))
                    label2.isUserInteractionEnabled = true
                    label2.addGestureRecognizer(labelTapGesture)
                    self.view.addSubview(label2)
                }
                //addAnnotations(step: step)
                //addAnnotationView(view:label2,step:nextStep)
                break
            case 2:
                if let gesture = sender as? UITapGestureRecognizer{
                    let viewToBeRemoved = gesture.view!
                    viewToBeRemoved.fadeOut(1, delay: 0) { (bool) in
                        viewToBeRemoved.removeFromSuperview()
                    }
                }
                let label3 = UILabel(frame: CGRect(x: 144 , y: 32, width: 224, height: 30))

                label3.numberOfLines = 5
                label3.lineBreakMode = .byWordWrapping
                label3.text = "<- This button show can always show you the last after-digging hint! Use it wisely! Tap me to end this tutorial!"
                label3.textColor = .blue
                label3.textAlignment = .center
                label3.sizeToFit()
                step = step! + 1
                label3.fadeIn(0.5, delay: 0) { (bool) in
                    let labelTapGesture = UITapGestureRecognizer(target:self,action:#selector(self.addAnnotations(sender:)))
                    label3.isUserInteractionEnabled = true
                    label3.addGestureRecognizer(labelTapGesture)
                    self.view.addSubview(label3)
                }
                //addAnnotations(step: step)
                //addAnnotationView(view:label3,step:nextStep)
                break
            default:
                if let gesture = sender as? UITapGestureRecognizer{
                    let viewToBeRemoved = gesture.view!
                    viewToBeRemoved.fadeOut(1, delay: 0) { (bool) in
                        viewToBeRemoved.removeFromSuperview()
                    }
                }
                //self.removeSpinner(child: child)
                break
        }
    }
        
    @objc func tappedTest(){
        print("Label tapped")
    }
//    func addAnnotationView(view:UIView, step:Int){
//        view.fadeIn(0.5, delay: 0) { (bool) in
//            self.view.addSubview(view)
//            let labelTapGesture = UITapGestureRecognizer(target:self,action:#selector(self.addAnnotations(step:step, viewToBeRemoved:view)))
//            view.addGestureRecognizer(labelTapGesture)
//        }
////            view.fadeOut(2, delay: 5) { (bool) in
////                view.removeFromSuperview()
////                self.addAnnotations(step: step)
////            }
//
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUserMapPreference()
    }
    
    func setUserMapPreference(){
        let userMapType = UserDefaults.standard.string(forKey: "mapType")
        if userMapType == "hybrid" {
            mapView.mapType = MKMapType.hybridFlyover
        } else {
            mapView.mapType = MKMapType.standard
        }
    }
    
    func configureUI(){
        self.hintButton.backgroundColor = UIColor(displayP3Red: 222/255, green: 194/255, blue: 152/255, alpha: 1.0)
        self.hintButton.layer.cornerRadius = 7.0
        self.hintButton.layer.borderWidth = 5.0
        self.hintButton.layer.borderColor = UIColor.clear.cgColor
        self.hintButton.layer.shadowColor = UIColor(displayP3Red: 158/255, green: 122/255, blue: 82/255, alpha: 1.0).cgColor
        self.hintButton.layer.shadowOpacity = 1.0
        self.hintButton.layer.shadowRadius = 2.0
        self.hintButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        //tutorial begins if showTutorial key is true
        if UserDefaults.standard.string(forKey: "showTutorial") == "true"{
            step = 0
            addAnnotations(sender: nil)
        }
    }
    
    func setupTimerLabel(text: String){
        // F3D38C primary background color
        timerLabel.attributedText = NSMutableAttributedString(string: text, attributes: strokeTextAttributes)
    }
    
    func getDigRadius() -> Double {
        return digradius
    }
    
    func resetDigTimer() {
        // Function called by bottle of water
        print("reset timer function called")
        let email=UserDefaults.standard.string(forKey: "useremail")
        timerReference.document(email!).setData(["lastDigDatetime":Timestamp(date: Date.init(timeIntervalSince1970: 0))])
        self.seconds = 0
        canDig = true
        self.timer.invalidate()
        setUpTimer()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake{
            print("SHAKED")
            shakeCounter+=1
        }
        if (shakeCounter > 5){
            shakeCounter = 0
            dig()
        }
    }
    
    func setUpLocationAuthorisation(){
        locationManager.delegate = self
        let authorisationStatus = locationManager.authorizationStatus
        if authorisationStatus == .notDetermined || authorisationStatus == .denied || authorisationStatus == .restricted{
            locationManager.requestWhenInUseAuthorization()
        }
        //define accuracy to best
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("HOME view appeared")
        setUpTimer()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        shakeCounter = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    @objc func appMovedToForeground() {
        print("App moved to ForeGround!")
        setUpTimer()
    }
    
    func setUpTimer(){
        //timer.invalidate()
        let email=UserDefaults.standard.string(forKey: "useremail")
        let userTimer = timerReference.document(email!)
        userTimer.getDocument { (document, error) in
            if let error = error{
                print(error)
                return
            }
            if let document = document, document.exists {
                
                let lastDigDatetime = document.get("lastDigDatetime") as! Timestamp
                let now = Timestamp(date: Date.init())
                let difference = now.seconds - lastDigDatetime.seconds
                //set seconds properly
                if difference < self.COOLDOWN {
                    self.seconds = self.COOLDOWN - Int(difference)
                }else{
                    self.seconds = 0
                    self.canDig = true
                }
            } else{
                self.isFirstTimeUser()
            }
            self.timer.invalidate()
            self.runTimer()
        }
    }
    
    func increaseDigRadius(by: Double){
        digradius = DEFAULT_DIG_RADIUS
        digradius += by
    }
    
    func isFirstTimeUser(){
        // Set up user timer
        let email=UserDefaults.standard.string(forKey: "useremail")
        timerReference.document(email!).setData(["lastDigDatetime":Timestamp(date: Date.init(timeIntervalSince1970: 0))])
        self.seconds = 0
        canDig = true
        // Initialize user bag with all items set to 0
        let userItemData = self.userItemReference.document(email!).setData([
            "Bottle Of Water" : 3,
            "Normal Oyster": 1,
            "Pearl Oyster": 0,
            "Map Piece 1": 0,
            "Map Piece 2": 0,
            "Map Piece 3": 0,
            "Map Piece 4": 0,
            "Map Piece 5": 0,
            "Map Piece 6": 0,
            "Large Treasure Chest": 0,
            "Gold": 300
        ])
        
        //tutorial begins when the user is first logging in
        step = 0
        addAnnotations(sender: nil)
        UserDefaults.standard.set("false", forKey: "showTutorial")
    }
    
    func runTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(HomeViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    //convert into shaking
    @IBAction func testDig(_ sender: Any) {
        dig()
    }
    
    func dig(){
        if canDig! {
            findItems()
            let email=UserDefaults.standard.string(forKey: "useremail")
            timerReference.document(email!).setData(["lastDigDatetime":Timestamp(date: Date.init())])
            setUpTimer()
            canDig = false
        } else {
            showAlert(title: "Cannot dig yet", message: "You cannot dig yet!")
        }
    }
    
    func findItems(){
        var items:[Item] = []
        var locationDocIDs: [String] = []
        
//        //add loading animation
//        let diggingGif = UIImage.gif(name: "digging")
//        let diggingView = UIImageView(image: diggingGif)
        
        let diggingView = UIImageView()
//        diggingView.loadGif(name: "digging")

        diggingView.contentMode = .scaleAspectFit
        diggingView.frame.size.width = 200
        diggingView.frame.size.height = 200
        diggingView.center = self.view.center
//        self.view.addSubview(diggingView)
        self.view.addSubview(diggingView)
        diggingView.fadeIn(0.5, delay: 0) { (bool) in
//            self.view.addSubview(diggingView)
//            print(Bundle.main.bundlePath)
//            print(Bundle.main.bundleURL)
//            let filepath = Bundle.url(forResource: "dig", withExtension: "webp", subdirectory: nil, in: URL)
//            guard let localFileUrl1 = Bundle.main.path(forResource: "dig", ofType: "webp") else{
//
//                print("cannot find the webp file")
//                return
//            }
//
//            print(localFileUrl)
//            print(localFileUrl1)
//            print(Bundle.main.url(forResource: "dig", withExtension: "webp"))
//            print(Bundle.main.path(forResource: "dig", ofType: "webp"))
            guard let localFileUrl = Bundle.main.url(forResource: "dig", withExtension: "webp") else{
                print("cannot find the webp file")
                return
            }

            
            //reference add unrecognized static file : https://rambo.codes/posts/2018-10-03-unleashing-the-power-of-asset-catalogs-and-bundles-on-ios
            DispatchQueue.main.async {
                diggingView.sd_setImage(with: localFileUrl)
                //diggingView.sd_setImage(with: URL(string: "https://im3.ezgif.com/tmp/ezgif-3-6865b0a6bda9.webp"), completed: nil)
            }
        }
        
        
        functions.httpsCallable("findItems").call(["radius": digradius, "long":userLocation?.longitude, "lat":userLocation?.latitude]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
                print(error)
                return
            }
            self.digradius = self.DEFAULT_DIG_RADIUS
            //reset digRadius overlay
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(MKCircle(center:self.userLocation!, radius: self.digradius))
            
            let diggedItems = result?.data as! NSArray
            if(diggedItems.count == 0){
                //ending animation
                //diggingView.removeFromSuperview()
//                diggingView.fadeOut(1, delay: 0) { (bool) in
//                    diggingView.removeFromSuperview()
//                }
                self.generateRandomItemToBag()
            }else{
                for item in diggedItems{
                    let parsed = item as! NSDictionary
                    print(parsed)
                    let ids = parsed["id"] as! [String]
                    locationDocIDs += ids
                    items.append(Item(name: parsed["itemID"] as! String, itemCount: parsed["itemCount"] as! Int))
                }
                var itemsDisplay = "\n"
                for item in items {
                    if item.name == "Pearl Oyster"{
                        self.hasPearl = true
                    }
                    itemsDisplay += "\(item.name!) x \(item.itemCount!)\n"
                }
                
               
//                diggingView.fadeOut(1, delay: 0) { (bool) in
//                    diggingView.removeFromSuperview()
//                }
//                let closure = {
//                    self.generateRandomItemToMap()
//                }
                //ending animation
                //diggingView.removeFromSuperview()
                
                self.showAlertWithCompletion(title: "Item found!", message: itemsDisplay, completion: self.generateRandomItemToMap)
                self.addToBag(itemList: items, itemDocIDS: locationDocIDs)
            }
            diggingView.fadeOut(1, delay: 0) { (bool) in
                    diggingView.removeFromSuperview()
                
                //if there is pearl oyster, show an animation:
                if self.hasPearl == true{
                        self.showPearlOyster()
                    }
            }
        }
    }
    
    func showPearlOyster(){
//        let concurrentQueue = DispatchQueue(label: "treasureHunter.concurrent.queue", attributes: .concurrent)
        let pearlOysterView = UIImageView()
        let backgroundView = UIImageView()
        backgroundView.contentMode = .scaleAspectFit
        backgroundView.frame.size.width = self.view.frame.width
        backgroundView.frame.size.height = self.view.frame.height
        backgroundView.center = self.view.center
        
        pearlOysterView.contentMode = .scaleAspectFit
        pearlOysterView.frame.size.width = 200
        pearlOysterView.frame.size.height = 200
        pearlOysterView.center = self.view.center
        
        backgroundView.fadeIn(0.5, delay: 0) { (bool) in
            guard let localFileUrl = Bundle.main.url(forResource: "pearlOyster", withExtension: "webp") else{
                print("cannot find the webp file")
                return
            }
            guard let backgroundFileUrl = Bundle.main.url(forResource: "sparkle1", withExtension: "webp") else{
                print("cannot find the webp file")
                return
            }
            DispatchQueue.main.async {
                backgroundView.sd_setImage(with: backgroundFileUrl) { (image, error, cacheType, url) in
                    pearlOysterView.sd_setImage(with: localFileUrl) { (image, error, cacheType, url) in
                        self.view.addSubview(pearlOysterView)
                        self.view.addSubview(backgroundView)
                        pearlOysterView.fadeOut(0.5, delay:5){ (bool) in
                            pearlOysterView.removeFromSuperview()
                            backgroundView.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }

    func addToBag(itemList: [Item], itemDocIDS: [String]){
                let email=UserDefaults.standard.string(forKey: "useremail")
        let userItemDocReference = userItemReference.document(email!)
        
        //Batch Write https://firebase.google.com/docs/firestore/manage-data/transactions#batched-writes
        let batch = db.batch()
        // Delete Item Location Documents
        for id in itemDocIDS {
            let docRef = itemLocationReference.document(id)
            batch.deleteDocument(docRef)
        }
        // Add Items to User Bag
        for item in itemList {
            batch.updateData([item.name! : FieldValue.increment(Int64(item.itemCount!))], forDocument: userItemDocReference)
        }
        // Commit Batch Operation
        batch.commit() {err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
                self.increaseUserDigCount()
            }
        }
        // transaction to delete item from itemLocation and add it to userItems https://firebase.google.com/docs/firestore/manage-data/transactions
//        db.runTransaction({ (transaction, errorPointer) -> Any? in
//            transaction.deleteDocument(itemLocationDocReference)
//            transaction.updateData([itemName : FieldValue.increment(Int64(1))], forDocument: userItemDocReference)
//            return nil
//        }) { (object, error) in
//            if let error = error {
//                print("Transaction failed: \(error)")
//            } else {
//                print("Transaction successfully committed!")
//            }
//        }
    }
    
    private func getAllExistingItems(){
        ItemReference.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("error getting all existing items: \(err)")
            } else {
                for document in querySnapshot!.documents{
                    print("\(document.documentID) => \(document.data())")
                    print("\(document.documentID) => \(document.data()["itemImage"] as! String)")
                    self.allExistingItems.append(Item(name: document.documentID,
                                                      desc: document.data()["description"] as! String,
                                                      imageIcon: UIImage(named: document.data()["itemImage"] as! String) ?? UIImage(named: "none")!,
                                                      dropChance: (document.data()["dropChance"] as! Int)))
                }
            }
        }
    }

    func generateRandomItemToBag(){
        // Generate item here
        var totalDropChance = 0
        for item in allExistingItems{
            totalDropChance += item.dropChance!
        }
        var generatedItem = ""
        var randomInt = Int.random(in: 0..<totalDropChance)
        allExistingItems.shuffle()
        
        for item in allExistingItems{
            randomInt -= item.dropChance!
            if randomInt <= 0 {
                generatedItem = item.name!
                print("Generated item: \(item.name!)")
                break
            }
        }
        if generatedItem == "Nothing"{
            showAlertWithCompletion(title: "Found nothing", message: "Bad luck :( You found nothing at this location", completion: self.generateRandomItemToMap)
            return
        }
        
        // Add generated Item to Bag
        let email=UserDefaults.standard.string(forKey: "useremail")
        let userItemDocReference = userItemReference.document(email!)
        userItemDocReference.updateData([
            generatedItem: FieldValue.increment(Int64(1))
        ]) {err in
            if let err = err {
                print("Error adding generated item to bag: \(err)")
            } else {
                print("Added generated item to bag")
                self.increaseUserDigCount()
                self.showAlertWithCompletion(title: "Found Item!!", message: generatedItem, completion: self.generateRandomItemToMap)
            }
        }
    }
    
    func increaseUserDigCount(){
        let email = UserDefaults.standard.string(forKey: "useremail")
        userReference.document(email!).updateData([
            "digCount" : FieldValue.increment(Int64(1))
        ]) { err in
            if let err = err {
                print ("error updating dig count \(err)")
            }
        }
    }
    
    @IBAction func stashedHintTapped(_ sender: Any) {
        let email=UserDefaults.standard.string(forKey: "useremail")
        let userPosition = CLLocation(latitude: userLocation!.latitude, longitude: userLocation!.longitude)
        itemLocationReference.document(email!).getDocument { (document, error) in
            if let error = error{
                print(error)
                return
            }
            if let document = document, document.exists{
                let coordinate = document.get("location") as! GeoPoint
                let itemLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let distance = userPosition.distance(from: itemLocation)
                if distance > 3000{
//                    exist = false
                    self.showLocationWithNavigation(title: "The hint left from last digging", message: "Item \(document.get("itemID")!) is around \(Int(distance)) meters away from you and kind of far away from you. You can try digging to get a new closer hint within 3 KM", coordinate: itemLocation.coordinate)
                } else{
//                    exist = true
                    //self.showAlert(title: "new item", message: "Item \(document.get("name")!) is only around \(Int(distance)) meters away from you")
                    self.showLocationWithNavigation(title: "The hint left from last digging", message: "Item \(document.get("itemID")!) is only around \(Int(distance)) meters away from you", coordinate: itemLocation.coordinate)
                    
                }
                print(itemLocation)
            } else{
                self.showAlert(title: "No Stashed hint.", message: "Sorry,you don't have any stashed hint and you can try to dig and get a new hint.")
            }
        }
    }
    
    
    func generateRandomItemToMap(){
        if self.hasPearl == true{
            self.hasPearl = false
            return
        }
        let randonLocationGenerator = RandomLocationGenerator()
        
        let locations = try? randonLocationGenerator.getMockLocationsFor(location: userLocation!, count: 1, minDistanceKM: 1, maxDistanceKM: 3)
        
        var goodItemList:[Item] = [Item]()
        var exist = false
        let userPosition = CLLocation(latitude: userLocation!.latitude, longitude: userLocation!.longitude)
        for item in allExistingItems {
            if item.dropChance == 1 {
                goodItemList.append(item)
            }
        }
        let email=UserDefaults.standard.string(forKey: "useremail")
        itemLocationReference.document(email!).getDocument { (document, error) in
            if let error = error{
                print(error)
                return
            }
            
            if let document = document, document.exists{
                let coordinate = document.get("location") as! GeoPoint
                let itemLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let distance = userPosition.distance(from: itemLocation)
                if distance > 3000{
                    exist = false
                } else{
                    exist = true
                    //self.showAlert(title: "new item", message: "Item \(document.get("name")!) is only around \(Int(distance)) meters away from you")
                    self.showLocationWithNavigation(title: "Go to Next Item", message: "Item \(document.get("itemID")!) is only around \(Int(distance)) meters away from you", coordinate: itemLocation.coordinate)
                    
                }
                print(itemLocation)
            }
            if !exist {
                for location in locations! {
                    let distance = userPosition.distance(from: location)
                    let slice = Int.random(in: 0 ..< goodItemList.count)
                    let generatedItem = goodItemList[slice]
                    print(generatedItem)
                    print("Item is \(distance) meters away from you")
                    
                    self.itemLocationReference.document(email!).setData([
                        "itemID":generatedItem.name!,
                        "itemCount":1,
                        "location":GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    ]) { (error) in
                        if let error = error{
                            print(error)
                            return
                        }
                        //self.showAlert(title: "new item", message: "Item \(generatedItem.name!) is only around \(Int(distance)) meters away from you")
                        self.showLocationWithNavigation(title: "Go to Next Item", message: "Item \(generatedItem.name!) is only around \(Int(distance)) meters away from you", coordinate: location.coordinate)
                    }
                }
            }
        }

        
    }
    // reference using url : https://stackoverflow.com/questions/38250397/open-an-alert-asking-to-choose-app-to-open-map-with/60930491#60930491
    func showLocationWithNavigation(title:String, message:String, coordinate:CLLocationCoordinate2D ){
        let alert = UIAlertController(title: title, message:
                                        message, preferredStyle:
                                            UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style:
                                        UIAlertAction.Style.cancel, handler: nil))
        let navigateAction = UIAlertAction(title : "Route", style:UIAlertAction.Style.default) { (action) in
        let placeMark = MKPlacemark(coordinate: coordinate)
        print(coordinate)
        let mapItem = MKMapItem(placemark: placeMark)
            mapItem.name = "Next Item Location"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
        }
        alert.addAction(navigateAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func updateTimer() {
        if seconds! < 1 {
            timeUp()
            
        } else {
            canDig = false
            seconds! -= 1
            setupTimerLabel(text: timeString(time: TimeInterval(seconds!)))
        }
    }
    
    func timeUp(){
        self.timer.invalidate()
        setupTimerLabel(text: "Shake to dig")
        canDig = true
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("CanDig"), object: SceneDelegate.self)
        print("Notifying")
    }
    
    //    func resetTimer(){
    //        timer.invalidate()
    //        seconds = 60    //Here we manually enter the restarting point for the seconds, but it would be wiser to make this a variable or constant.
    //        timerLabel.text = timeString(time: TimeInterval(seconds!))
    //    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK : Location manager delegate
    //update to latest location and zoom to it
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.sorted(by: {$0.timestamp > $1.timestamp}).first {
            let coordinate = location.coordinate
            
            userLocation = coordinate
            //clear overlays
            mapView.removeOverlays(mapView.overlays)
            //add dig circle
            mapView.addOverlay(MKCircle(center:coordinate, radius: digradius))
            
            //zoom to region of near 100 meters
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
            mapView.setRegion(region, animated: true)
            //mapView.
        }
    }
    
    func createSpinnerView() {


        // add the spinner view controller
        addChild(child)
        child.view.frame = self.view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        removeSpinner(child: child)
        // wait two seconds to simulate some work happening

    }
    
    func removeSpinner(child:SpinnerViewController){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    
}

extension HomeViewController{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .blue
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.2)
            print(circleRenderer.circle.radius)
            print(circleRenderer)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension UIViewController{
    // Shows alert
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message:
                                        message, preferredStyle:
                                            UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style:
                                        UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithImage(title: String, message: String, imageName: String){
        let imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 40, height: 40))
        imageView.image = UIImage(named: imageName)
        let alert = UIAlertController(title: title, message:
                                        message, preferredStyle:
                                            UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style:
                                        UIAlertAction.Style.default, handler: nil))
        alert.view.addSubview(imageView)
        self.present(alert, animated: true, completion:nil)
    }
    
    func showAlertWithCompletion(title: String, message: String, completion:@escaping () -> Void){
        let alert = UIAlertController(title: title, message:
                                        message, preferredStyle:
                                            UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style:
                                        UIAlertAction.Style.default,handler: { (UIAlertAction) in
                                            completion()
                                        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Shows toast message. Reference: https://stackoverflow.com/questions/31540375/how-to-toast-message-in-swift
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-112, width: self.view.frame.size.width - 32, height: 35))
        
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.numberOfLines = 5
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.sizeToFit()
        toastLabel.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-112)
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.0, delay: 4.0, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
extension HomeViewController{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
          return
        }

        manager.requestLocation()
    }


    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Error requesting location: \(error.localizedDescription)")
    }
}

extension UIView {

    func fadeIn(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
    }, completion: completion)
        
    }

    func fadeOut(_ duration: TimeInterval = 0.5, delay: TimeInterval = 5, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.3
    }, completion: completion)
   }
}
