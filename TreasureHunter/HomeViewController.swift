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

protocol HomeViewDelegate{
    func resetDigTimer()
    func showAlert(title: String, message: String)
    func showAlertWithImage(title: String, message: String, imageName: String)
    func getTimer() -> Int
}

//timer reference:
//https://medium.com/ios-os-x-development/build-an-stopwatch-with-swift-3-0-c7040818a10f
class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, HomeViewDelegate{
    func getTimer() -> Int{
        return seconds!
    }
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var functions = Functions.functions()
    var userLocation:CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    var seconds:Int? //This variable will hold a starting value of seconds. It could be any amount above 0.
    var timer = Timer()
    var isTimerRunning = false //This will be used to make sure only one timer is created at a time.
    var canDig: Bool?
    var timerReference = Firestore.firestore().collection("Timer")
    var db = Firestore.firestore()
    var itemLocationReference = Firestore.firestore().collection("ItemLocation")
    var userItemReference = Firestore.firestore().collection("UserItems")
    var ItemReference = Firestore.firestore().collection("Item")
    var allExistingItems: [Item] = []
    
    let COOLDOWN = 50
    var shakeCounter = 0
    let DIGRADIUS:Double = 10
    
    //    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        createSpinnerView()
        setupLabel()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        setUpLocationAuthorisation()
        mapView.delegate = self
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = appDelegate.itemFunctionsController
        vc.homeViewDelegate = self
        getAllExistingItems()
        
        //*** Get seconds from server database and load into SceneDelegate
    }
    
    func setupLabel(){
        // F3D38C primary background color
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
        ])
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
            //            let items=findItems()
            //            for item in items{
            //                showAlert(title: "Found Item: ", message: item.name!)
            //            }
            findItems()
            let email=UserDefaults.standard.string(forKey: "useremail")
            timerReference.document(email!).setData(["lastDigDatetime":Timestamp(date: Date.init())])
            setUpTimer()
            canDig = false
        }
    }
    
    func findItems(){
        var items:[Item] = []
        var locationDocIDs: [String] = []
        functions.httpsCallable("findItems").call(["long":userLocation?.longitude, "lat":userLocation?.latitude]) { (result, error) in
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
            print(result!.data)
            
            let diggedItems = result?.data as! NSArray
            if(diggedItems.count == 0){
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
                    itemsDisplay += "\(item.name!) x \(item.itemCount!)\n"
                }
                self.showAlert(title: "Item found!", message: itemsDisplay)
                self.addToBag(itemList: items, itemDocIDS: locationDocIDs)
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
            showAlert(title: "Found nothing", message: "Bad luck :( You found nothing at this location")
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
                self.showAlert(title: "Found Item!!", message: generatedItem)
            }
        }
    }
    
    func generateRandomItemToMap(){
        
    }
    
    @objc func updateTimer() {
        if seconds! < 1 {
            timeUp()
            
        } else {
            canDig = false
            seconds! -= 1
            timerLabel.text = timeString(time: TimeInterval(seconds!))
        }
    }
    
    func timeUp(){
        timerLabel.text = "You can dig"
        canDig = true
    }
    
    func useWater(){
        
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
            mapView.addOverlay(MKCircle(center:coordinate, radius: DIGRADIUS))
            
            //zoom to region of near 100 meters
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
            mapView.setRegion(region, animated: true)
        }
    }
    func createSpinnerView() {
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // wait two seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
        self.present(alert, animated: true, completion: nil)
    }
}
