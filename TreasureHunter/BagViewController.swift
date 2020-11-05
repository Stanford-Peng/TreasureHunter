//
//  BagViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 24/10/20.
//

import UIKit

class BagViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var bagCollectionView: UICollectionView!
    
    private let itemsPerRow: CGFloat = 4
    private let numberOfRow: CGFloat = 10
    // Reference: FIT5140 Lab 7 Material
    private let reuseIdentifier = "bagCell"
    
    var itemList = [Item]()
//    var managedObjectContext: NSManagedObjectContext?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    
    private func setUI() {
        // Register cell classes
//        self.bagCollectionView!.register(BagCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        bagCollectionView.dataSource = self
        bagCollectionView.delegate = self
        bagCollectionView.backgroundColor = UIColor(displayP3Red: 140/255, green: 235/255, blue: 211/255, alpha: 1.0)
        //8CEBD3
        //let backgroundImageView = UIImageView()
        //backgroundImageView.image = UIImage(named:"background-login")
        //bagCollectionView.backgroundView = backgroundImageView

        navBar.tintColor = .brown
        navBar.barTintColor = .brown
        navBar.prefersLargeTitles = true
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        do {
//            let imageDataList = try
////                managedObjectContext!.fetch(ImageMetaData.fetchRequest())
//                as [ImageMetaData]
//            for data in imageDataList {
//                let filename = data.filename!
//                if imagePathList.contains(filename) {
//                    print("Image already loaded skipping image")
//                    continue
//                }
//                if let image = loadImageData(filename: filename) {
//                    self.imageList.append(image)
//                    self.imagePathList.append(filename)
//                    self.collectionView?.reloadSections([0])
//                }
//            }
//        } catch {
//            print("Unable to fetch images")
//        }
    }
    
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }
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
        cell.configure(with: "shelf")
        
        // Configure the cell
        //cell.backgroundColor = .secondarySystemFill
//        cell.imageView.image = imageList[indexPath.row]
        return cell
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

