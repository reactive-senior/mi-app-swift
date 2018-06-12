//
//  Controller_QRCode.swift
//  Timi
//
//  Created by Julien on 15/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit

class Controller_QRCode: UIViewController {
    @IBOutlet weak var image: UIImageView!

    var coupon = Coupon()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Controller_QRCode", coupon.code)
        let image = generateQRCode(from: coupon.code)

        self.image.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickRetour(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 20, y: 20)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
}
