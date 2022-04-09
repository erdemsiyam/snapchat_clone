//
//  FeedViewController.swift
//  SnapchatClone
//
//  Created by Erdem Siyam on 6.04.2022.
//

import UIKit
import SDWebImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table uyarlama
        tableView.delegate = self
        tableView.dataSource = self
        
        // Uygulama Açılma anında kullanıcının email & username alınır
        UserRepository.instance.getUserDetail { errorText in
            self.makeAlert(title: "Error", message: errorText)
        }
        
        // Uygulama açılma anında snapler alınır
        SnapRepository.instance.getSnaps { error in
            if error != nil {
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Get details error")
                return
            }
            
            // Başarılıysa table güncelle
            self.tableView.reloadData()
        }
    }
    
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(btnOk)
        self.present(alert, animated: true,completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SnapRepository.instance.listSnap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // cell hücresi hazırlandı
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCellTableViewCell
        
        // Sıradaki Snap modeli çekildi
        let snapModel: SnapModel = SnapRepository.instance.listSnap[indexPath.row]
        
        // kullanıcı adı verildi
        cell.lblUsername.text = snapModel.username ?? ""
        
        cell.img.sd_setImage(with: URL(string: snapModel.imageUrlArray![0]))
        
        //cell.img.image = UIImage(named: "select")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Eleman seçilince
        
        // Seçilen snap ele alınır
        SnapRepository.instance.selectedSnap = SnapRepository.instance.listSnap[indexPath.row]
        
        // Snap sayfası getirilir
        performSegue(withIdentifier: "toSnapVC", sender: nil)
    }
    
}
