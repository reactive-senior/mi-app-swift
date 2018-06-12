//
//  OffreCell.swift
//  Timi
//
//  Created by Julien on 12/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit

class OffreCell: UITableViewCell {

    @IBOutlet weak var labelPrix: UILabel!
    @IBOutlet weak var imageOffre: UIImageView!
    @IBOutlet weak var TextLibelle: UITextView!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageOffre.image = nil
    }
}
