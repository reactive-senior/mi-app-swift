//
//  ChatViewCell.swift
//  Timi
//
//  Created by Julien on 31/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit

class ChatViewCell: UITableViewCell {
    @IBOutlet weak var imageProfil: UIImageView!
    @IBOutlet weak var imageSymbole: UIImageView!

    @IBOutlet weak var txtPrenom: UILabel!
    @IBOutlet weak var txtDernierMessage: UILabel!
    
    @IBOutlet weak var txtDate: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageProfil.image = nil
    }
}
