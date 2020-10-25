//
//  HomeViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 24/10/20.
//

import UIKit
import MapKit
import FirebaseFirestore
//timer reference:
//https://medium.com/ios-os-x-development/build-an-stopwatch-with-swift-3-0-c7040818a10f
class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var timerLabel: UILabel!
    let locationManager = CLLocationManager()
    var seconds:Int? //This variable will hold a starting value of seconds. It could be any amount above 0.
    var timer = Timer()
    var isTimerRunning = false //This will be used to make sure only one timer is created at a time.
    var canDig: Bool?
    var timerReference = Firestore.firestore().collection("Timer")
    let COOLDOWN = 60
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        locationManager.delegate = self
        let authorisationStatus = locationManager.authorizationStatus
        if authorisationStatus == .notDetermined || authorisationStatus == .denied || authorisationStatus == .restricted{
            locationManager.requestWhenInUseAuthorization()
        }
        //define accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //runTimer()
        
        //*** Get seconds from server database and load into SceneDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        print("view will appear")
//        setUpTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {

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
                //return
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
                
                //self.runTimer()

            }else{
                //user logs in for the first time
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
        if canDig!{
            dig()
        }
        
    }
    
    func dig(){
        //runTimer()
        //*** send time to server
        let email=UserDefaults.standard.string(forKey: "useremail")
        timerReference.document(email!).setData(["lastDigDatetime":Timestamp(date: Date.init())])
        setUpTimer()
        
    }

    @objc func updateTimer() {

//        seconds = appDelegate
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
    
    override func didMove(toParent parent: UIViewController?) {
        print("it works")
        //*** Send seconds to firebase and log out user
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
