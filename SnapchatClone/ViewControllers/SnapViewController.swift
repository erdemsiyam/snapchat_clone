//
//  SnapViewController.swift
//  SnapchatClone
//
//  Created by Erdem Siyam on 6.04.2022.
//

import UIKit
import ImageSlideshow

class SnapViewController: UIViewController {
    
    
    @IBOutlet weak var lblTimeLeft: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTimeLeft.text = "Time Left: \( SnapRepository.instance.selectedSnap?.difference ?? 0)"
        
        createImageSlideshow()
        
    }
    
    func createImageSlideshow() {
        
        // String urller Kingfisher e çevirilir (internetten foto indiren obje)
        let kingImages:[KingfisherSource] = (SnapRepository.instance.selectedSnap?.imageUrlArray!.map { (x) -> KingfisherSource in
            return KingfisherSource(urlString: x)!
        })!
        
        // UI Bileşen oluşturulur
        let imageSlideShow = ImageSlideshow(frame: CGRect(x: 10, y: 10, width: self.view.frame.width * 0.95, height: self.view.frame.height * 0.9))
        imageSlideShow.backgroundColor = UIColor.white
        imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
        imageSlideShow.setImageInputs(kingImages)
        
        // Altta noktalar
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray
        pageIndicator.pageIndicatorTintColor = UIColor.black
        imageSlideShow.pageIndicator = pageIndicator
        
        self.view.addSubview(imageSlideShow)
        self.view.bringSubviewToFront(lblTimeLeft)
    }

}
