//
//  BagViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 24/10/20.
//

import UIKit
import FirebaseFirestore

class BagViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var bagCollectionView: UICollectionView!
    @IBOutlet weak var itemDescriptionView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var useButton: UIButton!
    @IBOutlet weak var dropButton: UIButton!
    
    private let itemsPerRow: CGFloat = 4
    private let numberOfRow: CGFloat = 10
    // Reference: FIT5140 Lab 7 Material
    private let reuseIdentifier = "bagCell"
    
    var db = Firestore.firestore()
    var itemLocationReference = Firestore.firestore().collection("ItemLocation")
    var userItemReference = Firestore.firestore().collection("UserItems")
    var ItemReference = Firestore.firestore().collection("Item")
    var userItemList = [String: Int]()
    var allExistingItems = [Item]()
    var databaseListener: ListenerRegistration?
    
    //    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        self.getAllExistingItems()
        print("View did load")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userItemList.removeAll()
        print("view will appear")
    }
    
    @IBAction func dropButton(_ sender: Any) {
        
    }
    
    @IBAction func useButton(_ sender: Any) {
        
    }
    //
    //    func getImageNameFrom(name: String) -> String{
    //        // IMPORTANT Function to match item name with asset images
    //        var imageName: String?
    //        switch name {
    //        case "Bottle Of Water":
    //            imageName = "waterBottle"
    //        case "Normal Oyster":
    //            imageName = "normalOyster"
    //        default:
    //            print("No image found for \(name)")
    //        }
    //        return imageName!
    //    }
    //
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
                                                      imageIcon: UIImage(named: document.data()["itemImage"] as! String)!))
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
            self.userItemList.removeAll()
            let data = querySnapshot?.data()!
            print(data!)
            for (name, count) in data! {
                print(name, count)
                if count as! Int > 0 {
                    self.userItemList[name] = count as! Int
                }
            }
            self.bagCollectionView.reloadSections([0])
        }
    }
    
//    private func userItemListener(){
//        let email=UserDefaults.standard.string(forKey: "useremail")
//        let userItemDocReference = userItemReference.document(email!)
//        userItemList.removeAll()
//
//        userItemDocReference.getDocument { (document, error) in
//            if let error = error{
//                print(error)
//                return
//            }
//            if let document = document, document.exists {
//                let data = document.data()
//                for (name, count) in data! {
//                    if count as! Int > 0 {
//                        self.userItemList[name] = count as! Int
//                    }
//                }
//            } else{
//
//            }
//            self.bagCollectionView.reloadSections([0])
//        }
//    }
    
    private func setUI() {
        // Register cell classes
        //        self.bagCollectionView!.register(BagCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        bagCollectionView.dataSource = self
        bagCollectionView.delegate = self
        bagCollectionView.backgroundColor = UIColor.Custom.Cyan
        //8CEBD3
        //let backgroundImageView = UIImageView()
        //backgroundImageView.image = UIImage(named:"background-login")
        //bagCollectionView.backgroundView = backgroundImageView
        
        navBar.tintColor = UIColor.Custom.Cyan
        navBar.barTintColor = UIColor.Custom.Cyan
        navBar.prefersLargeTitles = true
        navBar.isTranslucent = false
        navBar.barStyle = .black
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
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BagCollectionViewCell
        cell.backgroundColor = .blue
        cell.configureBackground(with: "shelf")
        cell.configureItemImage(with: "NO_IMAGE")
        cell.itemCountLabel.text = ""
        cell.item = Item()
        cell.deselectCell()
        
        if indexPath.row < userItemList.keys.count{
            let key = Array(userItemList.keys)[indexPath.row]
            cell.configureItem(with: itemNamed(name: key)!)
            cell.item?.itemCount = userItemList[key]!
            cell.configureItemCountLabel()
            cell.isUserInteractionEnabled = true
        } else {
            cell.isUserInteractionEnabled = false
        }
        return cell
    }
    
    func itemNamed(name: String) -> Item?{
        for i in allExistingItems{
            if name == i.name{
                return i
            }
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BagCollectionViewCell
        
        if cell.item!.name != nil{
            cell.selectCell()
            descriptionTextView.text = cell.item?.desc
            itemTitleLabel.text = cell.item?.name
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
}
extension UIColor {
    struct Custom {
        static let Cyan = UIColor(displayP3Red: 140/255, green: 235/255, blue: 211/255, alpha: 1.0)
        static let lightBrown = UIColor(displayP3Red: 243/255, green: 211/255, blue: 140/255, alpha: 1.0)
    }
}
