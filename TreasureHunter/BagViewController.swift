//
//  BagViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 24/10/20.
//

import UIKit
import FirebaseFirestore

class BagViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var bagCollectionView: UICollectionView!
    @IBOutlet weak var itemDescriptionView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
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
    
//    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userItemList.removeAll()
        self.getAllExistingItems()
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
                self.fillBag()
            }
        }
    }
    
    private func fillBag(){
        let email=UserDefaults.standard.string(forKey: "useremail")
        let userItemDocReference = userItemReference.document(email!)
        userItemList.removeAll()
        
        userItemDocReference.getDocument { (document, error) in
            if let error = error{
                print(error)
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                for (name, count) in data! {
                    if count as! Int > 0 {
                        self.userItemList[name] = count as! Int
                    }
                }
            } else{
                
            }
            self.bagCollectionView.reloadSections([0])
        }
    }
    
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
        
        if indexPath.row < userItemList.keys.count{
            let key = Array(userItemList.keys)[indexPath.row]
            cell.configureItem(with: itemNamed(name: key)!)
            cell.item?.itemCount = userItemList[key]!
        }
        // Configure the cell
        //cell.backgroundColor = .secondarySystemFill
//        cell.imageView.image = imageList[indexPath.row]
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
        descriptionTextView.text = cell.item?.desc
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
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
