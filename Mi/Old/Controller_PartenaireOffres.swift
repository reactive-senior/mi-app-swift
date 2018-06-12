
//  Created by Julien on 12/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import Stripe
import SwiftHTTP
import Nuke

class Controller_PartenaireOffres: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var preferences : UserDefaults = UserDefaults.standard
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    
    
    
    var PartenaireOffres = [Offre]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelInformations: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Controller_PartenaireOffres")
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        //self.tableView.separatorStyle = .none
        
        self.title = "Offres"
        
        if( self.PartenaireOffres.count == 0 ) {
            self.tableView.isHidden = true
            self.labelInformations.isHidden = false
        } else {
            self.tableView.isHidden = false
            self.labelInformations.isHidden = true
        }
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Retour", style: UIBarButtonItemStyle.plain, target: self, action: #selector(Controller_PartenaireOffres.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    func back(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func clickExit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PartenaireOffres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellOffre", for: indexPath as IndexPath) as! OffreCell
        
        cell.selectionStyle = .none
        let offre = self.PartenaireOffres[indexPath.item]

        let prix = Double(offre.prix)! / 100.00
        let prixstring = String(format: "%.2f", arguments: [prix])
        
        cell.TextLibelle.text = offre.libelle
        cell.labelPrix.text = "\(prixstring) €"

        let photo = offre.photo;
        
        cell.imageOffre.image = nil
        
        if !photo.isEmpty
        {
            DispatchQueue.main.async {
                Nuke.loadImage(with: URL(string: Global().url+"photo_offre/"+(photo))!, into: cell.imageOffre)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let wWidth = self.tableView.frame.width - 70

        
        let offre = self.PartenaireOffres[indexPath.item]
        let lib = offre.libelle
        print ("lib " + lib)
        let height:CGFloat = self.calculateHeight(inString: lib)
        print(String(indexPath.row)+" : \(height)  \(wWidth) " + lib )
        return height+20
        
            }
    
    func calculateHeight(inString:String) -> CGFloat
    {
        
        let wWidth = self.tableView.frame.width - 70
        
        let messageString = inString
        let attributes = [NSAttributedStringKey.font:  UIFont(name: "Helvetica-Bold", size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.white]
        
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: wWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        let requredSize:CGRect = rect
        return requredSize.height + 60
        
        
    }
    
    

}
