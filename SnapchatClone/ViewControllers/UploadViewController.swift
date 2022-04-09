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
        SnapRepository.instance.uploadSnap(image: imgUpload.image!) { error in
            if error != nil {
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Image Upload Error")
                return
            }
            
            // Başarılı eklendi
            // Ana sayfaya yönlendirilir
            self.tabBarController?.selectedIndex = 0
            self.imgUpload.image = UIImage(named: "select")
            
        }
    }
    
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(btnOk)
        self.present(alert, animated: true,completion: nil)
    }
}


