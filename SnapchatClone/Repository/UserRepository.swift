//
//  UserRepository.swift
//  SnapchatClone
//
//  Created by Erdem Siyam on 7.04.2022.
//

import Foundation
import Firebase
import FirebaseAuth

class UserRepository {
    
    // Singleton
    private init() {}
    static let instance:UserRepository = UserRepository()
    
    // Properties
    var user:UserModel = UserModel()
    
    // Methods
    func getUserDetail(onError: @escaping (_ errorText:String) -> ()) {
        Firestore.firestore().collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { querySnapshot, error in
            if error != nil {
                onError(error?.localizedDescription ?? "Get details error")
                return
            }
            
            if querySnapshot?.isEmpty == false && querySnapshot != nil {
                for document in querySnapshot!.documents {
                    if let username = document.get("username") as? String {
                        self.user.email = Auth.auth().currentUser!.email!
                        self.user.username = username
                    }
                }
            }
            
        }
    }
    
    
}
