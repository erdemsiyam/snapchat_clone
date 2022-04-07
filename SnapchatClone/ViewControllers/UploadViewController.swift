//
//  UploadViewController.swift
//  SnapchatClone
//
//  Created by Erdem Siyam on 6.04.2022.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imgUpload: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setImageClickable()
    }
    
    func setImageClickable() {
        imgUpload.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(imgUploadOnClick))
        imgUpload.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func imgUploadOnClick() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true,completion: nil)
    }
    
    // Image seçim sonrası
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imgUpload.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    @IBAction func btnUploadOnClick(_ sender: Any) {
        
        //  Storage
        
        let storageReference = Storage.storage().reference()
        let mediaFolder = storageReference.child("media")
        
        if let data = imgUpload.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data,metadata: nil) { storageMetaData, error in
                if error != nil {
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Image Upload Error")
                    return
                }
                
                imageReference.downloadURL { url, error2 in
                    if error2 != nil {
                        self.makeAlert(title: "Error", message: error2?.localizedDescription ?? "Image Upload Error")
                        return
                    }
                    
                    let imageUrl = url?.absoluteString
                    
                    // Firestore
                    
                    let firestore = Firestore.firestore()
                    
                    // Bu kullanıcıya ait olan snapi bul, varsa onun içindeki urllere url ekle
                    firestore.collection("Snaps").whereField("snapOwner", isEqualTo: UserRepository.instance.user.username!).getDocuments { querySnapshot, error3 in
                        if error3 != nil || querySnapshot == nil {
                            self.makeAlert(title: "Error", message: error3?.localizedDescription ?? "Image Upload Error")
                            return
                        }
                        
                        for document in querySnapshot!.documents {
                            let documentId = document.documentID
                            
                            // Url Array Objesi varsa olanı çek ona ekle
                            if var imageUrlArray = document.get("imageUrlArray") as? [String] {
                                imageUrlArray.append(imageUrl!) // url array e yeni url eklendi
                                
                                // yeni url array firebase kayıt edilir
                                let additionalData = ["imageUrlArray":imageUrlArray]
                                firestore.collection("Snaps").document(documentId).setData(additionalData, merge: true) { error4 in
                                    if error4 != nil {
                                        self.makeAlert(title: "Error", message: error4?.localizedDescription ?? "Image Upload Error")
                                        return
                                    }
                                    
                                    // Başarılı eklendi
                                    // Ana sayfaya yönlendirilir
                                    self.tabBarController?.selectedIndex = 0
                                    self.imgUpload.image = UIImage(named: "select")
                                }
                            } else {
                                
                                // Url Array Objesi yoksa yeni obje oluştur kaydet
                                
                                // Fotoğraf nereye kayıt olacak obje içeriği listesi hazırlanır
                                let dataToSave = ["imageUrlArray":[imageUrl!],"snapOwner": UserRepository.instance.user.username!,"date":FieldValue.serverTimestamp()] as [String: Any]
                                firestore.collection("Snaps").addDocument(data: dataToSave) { error5 in
                                    if error5 != nil {
                                        self.makeAlert(title: "Error", message: error5?.localizedDescription ?? "Image Upload Error")
                                        return
                                    }
                                    
                                    // Başarılı eklendi
                                    // Ana sayfaya yönlendirilir
                                    self.tabBarController?.selectedIndex = 0
                                    self.imgUpload.image = UIImage(named: "select")
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                }
            }
        }
            
    }
    
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(btnOk)
        self.present(alert, animated: true,completion: nil)
    }
}


