//
//  LoginViewController.swift
//  Begonya
//
//  Created by Metin Atac on 31.08.18.
//  Copyright © 2018 Metin Atac. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth


//var isLoggedIn = 0

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

  
    
    
    
    
    
    let googleSignInButton:GIDSignInButton = {
        let googleButton = GIDSignInButton()
        return googleButton
    }()
    
    override func viewDidLoad() {
     /* FirebaseApp.configure()
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        */
       
        
        view.backgroundColor = UIColor(red: 0.9686, green: 0.651, blue: 0.1725, alpha: 1.0)

        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        
        googleSignInButton.center = view.center
        view.addSubview(googleSignInButton)
        
        //GIDSignIn.sharedInstance().signIn()
        // Do any additional setup after loading the view.
        //let user = Auth.auth().currentUser
   
    }
    
   
    
    
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
             self.ConnectionFail(errorString:"möchten Sie in den \n Offline-Modus wechseln?")
        return
        }
        
        
      //  let firstName = user.profile.givenName
        //let familyName = user.profile.familyName
    
        
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
       
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // ...
                signIn.signOut()
                print(error)
                //ALert
                self.showAlertController(errorString: error.localizedDescription)
                return
            }
            // User is signed in
            // ...
            
          
            
            
            
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "ViewController")
            self.present(vc, animated: true, completion: nil)
        }
        
        
    }
    
    func showAlertController(errorString: String ) {
    
        let alert = UIAlertController(title: "ERROR", message: errorString , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Nein", style: .default, handler: { (action) in
          
            
            //self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Ja", style: .default, handler: { (action) in
          
         
            
        }))
        
         self.present(alert, animated: true, completion: nil)
    }
  
    
    
    
    
    
    
    
    func ConnectionFail(errorString: String ) {
        
        let alert = UIAlertController(title: "Keine Internetverbindung", message: errorString , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Nein", style: .default, handler: { (action) in
            
            
            //self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Ja", style: .default, handler: { (action) in
           
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "PwViewController")
            self.present(vc, animated: true, completion: nil)
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
        
        
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
