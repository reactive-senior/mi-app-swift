//
//  Controller_GiftPartenaires.swift
//  Timi
//
//  Created by Julien on 10/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import Nuke
import SwiftHTTP

class Controller_GiftPartenaires: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var preferences : UserDefaults = UserDefaults.standard
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var partenaires = [Partenaire]()
    
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

        self.tableView.separatorStyle = .none

        self.title = "Établissement"
        
        if( self.partenaires.count == 0 ) {
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
        return partenaires.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPartenaire", for: indexPath as IndexPath) as! PartenaireCell
        
        cell.selectionStyle = .none
        
        let partenaire = self.partenaires[indexPath.item]
        
        DispatchQueue.main.async {
            cell.imagePartenaire.image = nil
            
            Nuke.loadImage(with: URL(string: Global().url+"photo_partenaire/"+(partenaire.photo))!, into: cell.imagePartenaire)
        }
        
        cell.labelNom.text = partenaire.nom
        if ( partenaire.adresse == "")
        {
            cell.labelDescription.text = partenaire.descr
        }
        else{
            cell.labelDescription.text = partenaire.descr + "\n\n" + partenaire.adresse
        }

        if( partenaire.note == "0" ) {
            cell.labelNote.text = "Pas encore noté"
        } else {
            cell.labelNote.text = partenaire.note+" / 5"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let partenaire = self.partenaires[indexPath.item]

        self.voirOffres(id: partenaire.id)
    }

    func voirOffres( id: String ) {
        print(id)
        
        self.present(alertController, animated: true, completion: nil)
        
        let params = [ "type":"get_offres", "idpartenaire": id ] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_partenaire.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    })
                    return
                }
                
                print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            self.alertController.dismiss(animated: true, completion: {
                                var offres = [Offre]()
                                
                                let jsonOffres = json["offres"] as! [[String: Any]]
                                
                                for jsonOffre in jsonOffres{
                                    let offre = Offre()
 
                                    offre.id = jsonOffre["id"] as! String
                                    offre.partenaire = jsonOffre["partenaire"] as! String
                                    offre.libelle = jsonOffre["libelle"] as! String
                                    offre.prix = jsonOffre["prix"] as! String
                                    offre.photo = jsonOffre["photo"] as! String
                                    offre.actif = jsonOffre["actif"] as! String
                                    
                                    offres.append(offre)
                                }
                                
                                let giftOffres = self.storyboard?.instantiateViewController(withIdentifier: "giftOffres") as! Controller_GiftOffres
                                
                                giftOffres.offres = offres
                                
                                self.navigationController?.pushViewController(giftOffres, animated: true)
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                            })
                        }
                    } else {
                        self.alertController.dismiss(animated: true, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Vous n'avez encore jamais eu de rendez-vous")
                        })
                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    })
                }
            }
        } catch {
            self.alertController.dismiss(animated: true, completion: {
                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
            })
        }
    }
    
    func afficherPopup( title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
