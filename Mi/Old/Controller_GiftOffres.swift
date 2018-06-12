//
//  Controller_GiftOffres.swift
//  Timi
//
//  Created by Julien on 12/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import Stripe
import SwiftHTTP
import Nuke

class Controller_GiftOffres: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var preferences : UserDefaults = UserDefaults.standard
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var offres = [Offre]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelInformations: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        //self.tableView.separatorStyle = .none
        
        self.title = "Offres"
        
        if( self.offres.count == 0 ) {
            self.tableView.isHidden = true
            self.labelInformations.isHidden = false
        } else {
            self.tableView.isHidden = false
            self.labelInformations.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellOffre", for: indexPath as IndexPath) as! OffreCell
        
        cell.selectionStyle = .none
        let offre = self.offres[indexPath.item]

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

        
        let offre = self.offres[indexPath.item]
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offre = self.offres[indexPath.item]
        
        let prix = Double(offre.prix)! / 100.00
        
        let prixstring = String(format: "%.2f", arguments: [prix])
    
        let alert = UIAlertController(title: "Acheter \(offre.libelle)", message: "Prix : \(prixstring) €", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Confirmer", style: .default, handler: { (action) in
            print("achat ici")
            
            let number = self.preferences.string(forKey: "card_number") ?? "0"
            let month = self.preferences.string(forKey: "card_month") ?? "0"
            let year = self.preferences.string(forKey: "card_year") ?? "0"
            let cvc = self.preferences.string(forKey: "card_cvc") ?? "0"
            
            
            if( number == "0" || month == "0" || year == "0" || cvc == "0" ) {
                self.afficherPopup(title: "Action impossible", message: "Vous n'avez pas rempli vos coordonnées bancaires")
            } else {
                let cardParams = STPCardParams()
                cardParams.number = number
                cardParams.expMonth = UInt(month)!
                cardParams.expYear = UInt(year)!
                cardParams.cvc = cvc
                STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
                    if let error = error {
                        self.afficherPopup(title: "Action impossible", message: "Votre carte n'est pas valide")
                        print(error)
                    } else if let token = token {
                        self.envoyerTokenServeur(token: token, offre: offre)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Retour", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func envoyerTokenServeur(token: STPToken, offre: Offre) {
        self.present(alertController, animated: true, completion: nil)
        let params = [ "type":"acheter_offre", "stripeToken": token.tokenId, "acheteur": preferences.string(forKey: "userid") ?? "", "receveur": preferences.string(forKey: "gift_iduser") ?? "", "idchat": preferences.string(forKey: "gift_idchat") ?? "", "offre": offre.id, "prix": offre.prix] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_paiement.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopup(title : "Action impossible", message : "Le paiement n'a pas pu aboutir. Veuillez réessayer.")
                    })
                    return
                }
                print(response.text!)
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            self.alertController.dismiss(animated: true, completion: {
                                let alert = UIAlertController(title: "Achat réussi", message: "Vous avez bien acheté cette offre", preferredStyle: .alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                                    UIAlertAction in
                                    alert.dismiss(animated: true, completion: nil)
                                    
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
                                alert.addAction(okAction)
                                
                                self.present(alert, animated: true, completion: nil)
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Le paiement n'a pas pu aboutir. Veuillez réessayer.")
                            })
                        }
                    } else {
                        self.alertController.dismiss(animated: true, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Le paiement n'a pas pu aboutir. Veuillez réessayer.")
                        })
                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopup(title : "Action impossible", message : "Le paiement n'a pas pu aboutir. Veuillez réessayer.")
                    })
                }
            }
        } catch {
            self.alertController.dismiss(animated: true, completion: {
                self.afficherPopup(title : "Action impossible", message : "Le paiement n'a pas pu aboutir. Veuillez réessayer.")
            })
        }
    }
    
    func afficherPopup (title: String, message: String) {
        let alert = UIAlertController(title: title, message: "\n\n\n\n\n", preferredStyle: .alert)
        let viewText =  UITextView ()
        viewText.frame = CGRect(x: 10, y: 40, width: 250, height: 100)
        viewText.allowsEditingTextAttributes = false
        viewText.backgroundColor = UIColor.clear
        viewText.text = message
        alert.view.addSubview(viewText)

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)

        present(alert, animated: true)
        
    }
    
    
    func afficherPopupvp( title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)

        self.present(alert, animated: true, completion: nil)

    
    }
}
