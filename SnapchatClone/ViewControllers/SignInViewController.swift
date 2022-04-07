//
//  ViewController.swift
//  SnapchatClone
//
//  Created by Erdem Siyam on 6.04.2022.
//

import UIKit
import FirebaseAuth
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnSignInOnClick(_ sender: Any) {
        
        if !checkTexts() { return }
        
        Auth.auth().signIn(withEmail: txtEmail.text!, password: txtPassword.text!) { authDataResult, error in
            
            // Başarısız
            if error != nil {
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Sign in error")
                return
            }
            
            // Başarılı
            self.performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
        
    }
    @IBAction func btnSignUpOnClick(_ sender: Any) {
        
        if !checkTexts() { return }
        
        // Firebase Auth
        Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { authDataResult, error in
            
            // Başarısız
            if error != nil {
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Sign up error")
                return
            }
            
            // Yeni kullanıcının bilgilerini kayıt et
            self.saveNewUserToFirestore()
            
            // Başarılı
            self.performSegue(withIdentifier: "toFeedVC", sender: nil)
            
            
        }
    }
    
    func checkTexts() -> Bool {
        if txtEmail.text?.isEmpty ?? true || txtUsername.text?.isEmpty ?? true || txtPassword.text?.isEmpty ?? true {
            makeAlert(title: "Error", message: "Username/password/email empty")
            return false
        }
        if txtPassword.text!.count < 6 {
            makeAlert(title: "Error", message: "password must atleast 6 character")
            return false
        }
        return true
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(btnOk)
        self.present(alert, animated: true,completion: nil)
    }
    
    func saveNewUserToFirestore(){
        let firestore = Firestore.firestore()
        let userDictionary = ["email": txtEmail.text!, "username": txtUsername.text!] as [String : Any]
        firestore.collection("UserInfo").addDocument(data: userDictionary) { error in
            // Hata Olursa
        }
        
    }
    
    
}

