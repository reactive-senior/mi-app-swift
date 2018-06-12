//
//  Controller_Tutoriel.swift
//  Timi
//
//  Created by Julien on 22/08/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import ImageSlideshow

class Controller_Tutoriel: UIViewController {
    
    @IBOutlet var imageSlideShow: ImageSlideshow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageSlideShow.setImageInputs([
            ImageSource(image: UIImage(named: "tuto_1-1")!),
            ImageSource(image: UIImage(named: "tuto_2-1")!),
            ImageSource(image: UIImage(named: "tuto_3-1")!),
            ImageSource(image: UIImage(named: "tuto_4-1")!),
            ImageSource(image: UIImage(named: "tuto_5-1")!),
            ImageSource(image: UIImage(named: "tuto_6-1")!)])
        
        imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
        
        imageSlideShow.circular = false
    
        //imageSlideShow.activityIndicator = DefaultActivityIndicator(style: UIActivityIndicatorViewStyle.gray, color: UIColor.blue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickValider(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
