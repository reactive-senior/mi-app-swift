//
//  CouponCell.swift
//  Timi
//
//  Created by Julien on 15/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit

class CouponCell: UITableViewCell {
    @IBOutlet weak var imagePartenaire: UIImageView!
    
    @IBOutlet weak var labelEtat: UILabel!
    @IBOutlet weak var labelNom: UILabel!
    @IBOutlet weak var labelLibelle: UILabel!

    @IBOutlet weak var buttonQRCode: UIButton!
    @IBOutlet weak var buttonNoter: UIButton!
    @IBOutlet weak var buttonAnnuler: UIButton!
    
    @IBOutlet weak var buttonPhone: UIButton!
    @IBOutlet weak var buttonMaps: UIButton!

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imagePartenaire.image = nil
    }
}
