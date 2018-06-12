//
//  UtilisateurViewCell.swift
//  Timi
//
//  Created by Julien on 26/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit

class LieuViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!

    
    @IBOutlet weak var viewLieu: UIView!

    @IBOutlet weak var imageLieu: UIImageView!

    var nom : String = ""
    var descr : String = ""

    @IBOutlet weak var txtnom: UILabel!
    @IBOutlet weak var txtdescr: UITextView!
    
    @IBOutlet weak var btnWWW: UIButton!
    @IBOutlet weak var btnINV: UIButton!
    @IBOutlet weak var btnLOC: UIButton!

    
    

    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.image.image = nil
    }

}
