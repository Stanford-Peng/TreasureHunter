//
//  BagViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 24/10/20.
//

import UIKit
import FirebaseFirestore
import MapKit

protocol BagViewDelegate{
    func confirmItemUsed()
    func sellItem(forPrice: Int)
}

class BagViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, BagViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row])"
    }
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    //@IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var bagCollectionView: UICollectionView!
    @IBOutlet weak var itemDescriptionView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var useButton: UIButton!
    @IBOutlet weak var dropButton: UIButton!
    @IBOutlet weak var shopButton: UIBarButtonItem!
    @IBOutlet weak var userGoldLabel: UILabel!
    
    private let itemsPerRow: CGFloat = 4
    private let numberOfRow: CGFloat = 10
    // Reference: FIT5140 Lab 7 Material
    private let reuseIdentifier = "bagCell"
    
    var shopViewDelegate: ShopViewDelegate?
    var db = Firestore.firestore()
    var itemLocationReference = Firestore.firestore().collection("ItemLocation")
    var userItemReference = Firestore.firestore().collection("UserItems")
    var ItemReference = Firestore.firestore().collection("Item")
    var userItemArray = [Item]()
    var allExistingItems = [Item]()
    var databaseListener: ListenerRegistration?
    var userLocation: CLLocationCoordinate2D?
    let locationManager =  CLLocationManager()
    var selectedItem: Item?
    var pickerView: UIPickerView!
    var pickerData: [Int]!
    var itemFunctionsController: ItemFunctionsController?
    //    var managedObjectContext: NSManagedObjectContext?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        pickerView = UIPickerView(frame: CGRect(x: 10, y: 50, width: 250, height: 150))
        pickerView.delegate = self
        pickerView.dataSource = self
        self.setUI()
        self.getAllExistingItems()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        itemFunctionsController = appDelegate.itemFunctionsController
        itemFunctionsController!.bagViewDelegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shopSegue" {
            let destination = segue.destination as! ShopViewController
            shopViewDelegate = destination
            destination.initialGoldAmount = userGoldLabel!.text!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start to update user location in real time
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        //Stop updating user location in real time
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func showNumberPicker(){
        // set picker values
        let min = 1
        let max = selectedItem!.itemCount!
        pickerData = Array(stride(from: min, to: max + 1, by: 1))
        pickerView.reloadAllComponents()

        // show number picker
        let ac = UIAlertController(title: "Drop Amount", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        ac.view.addSubview(self.pickerView)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let pickerValue = self.pickerData[self.pickerView.selectedRow(inComponent: 0)]
            self.dropTransaction(dropAmount: pickerValue)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(ac, animated: true)
    }
    
    @IBAction func dropButton(_ sender: Any) {
        if selectedItem == nil {
            return
        }
        // Let user choose amount to drop
        if selectedItem!.itemCount! > 1 {
            showNumberPicker()
        } else {
            // If item count is 1, show confirmation to drop
            showDropConfirmation()
        }
    }
    
    func dropTransaction(dropAmount: Int){
        let amount = dropAmount
        if amount < 1 {
            return
        }
        // transaction to delete item from UserItems and Add to ItemLocation https://firebase.google.com/docs/firestore/manage-data/transactions
        let email=UserDefaults.standard.string(forKey: "useremail")
        let userItemDocReference = userItemReference.document(email!)
        //itemLocationReference
        let itemLocationDoc = self.itemLocationReference.document()
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let dropLocation = GeoPoint(latitude: self.userLocation!.latitude, longitude: self.userLocation!.longitude)
            let dropData = [
                "itemID" : self.selectedItem!.name!,
                "itemCount" : amount,
                "location" : dropLocation
            ] as [String : Any]
            print(dropData)
            
            transaction.setData(dropData, forDocument: itemLocationDoc, merge: true)
            transaction.updateData([self.selectedItem!.name! : self.selectedItem!.itemCount! - amount], forDocument: userItemDocReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                self.selectedItem = nil
                self.descriptionTextView.text = nil
                self.itemTitleLabel.text = nil
            }
        }
    }
    
    func sellItem(forPrice: Int){
        let email=UserDefaults.standard.string(forKey: "useremail")
        let userItemDocReference = userItemReference.document(email!)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.updateData([
                self.selectedItem!.name! : self.selectedItem!.itemCount! - 1,
                "Gold" : FieldValue.increment(Int64(forPrice))
                ], forDocument: userItemDocReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                self.selectedItem = nil
                self.descriptionTextView.text = nil
                self.itemTitleLabel.text = nil
            }
        }
        
    }
    
    //Reference https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
    func showDropConfirmation(){
        let alert = UIAlertController(title: "Drop Confirm", message: "Would you like to drop item at current location?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Drop", style: UIAlertAction.Style.default, handler: { action in
            self.dropTransaction(dropAmount: 1)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showUseConfirmation(){
        let alert = UIAlertController(title: "\(useButton!.currentTitle!) \(selectedItem!.name!)?", message: selectedItem?.desc, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
            self.itemFunctionsController!.use(item: self.selectedItem!)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func useButton(_ sender: Any) {
        if selectedItem == nil {
            return
        }
        showUseConfirmation()
    }
    
    func confirmItemUsed(){
        let email=UserDefaults.standard.string(forKey: "useremail")
        let userItemDocReference = userItemReference.document(email!)
        userItemDocReference.updateData([selectedItem!.name : FieldValue.increment(Int64(-1))])
        
        self.selectedItem = nil
        self.descriptionTextView.text = nil
        self.itemTitleLabel.text = nil
    }

    private func getAllExistingItems(){
        ItemReference.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("error getting all existing items: \(err)")
            } else {
                for document in querySnapshot!.documents{
//                    print("\(document.documentID) => \(document.data())")
//                    print("\(document.documentID) => \(document.data()["itemImage"] as! String)")
                    self.allExistingItems.append(Item(name: document.documentID,
                                                      desc: document.data()["description"] as! String,
                                                      imageIcon: UIImage(named: document.data()["itemImage"] as! String) ?? UIImage(named: "none")!))
                    
                }
                self.userItemListener()
            }
        }
    }
    
    
    
    func userItemListener(){
        let email = UserDefaults.standard.string(forKey: "useremail")
        databaseListener = userItemReference.document(email!).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            self.userItemArray.removeAll()
            let data = querySnapshot?.data()!
            print(data!)
            for (name, count) in data! {
                print(name, count)
                if name == "Gold"{
                    self.configureGoldLabel(text: String(count as! Int))
                    if self.shopViewDelegate != nil {
                        self.shopViewDelegate?.configureUserGoldLabel(text: String(count as! Int))
                    }
                } else {
                    if count as! Int > 0 {
    //                    self.userItemList[name] = count as! Int
                        self.userItemArray.append(Item(name: name, itemCount: count as! Int))
                    }
                }
            }
            self.userItemArray.sort{$0.name! < $1.name!}
            self.bagCollectionView.reloadSections([0])
        }
    }
    
    private func setUI() {
        descriptionView.backgroundColor = UIColor(patternImage: UIImage(named: "blueWood")!)
        // Register cell classes
        //        self.bagCollectionView!.register(BagCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        bagCollectionView.dataSource = self
        bagCollectionView.delegate = self
        bagCollectionView.backgroundColor = .brown
        //8CEBD3
        //let backgroundImageView = UIImageView()
        //backgroundImageView.image = UIImage(named:"background-login")
        //bagCollectionView.backgroundView = backgroundImageView
        
        navigationItem.title = "Bag"
        navigationController?.navigationBar.isTranslucent = true
        
//        navigationController?.navigationBar.barTintColor = UIColor.Custom.darkBlue
//        navigationController?.navigationBar.backgroundColor = UIColor.Custom.darkBlue
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        navigationController?.navigationBar.barStyle = .black
        //        navBar.isTranslucent = false
        //        navBar.barStyle = .black
        
        //Set button UI
        
        self.useButton.backgroundColor = UIColor(displayP3Red: 222/255, green: 194/255, blue: 152/255, alpha: 1.0)
        self.useButton.layer.cornerRadius = 7.0
        self.useButton.layer.borderWidth = 5.0
        self.useButton.layer.borderColor = UIColor.clear.cgColor
        self.useButton.layer.shadowColor = UIColor(displayP3Red: 158/255, green: 122/255, blue: 82/255, alpha: 1.0).cgColor
        self.useButton.layer.shadowOpacity = 1.0
        self.useButton.layer.shadowRadius = 2.0
        self.useButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        self.dropButton.backgroundColor = UIColor(displayP3Red: 222/255, green: 194/255, blue: 152/255, alpha: 1.0)
        self.dropButton.layer.cornerRadius = 7.0
        self.dropButton.layer.borderWidth = 5.0
        self.dropButton.layer.borderColor = UIColor.clear.cgColor
        self.dropButton.layer.shadowColor = UIColor(displayP3Red: 158/255, green: 122/255, blue: 82/255, alpha: 1.0).cgColor
        self.dropButton.layer.shadowOpacity = 1.0
        self.dropButton.layer.shadowRadius = 2.0
        self.dropButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        userGoldLabel.textColor = .white
        userGoldLabel.shadowColor = .black
        userGoldLabel.shadowOffset = CGSize(width: 0.7, height: 0.7)
    }
    
    private func configureGoldLabel(text: String){
        // Create Attachment
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named:"dollar")
        // Set bound to reposition
        let imageOffsetY: CGFloat = -3.0
        imageAttachment.bounds = CGRect(x: -1, y: imageOffsetY, width: 20, height: 20)
        // Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        // Initialize mutable string
        let completeText = NSMutableAttributedString(string: "")
        // Add image to mutable string
        completeText.append(attachmentString)
        // Add your text to mutable string
        let textAfterIcon = NSAttributedString(string: text)
        completeText.append(textAfterIcon)
        self.userGoldLabel.textAlignment = .center
        self.userGoldLabel.attributedText = completeText
    }
    
    //        let appDelegate = UIApplication.shared.delegate as? AppDelegate
    //        managedObjectContext = appDelegate?.persistantContainer?.viewContext
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Register cell classes
    //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    // Do any additional setup after loading the view.
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    
    //    func loadImageData(filename: String) -> UIImage? {
    //        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    //        let documentsDirectory = paths[0]
    //        let imageURL = documentsDirectory.appendingPathComponent(filename)
    //        let image = UIImage(contentsOfFile: imageURL.path)
    //        return image
    //    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BagCollectionViewCell
        cell.backgroundColor = .blue
        cell.configureBackground(with: "shelf")
        cell.configureItemImage(with: "NO_IMAGE")
        cell.itemCountLabel.text = ""
        cell.item = Item()
        cell.deselectCell()
        
        if indexPath.row < userItemArray.count{
            let itemAtIndex = createItem(with: userItemArray[indexPath.row])
            cell.configureItem(with: itemAtIndex)
            cell.item?.itemCount = itemAtIndex.itemCount!
            cell.configureItemCountLabel()
            cell.isUserInteractionEnabled = true
        } else {
            cell.isUserInteractionEnabled = false
        }
        return cell
    }
    
    func createItem(with: Item) -> Item{
        let i = with
        for item in allExistingItems{
            if item.name == i.name{
                i.imageIcon = item.imageIcon
                i.desc = item.desc
                i.dropChance = item.dropChance
            }
        }
        return i
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BagCollectionViewCell
        
        if cell.item!.name != nil{
            
            //Briefly fade the cell on selection
               UIView.animate(withDuration: 0.5,
                              animations: {
                               //Fade-out
                               cell.alpha = 0.5
                            
               }) { (completed) in
                   UIView.animate(withDuration: 0.5,
                                  animations: {
                                   //Fade-out
                                   cell.alpha = 1
                   })
               }
            
            cell.selectCell()
            selectedItem = cell.item
            descriptionTextView.text = cell.item?.desc
            itemTitleLabel.text = cell.item?.name
            if selectedItem!.name!.contains("Map Piece"){
                self.useButton.setTitle("Read", for: .normal)
            } else if selectedItem!.name!.contains("Normal Oyster") || selectedItem!.name!.contains("Large Treasure Chest"){
                self.useButton.setTitle("Sell", for: .normal)
            } else {
                self.useButton.setTitle("Use", for: .normal)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BagCollectionViewCell
        if cell.item!.name != nil{
            cell.deselectCell()
        }
    }
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout
                            collectionViewLayout: UICollectionViewLayout, sizeForItemAt
                                indexPath: IndexPath) -> CGSize {
        
        let itemWidth = (view.frame.width/itemsPerRow)
        let itemHeight = itemWidth
        return CGSize(width: itemWidth, height: itemHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    //MARK: - Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.sorted(by: {$0.timestamp > $1.timestamp}).first {
            let coordinate = location.coordinate
            userLocation = coordinate
        }
    }
}
extension UIColor {
    struct Custom {
        static let Cyan = UIColor(displayP3Red: 140/255, green: 235/255, blue: 211/255, alpha: 1.0)
        static let lightBrown = UIColor(displayP3Red: 243/255, green: 211/255, blue: 140/255, alpha: 1.0)
        static let darkBlue = UIColor(displayP3Red: 27/255, green: 89/255, blue: 157/255, alpha: 1.0)
    }
}

