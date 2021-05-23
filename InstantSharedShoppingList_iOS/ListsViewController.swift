//
//  ListsViewController.swift
//  InstantSharedShoppingList_iOS
//
//  Created by Pier Luigi Papeschi on 12/10/2019.
//  Copyright © 2019 Pier Luigi Papeschi. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit
import SVProgressHUD

class ListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var addListBtnPressed: UIBarButtonItem!
    @IBOutlet var listsTableView: UITableView!
    
    
    var db: Firestore!
    var email: String = ""
    var lists: [List] = [List]()
    var idInArray: Int?
    let defaults = UserDefaults.standard
    
    private var documents: [DocumentSnapshot] = []
    private var listener: ListenerRegistration?
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                print("Lists ---> Query?")
                listener.remove()
                observeQuery()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        email = (Auth.auth().currentUser?.email)!

        listsTableView.delegate = self
        listsTableView.dataSource = self
        
        query = baseQuery()
        listsTableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "listCell")
        
        configureTableView()
        self.title = "LISTS"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeQuery()
    }
    
    // MARK: - Query part

    fileprivate func baseQuery() -> Query {
        print("Lists ---> baseQuery()")
        let firestore: Firestore = Firestore.firestore()
        //Sostituire con l'email salvata nei campi defaults
        let email = (Auth.auth().currentUser?.email)!
        print("Email del proprietario: \(email)")
        return firestore.collection("lists").whereField("emailOwner", isEqualTo: email)
    }
    
    /*
     * Attenzione quando sto scrivendo un nuovo item e nel frattempo un altro untente ne ha appena aggiunto uno: come si comporta?
     */
    fileprivate func observeQuery() {
        print("Lists ---> observeQuery()")
        guard let query = query else { return }
        stopObserving()
        
        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            
            let models = snapshot.documents.map { (document) -> List in
                if let model = List(dictionary: document.data()) {
                    return model
                } else {
                    // Don't use fatalError here in a real app.
                    fatalError("Unable to initialize type \(List.self) with dictionary \(document.data())")
                }
            }
            
            self.lists = models
            self.documents = snapshot.documents
            
            if self.documents.count > 0 {
                self.listsTableView.backgroundView = nil
            } else {
                print("No lists available")
                //self.itemsTableView.backgroundView = self.backgroundView
            }
            
            self.listsTableView.reloadData()
        }
    }

    fileprivate func stopObserving() {
        print("Lists ---> stopObserving()")
        listener?.remove()
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListTableViewCell
        
        cell.listNameTextField.text = lists[indexPath.row].name
        //cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        idInArray = indexPath.row
        defaults.set(lists[idInArray!].name, forKey: "ListNameSelected")
        //performSegue(withIdentifier: "gotoListsItems", sender: self)
        
        //let listsVC = UIStoryboard(name: "Main", bundle: nil)
        
        //let itemsVC = listsVC.instantiateViewController(withIdentifier: "itemsInListViewController")
        //let itemsVC = listsVC.instantiateViewController(withIdentifier: "mainTabbarViewController")
        //self.definesPresentationContext = true
        //itemsVC.modalPresentationStyle = .overCurrentContext
        //self.present(itemsVC, animated: true, completion: nil)
        
        //tabBarController?.selectedIndex = 0
    }
    
    func configureTableView(){
        listsTableView.rowHeight = 80.0 //UITableView.automaticDimension
        //listsTableView.estimatedRowHeight = 80.0
    }

    // MARK: - Navigation
    
    @IBAction func addListBtnPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Add new list", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                var ref: DocumentReference? = nil
                
                let data = List(
                    name: text,
                    emailOwner: self.email)
                ref = self.db.collection("lists").addDocument(data: data.dictionary) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        
                        self.lists.append(data)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "List name"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
