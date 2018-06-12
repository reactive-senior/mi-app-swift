//
//  UtilisateurViewCell.swift
//  Timi
//
//  Created by Julien on 26/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit

class UtilisateurViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageSymbole: UIImageView!
    @IBOutlet weak var imageLieu: UIImageView!

    @IBOutlet weak var txtPrenomAge: UILabel!
    @IBOutlet weak var txtDistance: UILabel!

    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnDelete: UIButton!

    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.image.image = nil
    }

}
