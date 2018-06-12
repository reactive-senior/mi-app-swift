//
//  MessageViewCell.swift
//  Timi
//
//  Created by Julien on 07/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit

class MessageViewCell: UITableViewCell {
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelvu: UILabel!

    @IBOutlet weak var contrainteDroite: NSLayoutConstraint!
    @IBOutlet weak var contrainteGauche: NSLayoutConstraint!
    @IBOutlet weak var contrainteBas: NSLayoutConstraint!
}
