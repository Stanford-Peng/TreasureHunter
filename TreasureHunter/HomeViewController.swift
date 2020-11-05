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
//timer reference:
//https://medium.com/ios-os-x-development/build-an-stopwatch-with-swift-3-0-c7040818a10f
class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
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
    //var itemLocationReference = Firestore.firestore().collection("ItemLocation")
    
    let COOLDOWN = 10
    var shakeCounter = 0
    let DIGRADIUS:Double = 10
    
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabel()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        setUpLocationAuthorisation()
        mapView.delegate = self
        //locationManager
        //runTimer()
        
        //*** Get seconds from server database and load into SceneDelegate
    }
    
    func setupLabel(){
        // beautify the label
        
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
        timer.invalidate()
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
            self.runTimer()
        }
    }
    
    func isFirstTimeUser(){
        self.seconds = 0
        canDig = true
    }

    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(HomeViewController.updateTimer)), userInfo: nil, repeats: true)
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
        }
    }
    
    func findItems(){
       var callable = functions.httpsCallable("findItems").call([]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
                print(error)
                return
            }
            print(result?.data)
            do{
                let json =  try JSONDecoder().decode([ItemLocation].self, from:result?.data as! Data)
                print(json)
            }catch{

            }

            
            
            
//            if let text = (result?.data as? [String: Any])?

            
            //(result?.data as? [String: Any])?["text"] as? String {
            //self.resultField.text = text
        }
        
//        functions.httpsCallable("findItems").call(["lat": userLocation?.latitude, "long": userLocation?.longitude]) { (result, error) in
//          if let error = error as NSError? {
//            if error.domain == FunctionsErrorDomain {
//              let code = FunctionsErrorCode(rawValue: error.code)
//              let message = error.localizedDescription
//              let details = error.userInfo[FunctionsErrorDetailsKey]
//            }
//            // ...
//          }
////            if let json =  try JSONDecoder().decode([ItemLocation].self, from:result?.data){
////
////            }
//        }
    }

    @objc func updateTimer() {

        if seconds! < 1 {
            timer.invalidate()
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

    func resetTimer(){
        timer.invalidate()
        seconds = 60    //Here we manually enter the restarting point for the seconds, but it would be wiser to make this a variable or constant.
        timerLabel.text = timeString(time: TimeInterval(seconds!))
    }

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

    
}

extension HomeViewController{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
          let circleRenderer = MKCircleRenderer(overlay: overlay)
          circleRenderer.lineWidth = 1.0
          circleRenderer.strokeColor = .purple
          circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.2)
          return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
//extension MKMapView {
//  func zoomToUserLocation() {
//    guard let coordinate = userLocation.location?.coordinate else { return }
//    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
//    setRegion(region, animated: true)
//  }
//}
