//
//  ItemsViewController.swift
//  InstantSharedShoppingList_iOS
//
//  Created by Pier Luigi Papeschi on 21/07/2019.
//  Copyright © 2019 Pier Luigi Papeschi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class ItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChangeItemDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet var itemsTableView: UITableView!
    @IBOutlet var addItemTextField: UITextField!
    @IBOutlet var addItemButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    var db: Firestore!
    var listId = "5LC8zA3y3fS9AWWwF6kL"
    private var documents: [DocumentSnapshot] = []
    
    var items: [Item] = []
    var search: String = ""
    var isSearching: Bool = false
    var filteredItems = [Item]()
    
    private var listener: ListenerRegistration?
    
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                print("---> Query?")
                listener.remove()
                observeQuery()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addItemTextField.delegate = self
        addItemTextField.addTarget(self, action:#selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)), for: UIControl.Event.editingChanged)
        
        addItemButton.isHidden = true
        
        addItemTextField.layer.cornerRadius = 20.0
        addItemTextField.layer.borderWidth = 1.0
        addItemTextField.layer.borderColor = UIColor.red.cgColor

        db = Firestore.firestore()
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        
        query = baseQuery()
        itemsTableView.register(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: "itemListCell")
        
        itemsTableView.separatorStyle = .none
        
        configureTableView()
        
        self.title = "SPESA"
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print(">>> <<< textFieldShouldEndEditing: \(textField.text!)")
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("---> viewWillAppear()")
        observeQuery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("---> viewWillDesappear()")
        stopObserving()
    }
    
    deinit {
        print("---> deinit")
        listener?.remove()
    }
    
    
    // MARK: - Query part

    fileprivate func baseQuery() -> Query {
        print("---> baseQuery()")
        // Firestore needs to use Timestamp type instead of Date type.
        // https://firebase.google.com/docs/reference/swift/firebasefirestore/api/reference/Classes/FirestoreSettings
        let firestore: Firestore = Firestore.firestore()
        
        //if listId != nil {
        return firestore.collection("lists").document(self.listId).collection("items").order(by: "isChecked").order(by: "timestamp", descending: true)
        //Linda vuole order(by: "timestamp", descending: true
        //} else {
        //DA RIVEDERE
        //return firestore.collection("lists")
        //}
    }
    
    /*
     * Attenzione quando sto scrivendo un nuovo item e nel frattempo un altro untente ne ha appena aggiunto uno: come si comporta?
     */
    fileprivate func observeQuery() {
        print("---> observeQuery()")
        guard let query = query else { return }
        stopObserving()
        
        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            
            let models = snapshot.documents.map { (document) -> Item in
                if let model = Item(dictionary: document.data()) {
                    return model
                } else {
                    // Don't use fatalError here in a real app.
                    fatalError("Unable to initialize type \(Item.self) with dictionary \(document.data())")
                }
            }
            
            self.items = models
            self.documents = snapshot.documents
            
            if self.documents.count > 0 {
                self.itemsTableView.backgroundView = nil
            } else {
                print("Lista vuota")
                //self.itemsTableView.backgroundView = self.backgroundView
            }
            
            self.itemsTableView.reloadData()
        }
    }

    fileprivate func stopObserving() {
        print("---> stopObserving()")
        listener?.remove()
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemListCell", for: indexPath) as! ItemTableViewCell
        
        var theCell: Item
        
        if isSearching {
            theCell = filteredItems[indexPath.row]
            //print("cellForRowAt: \(filteredItems.count)")
        } else {
            theCell = items[indexPath.row]
        }
        
        cell.itemTextField.text! = theCell.name
        
        if theCell.isChecked {
            setChecked(cell: cell)
        } else {
            setUnchecked(cell: cell)
        }
        cell.cellIndex = indexPath
        cell.delegate = self
        
        //cell.itemTextField.addGestureRecognizer(UITapGestureRecognizer(target: cell.itemTextField, action: Selector("endEditing:")))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredItems.count
        }
        return items.count
    }
    
    func configureTableView(){
        itemsTableView.rowHeight = UITableView.automaticDimension
        itemsTableView.estimatedRowHeight = 40.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(items[indexPath.row])
        //tableView.deselectRow(at: indexPath, animated: true)
        if isSearching {
            print("Cliccato su filtered \(filteredItems[indexPath.row])")
        } else {
            print("Cliccato su items \(items[indexPath.row])")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //let animation = AnimationFactory.makeSlideIn(duration: 0.1, delayFactor: 0.01)
        //let animator = Animator(animation: animation)
        //animator.animate(cell: cell, at: indexPath, in: tableView)
    }
    
    
    // MARK: - Interaction with View's elements
    
    private func resetAddItemTextField() {
        addItemTextField.text = ""
        addItemButton.isHidden = true
        addItemTextField.endEditing(true)
        isSearching = false
    }
    
    @IBAction func btnAddPressed(_ sender: Any) {
        addItemInList(itemName: addItemTextField.text!)
        resetAddItemTextField()
        itemsTableView.reloadData()
    }
    
    @IBAction func addTextFieldChanged(_ sender: Any) {
        if addItemButton.isHidden {
            addItemButton.isHidden = false
        }
    }
    
    @IBAction func StartBtnPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Start shopping!", message: "Function not yet implemented!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Retry later",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logOutBtnPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            print("Properly logged out")
            
            defaults.set("", forKey: "user_name")
            defaults.set("", forKey: "user_email")
            
            let main = UIStoryboard(name: "Main", bundle: nil)
            let welcome = main.instantiateViewController(withIdentifier: "WelcomeVC")
            self.present(welcome, animated: true, completion: nil)
        }
        catch {
            
            print("error: there was a problem logging out")
        }
    }
    
    func addItemInList(itemName: String) {
        let ref = db.collection("lists").document(listId).collection("items")
        let newItem = ref.document()
        
        let data = Item(
            id: newItem.documentID,
            name: itemName,
            isChecked: false,
            order: 0,
            category: "",
            count: 0,
            supermarket: "",
            date: Date())
        
        newItem.setData(data.dictionary) { err in
            if let err = err {
                print("Error adding document: \(err.localizedDescription)")
            } else {
                self.items.append(data)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            search = String(search.dropLast())
            
            //Deleting all characters in the texfield = no word to search for
            if search.isEmpty {
                isSearching = false
            }
        }
        else {
            isSearching = true
            search = textField.text! + string
        }
        
        self.filteredItems = items.filter({(item) -> Bool in
            let stringMatch = item.name.lowercased().range(of: search.lowercased())
            return stringMatch != nil ? true : false
        })
        
        itemsTableView.reloadData()
        
        //print("shouldChangeCharactersIn: \(filteredItems.count)")
        return true
    }
    
    // MARK: - Change item methods from item list interactionas the protocol ChangeItemDelegate
    
    func checkedPressed(cell: ItemTableViewCell) {
        print("checkedPressed \(cell.checkedBtn.isSelected)")
        changeChecked(cell: cell)
        
        if cell.checkedBtn.isSelected {
            setUnchecked(cell: cell)
            cell.itemTextField.isUserInteractionEnabled = true
        } else {
            self.setChecked(cell: cell)
            cell.itemTextField.isUserInteractionEnabled = false
        }
        
        if isSearching {
            resetAddItemTextField()
        }
    }
    
    func deletePressed(cell: ItemTableViewCell) {
        let alert = UIAlertController(title: "Delete?", message: "Sure want to delete?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            print("Cliccato da deletage delete cancellato: \(cell)")
            
            if self.isSearching {
                self.resetAddItemTextField()
                let item = self.filteredItems[(cell.cellIndex?.row)!]
                self.db.collection("lists").document(self.listId).collection("items").document(item.id).delete() { err in
                    if let err = err {
                        print("Error removing filtered document: \(err)")
                    } else {
                        print("Filtered document successfully removed!")
                    }
                }
            } else {
                let item = self.items[(cell.cellIndex?.row)!]
                self.db.collection("lists").document(self.listId).collection("items").document(item.id).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func setChecked(cell: ItemTableViewCell) {
        print("setChecked \(String(describing: cell.itemTextField.text))")
        cell.checkedBtn.isSelected = true
        cell.checkedBtn.setImage(UIImage(named: "ic_check_box"), for: .normal)
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cell.itemTextField.text!)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        cell.itemTextField.attributedText = attributeString
        //cell.itemTextField.textColor = UIColor.white
        
        let origImage = cell.checkedBtn.currentImage
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        cell.checkedBtn.setImage(tintedImage, for: .normal)
        cell.checkedBtn.tintColor = .lightGray
        
        cell.itemTextField.textColor = UIColor.lightGray
        cell.itemTextField.isUserInteractionEnabled = false
    }
    
    func setUnchecked(cell: ItemTableViewCell) {
        print("setUnchecked \(String(describing: cell.itemTextField.text))")
        cell.checkedBtn.isSelected = false
        cell.checkedBtn.setImage(UIImage(named: "ic_check_box_outline_blank"), for: .normal)
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cell.itemTextField.text!)
        attributeString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributeString.length))
        cell.itemTextField.attributedText = attributeString
        cell.itemTextField.textColor = UIColor.darkGray
        
        cell.backgroundColor = UIColor.clear
        cell.itemTextField.backgroundColor = UIColor.clear
        cell.itemTextField.isUserInteractionEnabled = true
    }
    
    func changeChecked(cell: ItemTableViewCell) {
        //let animation = AnimationFactory.makeSlideOut(duration: 0.5, delayFactor: 0.05)
        //let animator = Animator(animation: animation)
        //animator.animate(cell: cell, at: cell.cellIndex!, in: itemsTableView)
        
        if isSearching {
            let itemRef = db.collection("lists").document(listId).collection("items").document(filteredItems[(cell.cellIndex?.row)!].id)
            itemRef.updateData(["isChecked": !filteredItems[(cell.cellIndex?.row)!].isChecked]) { err in
                if let err = err {
                    print("Error updating data \(err)")
                } else {
                    print("Filtered Data updated correctly")
                }
            }
        } else {
            let itemRef = db.collection("lists").document(listId).collection("items").document(items[(cell.cellIndex?.row)!].id)
            itemRef.updateData(["isChecked": !items[(cell.cellIndex?.row)!].isChecked]) { err in
                if let err = err {
                    print("Error updating data \(err)")
                } else {
                    print("Data updated correctly")
                }
            }
        }
        
        itemsTableView.reloadData()
    }
    
    func editingItemEnded(cell: ItemTableViewCell) {
        //Se edito un item che è stato filtrato???
        if isSearching {
            let itemRef = db.collection("lists").document(listId).collection("items").document(filteredItems[(cell.cellIndex?.row)!].id)
            itemRef.updateData(["name": cell.itemTextField.text!]) { err in
                if let err = err {
                    print("Error updating filtered data \(err)")
                } else {
                    print("Filtered data updated correctly: \(String(describing: cell.itemTextField.text))")
                }
            }
        } else {
            let itemRef = db.collection("lists").document(listId).collection("items").document(items[(cell.cellIndex?.row)!].id)
            itemRef.updateData(["name": cell.itemTextField.text!]) { err in
                if let err = err {
                    print("Error updating data \(err)")
                } else {
                    print("Data updated correctly: \(String(describing: cell.itemTextField.text))")
                }
            }
        }
    }
}
