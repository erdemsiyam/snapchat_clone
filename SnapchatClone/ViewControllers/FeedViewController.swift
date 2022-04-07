//
//  FeedViewController.swift
//  SnapchatClone
//
//  Created by Erdem Siyam on 6.04.2022.
//

import UIKit

class FeedViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uygulama Açılma anında kullanıcının email & username alınır
        UserRepository.instance.getUserDetail { errorText in
            self.makeAlert(title: "Error", message: errorText)
        }
    }
    
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(btnOk)
        self.present(alert, animated: true,completion: nil)
    }
    
}
