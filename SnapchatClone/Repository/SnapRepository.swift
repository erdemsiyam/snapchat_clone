//
//  SnapRepository.swift
//  SnapchatClone
//
//  Created by Erdem Siyam on 8.04.2022.
//

import Foundation
import Firebase
import FirebaseAuth

class SnapRepository {
    
    // Singleton
    private init() {}
    static let instance:SnapRepository = SnapRepository()
    
    // Properties
    var listSnap: [SnapModel] = []
    var selectedSnap : SnapModel?
    
    // Methods
    func getSnaps(onComplate: @escaping (_ error:Error?) -> ()){
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("Snaps").order(by: "date",descending: true).addSnapshotListener { querySnapshot, error in
            if error != nil || querySnapshot == nil || querySnapshot?.isEmpty ?? true {
                onComplate(error)
                return
            }
            self.listSnap.removeAll()
            for document in querySnapshot!.documents {
                let snap = SnapModel()
                snap.documentId = document.documentID
                snap.username = document.get("snapOwner") as? String
                snap.imageUrlArray = document.get("imageUrlArray") as? [String]
                snap.date = (document.get("date") as? Timestamp)?.dateValue()
                // saat farkı bulunur
                //snap.difference = 24 - Calendar.current.dateComponents([.hour], from:  snap.date!, to: Date()).hour!
                snap.difference = 1
                if snap.difference! <= 0 {
                    self.deleteSnap(snapModel: snap)
                    continue
                }
                
                self.listSnap.append(snap)
            }
            onComplate(nil)
        }
        
    }
    
    func deleteSnap(snapModel:SnapModel){
        if snapModel.documentId == nil {return}
        let firestoreDb = Firestore.firestore()
        firestoreDb.collection("Snaps").document(snapModel.documentId!).delete { error in
            //
        }
    }
    
    func uploadSnap(image:UIImage,onComplate: @escaping (_ error:Error?) -> ()){
        
        //  Storage
        
        let storageReference = Storage.storage().reference()
        let mediaFolder = storageReference.child("media")
        
        if let data = image.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            let uploadTask = imageReference.putData(data,metadata: nil) { storageMetaData, error in
                if error != nil {
                    onComplate(error)
                    return
                }
                
                imageReference.downloadURL { url, error2 in
                    if error2 != nil {
                        onComplate(error2)
                        return
                    }
                    
                    let imageUrl = url?.absoluteString
                    
                    // Firestore
                    
                    let firestore = Firestore.firestore()
                    
                    // Bu kullanıcıya ait olan snapi bul, varsa onun içindeki urllere url ekle
                    firestore.collection("Snaps").whereField("snapOwner", isEqualTo: UserRepository.instance.user.username!).getDocuments { querySnapshot, error3 in
                        if error3 != nil || querySnapshot == nil {
                            onComplate(error3)
                            return
                        }
                        if querySnapshot!.documents.count == 0 {
                            
                            // Url Array Objesi yoksa yeni obje oluştur kaydet
                            
                            // Fotoğraf nereye kayıt olacak obje içeriği listesi hazırlanır
                            let dataToSave = ["imageUrlArray":[imageUrl!],"snapOwner": UserRepository.instance.user.username!,"date":FieldValue.serverTimestamp()] as [String: Any]
                            firestore.collection("Snaps").addDocument(data: dataToSave) { error5 in
                                if error5 != nil {
                                    onComplate(error5)
                                    return
                                }
                                
                                // Başarılı eklendi
                                // Ana sayfaya yönlendirilir
                                onComplate(nil)
                            }
                        } else {
                            
                            // Url Array Objesi varsa olanı çek ona ekle
                            for document in querySnapshot!.documents {
                                let documentId = document.documentID
                                
                                // Url Array Objesi varsa olanı çek ona ekle
                                if var imageUrlArray = document.get("imageUrlArray") as? [String] {
                                    imageUrlArray.append(imageUrl!) // url array e yeni url eklendi
                                    
                                    // yeni url array firebase kayıt edilir
                                    let additionalData = ["imageUrlArray":imageUrlArray]
                                    firestore.collection("Snaps").document(documentId).setData(additionalData, merge: true) { error4 in
                                        if error4 != nil {
                                            onComplate(error4)
                                            return
                                        }
                                        
                                        // Başarılı eklendi
                                        // Ana sayfaya yönlendirilir
                                        onComplate(nil)
                                    }
                                } else {
                                    
                                    // Url Array Objesi yoksa yeni obje oluştur kaydet
                                    
                                    // Fotoğraf nereye kayıt olacak obje içeriği listesi hazırlanır
                                    let dataToSave = ["imageUrlArray":[imageUrl!],"snapOwner": UserRepository.instance.user.username!,"date":FieldValue.serverTimestamp()] as [String: Any]
                                    firestore.collection("Snaps").addDocument(data: dataToSave) { error5 in
                                        if error5 != nil {
                                            onComplate(error5)
                                            return
                                        }
                                        
                                        // Başarılı eklendi
                                        // Ana sayfaya yönlendirilir
                                        onComplate(nil)
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    
                }
            }
            uploadTask.observe(.failure) { snapshot in
                if let error = snapshot.error as? NSError {
                  switch (StorageErrorCode(rawValue: error.code)!) {
                  case .objectNotFound:
                    print("File doesn't exist")
                    break
                  case .unauthorized:
                      print("User doesn't have permission to access file")
                    break
                  case .cancelled:
                    print("User canceled the upload")
                    break
                  case .unknown:
                    print("Unknown error occurred, inspect the server response")
                    break
                  default:
                    print("A separate error occurred. This is a good place to retry the upload.")
                    break
                  }
                }
            }
        }
    }
    
    private func createSnap(){}
}
