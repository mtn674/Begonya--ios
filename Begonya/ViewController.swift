//
//  ViewController.swift
//  Begonya
//
//  Created by Metin Atac on 24.08.18.
//  Copyright © 2018 Metin Atac. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import FirebaseAuth
import GoogleSignIn

class ViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
 
    
    @IBOutlet weak var dateView: UITextField!
   
    @IBOutlet weak var activityView: UITextField!
    
    @IBOutlet weak var activityButton: UITextField!
    
    @IBOutlet weak var logoutBtn: UIButton!
    
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var searchButton: UIButton!
    
    
    
    private var db:Firestore!
    
    var activityArray = [Activity]()
    
    override func viewDidLoad() {
       searchButton.tintColor = .white
        addButton.tintColor = .white
        
     
    dateView.tintColor = .white
        dateView.clearButtonMode = .whileEditing
        
        activityView.tintColor = .white
        activityView.clearButtonMode = .whileEditing
        dateView.backgroundColor = UIColor(red: 0.9686, green: 0.651, blue: 0.1725, alpha: 1.0)
        activityView.backgroundColor = UIColor(red: 0.9686, green: 0.651, blue: 0.1725, alpha: 1.0)
        activityView.textColor = .white
        dateView.textColor = .white
       
        view.backgroundColor = UIColor(red: 0.9686, green: 0.651, blue: 0.1725, alpha: 1.0)
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() // hides the datePicker, too .
        db = Firestore.firestore()
        
        loadAllActivities(from: db)
        
    }
    
    // loadig of the data from the database
    
    fileprivate func loadAllActivities(from db: Firestore) {
        
        var activitiesArray = [Activity]()
        
        db.collection("docOfObjects").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    
                    let activity = Activity(dic: document.data())
                    
                    activitiesArray.append(activity)
                    
                    self.activityArray = activitiesArray
                    
                }
            }
        }
    }
    
    // Deletes given Event at the Date
    
    func deleteActivity(to db: Firestore, date: String, event:String){
        
        let activtyRef =  db.collection("docOfObjects").document(date)
        
        activtyRef.updateData([
            "event" : FieldValue.arrayRemove([event])
            ]
        ) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        loadAllActivities(from: db)
    }
    
    // adding an Event on to the given date
    
    fileprivate func addActivity (to db: Firestore, date: String, event:String) {
        
        let savedDatas = db.collection("savedObjects").document(date)    // Not editable, data cant be deleted. Like Backup
        let activtyRef =  db.collection("docOfObjects").document(date)
        
        
        activtyRef.setData([
            "date" : date
            
            ], merge: true
        ) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        activtyRef.updateData([
            "event" : FieldValue.arrayUnion([event]
            )]
            
        ) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        
        
        savedDatas.setData([   // Not editable from User COPY of the used Database
            "date" : date,
            
            ], merge: true
        ) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        savedDatas.updateData([
            "event" : FieldValue.arrayUnion([event]
            )]
            
        ) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    //  search desicion for date or event
    
    func search (date: String?, event: String?)  {
        
        if  date != nil && event == nil {
            
            searchForEvent(date: date!)
        }
        
    }
    
    
    // searchs for dates after input is an event
    
    func searchForDate(event: String) {
         loadAllActivities(from: db)
        var dates = [String]()
        
        for activity in activityArray{
            for events in activity.event!{
                
                if events == event {
                    dates.append(activity.date!)
                    
                }
            }
        }
        showAlertController(titleFromFunc: event, messageArray: dates)
    }
    
    
    // searchs for events after input is an date
    
    func searchForEvent (date: String )  {
            loadAllActivities(from: db)
        var events = [String]()
        
        
        for event in activityArray {
            if date == event.date {
                events = event.event!
                
            } else {
                
            }
        }
        showAlertController(titleFromFunc: date, messageArray: events)
    }
    
  
    
    
    
    
    
    
    @IBAction func addActivityButton(_ sender: UIButton) {
        print("addClicked")
        let dateText = dateView.text
       
        
        
        
        
        if let date = dateView.text , let event = activityView.text {
            if date == "" || event == "" {
                ErrorAdding()
                return
            }
            
           alertForAdd(date: date, event:event)
          
        } else {
            ErrorAdding()
        }
    
        
    }
    
    @IBAction func searchDateButton(_ sender: UIButton) {
      
        
        let date:  String = dateView.text!
        let event: String = activityView.text!
        
        
        
        if !date.isEmpty && event.isEmpty {
            searchForEvent(date: date)
        } else if date.isEmpty && !event.isEmpty {
            searchForDate(event: event)
            
        }else if !date.isEmpty && !event.isEmpty {
            alertForDelete(date: date, event: event) // Hier soll nicht die Funktion aufgerufen werden sondern ein Alert erscheinen, zum löschen.
        }
        
    }
    
    
    func logout(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance().signOut()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let lvc = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(lvc, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    
    
    
    @IBAction func logoutButton(_ sender: UIButton) {

        alertForLogout()

    }

    @IBAction func textFieldEditing(_ sender: UITextField) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.locale = Locale.init(identifier:"de"
        )
        datePickerView.backgroundColor = .white
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(ViewController.datePickerValueChanged), for: .valueChanged)
        
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat =  "dd. MM. yyyy"
        dateView.text = dateFormatter.string(from: sender.date)
    }
    
    func alertForAdd(date:String , event:String){
        
        let alert = UIAlertController(title:date , message:event, preferredStyle: .alert)
    //    alert.view.tintColor = UIColor.red
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .destructive, handler:{(action) in
            //self.dismiss(animated: true, completion: nil)
         //   alert.view.tintColor = UIColor.red
        }))
        alert.addAction(UIAlertAction(title: "Einfügen", style: .default, handler: {(action) in
            
            self.addActivity(to: self.db, date: date, event: event)
            self.loadAllActivities(from: self.db)
            self.dateView.text = ""
            self.activityView.text = ""
            
            
            
            
            
            
            // self.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // alert for the desicion, wheter you want to delete an event or not
    
   
    
    func alertForLogout(){
        
        let alert = UIAlertController(title:"Logout" , message:"möchten Sie sich wirklich abmelden?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .default, handler:{(action) in
            //self.dismiss(animated: true, completion: nil)
         alert.view.tintColor = UIColor.red
        }))
        alert.addAction(UIAlertAction(title: "Abmelden", style: .destructive, handler: {(action) in
            
         self.logout()
        
            
            // self.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    
    
    
    
    
    func alertForDelete(date: String, event: String){
        
        let del = "Löschen ?"
        let dateAndEvent = date+"\n"+event
        
        let alert = UIAlertController(title: del , message: dateAndEvent, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .default, handler:{(action) in
            //self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Löschen", style: .destructive, handler: {(action) in
            
            self.deleteActivity(to: self.db, date: date, event: event)
            
            alert.view.tintColor = UIColor.red
            
           // self.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
}


extension UIViewController {
    
    // Alert that pop ups after search for event or date
    
    func showAlertController(titleFromFunc: String , messageArray: [String] ) {
        var messageFromArray  = String()
        if messageArray.isEmpty{
            messageFromArray = "Leer"
        }else{
            for mes in messageArray {
                messageFromArray = messageFromArray + mes + "\n"
            }
        }
        
        let alert = UIAlertController(title: titleFromFunc, message: messageFromArray , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            //self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    // Error alert for add function , if there is no entered an event or a date
    func ErrorAdding() {
        
        let alert = UIAlertController(title: "Fehler", message:"Datum oder Event fehlt!" , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
           // self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // function for the hide from the keyboard after tabbing an empty space
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
