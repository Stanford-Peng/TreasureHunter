//
//  ShopViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 11/11/20.
//

import UIKit
import FirebaseFirestore
import MapKit

protocol ShopViewDelegate {
    func configureUserGoldLabel(text: String)
}

class ShopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, ShopViewDelegate {
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var userGoldLabel: UILabel!
    @IBOutlet weak var shopCollectionView: UICollectionView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    
    private let reuseIdentifier = "shopCell"
    private let itemsPerRow: CGFloat = 4
    private let numberOfRow: CGFloat = 10
    var shopItems = [Item]()
    var selectedItem: Item?
    var itemFunctionsController: ItemFunctionsController?
    var db = Firestore.firestore()
    var itemLocationReference = Firestore.firestore().collection("ItemLocation")
    var userItemReference = Firestore.firestore().collection("UserItems")
    var ItemReference = Firestore.firestore().collection("Item")
    var initialGoldAmount = "..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        self.getAllShopItems()
        //get Item functions controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        itemFunctionsController = appDelegate.itemFunctionsController
        itemFunctionsController!.shopViewDelegate = self
    }
    
    @IBAction func buyButton(_ sender: Any) {
        if selectedItem == nil {
            return
        }
        showBuyConfirmation()
    }
    
    func showBuyConfirmation(){
        let alert = UIAlertController(title: "Buy Confirmation", message: "Would you like to buy \(selectedItem!.name!)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Buy", style: UIAlertAction.Style.default, handler: { action in
            self.buyItemTransaction()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func buyItemTransaction(){
        let email=UserDefaults.standard.string(forKey: "useremail")
        let userItemDocReference = userItemReference.document(email!)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.updateData([
                                    self.selectedItem!.name! : FieldValue.increment(Int64(1)),
                                    "Gold" : FieldValue.increment(Int64(-self.selectedItem!.itemShopPrice!))],
                    forDocument: userItemDocReference)
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
    
    private func setUI() {
        descriptionView.backgroundColor = UIColor(patternImage: UIImage(named: "redWood")!)
        
        shopCollectionView.dataSource = self
        shopCollectionView.delegate = self
        shopCollectionView.backgroundColor = .brown
        
        userGoldLabel.textColor = .white
        userGoldLabel.shadowColor = .black
        userGoldLabel.shadowOffset = CGSize(width: 0.7, height: 0.7)
        
        self.buyButton.backgroundColor = UIColor(displayP3Red: 222/255, green: 194/255, blue: 152/255, alpha: 1.0)
        self.buyButton.layer.cornerRadius = 7.0
        self.buyButton.layer.borderWidth = 5.0
        self.buyButton.layer.borderColor = UIColor.clear.cgColor
        self.buyButton.layer.shadowColor = UIColor(displayP3Red: 158/255, green: 122/255, blue: 82/255, alpha: 1.0).cgColor
        self.buyButton.layer.shadowOpacity = 1.0
        self.buyButton.layer.shadowRadius = 2.0
        self.buyButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        configureUserGoldLabel(text: initialGoldAmount)
    }
    
    func getAllShopItems(){
        ItemReference.getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("error getting all existing items: \(err)")
            } else {
                for document in querySnapshot!.documents{
//                    print("\(document.documentID) => \(document.data())")
//                    print("\(document.documentID) => \(document.data()["itemImage"] as! String)")
                    if document.data()["sellsAtShop"] as! Bool {
                        self.shopItems.append(Item(name: document.documentID,
                                                          desc: document.data()["description"] as! String,
                                                          imageIcon: UIImage(named: document.data()["itemImage"] as! String) ?? UIImage(named: "none")!,
                                                          shopPrice: document.data()["shopPrice"] as! Int))
                    }
                }
                self.shopItems.sort{$0.name! < $1.name!}
                self.shopCollectionView.reloadData()
            }
        }
    }
    
    
    func configureUserGoldLabel(text: String) {
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
    
    
    // MARK: Collection View Functions
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ShopCollectionViewCell
        cell.configureBackground(with: "shelf")
        cell.configureItemImage(with: "NO_IMAGE")
        cell.item = Item()
        cell.deselectCell()
        
        if indexPath.row < shopItems.count{
            let itemAtIndex = shopItems[indexPath.row]
            cell.configureItem(with: itemAtIndex)
            cell.configurePrice(with: itemAtIndex)
            cell.isUserInteractionEnabled = true
        } else {
            cell.isUserInteractionEnabled = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ShopCollectionViewCell
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
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ShopCollectionViewCell
        if cell.item!.name != nil{
            cell.deselectCell()
        }
    }
    
    // Collection View Layout
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
