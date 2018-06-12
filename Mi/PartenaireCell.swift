//
//  PartenaireCell.swift
//  Timi
//
//  Created by Julien on 10/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit

class PartenaireCell: UITableViewCell {
    @IBOutlet weak var imagePartenaire: UIImageView!
    
    @IBOutlet weak var labelNom: UILabel!
    @IBOutlet weak var labelNote: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imagePartenaire.image = nil
    }
}
