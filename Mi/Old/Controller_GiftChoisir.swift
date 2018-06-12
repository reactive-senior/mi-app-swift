//
//  Controller_GiftChoisir.swift
//  Timi
//
//  Created by Julien on 09/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP

class Controller_GiftChoisir: UIViewController {
    
    @IBOutlet weak var viewBar: UIView!
    @IBOutlet weak var viewCinema: UIView!
    @IBOutlet weak var viewRestaurant: UIView!
    @IBOutlet weak var viewSoiree: UIView!
    @IBOutlet weak var viewFleur: UIView!
    @IBOutlet weak var viewChocolat: UIView!
    @IBOutlet weak var viewAtypique: UIView!
    @IBOutlet weak var viewTapisrouge: UIView!
    
    var preferences : UserDefaults = UserDefaults.standard
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        viewBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickBar(tapGestureRecognizer:))))
        viewCinema.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickCinema(tapGestureRecognizer:))))
        viewRestaurant.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickRestaurant(tapGestureRecognizer:))))
        viewSoiree.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickSoiree(tapGestureRecognizer:))))
        viewAtypique.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickAtypique(tapGestureRecognizer:))))
        viewTapisrouge.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickTapisrouge(tapGestureRecognizer:))))
        
        viewFleur.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickFleur(tapGestureRecognizer:))))
        viewChocolat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickChocolat(tapGestureRecognizer:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickRetour(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func clickBar(tapGestureRecognizer: UITapGestureRecognizer) {
        afficherPartenaires(type: "bar")
    }
    @objc func clickCinema(tapGestureRecognizer: UITapGestureRecognizer) {
        afficherPartenaires(type: "cinema")
    }
    @objc func clickRestaurant(tapGestureRecognizer: UITapGestureRecognizer) {
        afficherPartenaires(type: "restaurant")
    }
    @objc func clickSoiree(tapGestureRecognizer: UITapGestureRecognizer) {
        afficherPartenaires(type: "soiree")
    }
    @objc func clickAtypique(tapGestureRecognizer: UITapGestureRecognizer) {
        afficherPartenaires(type: "atypique")
    }
    @objc func clickTapisrouge(tapGestureRecognizer: UITapGestureRecognizer) {
        afficherPartenaires(type: "tapisrouge")
    }
    @objc func clickFleur(tapGestureRecognizer: UITapGestureRecognizer) {
        afficherPartenaires(type: "petiteattention")
    }
    @objc func clickChocolat(tapGestureRecognizer: UITapGestureRecognizer) {
        afficherPartenaires(type: "culture")
    }
    
    func afficherPartenaires(type: String) {
        print(type)
        
        self.present(alertController, animated: true, completion: nil)
        
        let params = [ "type":"rechercher_partenaire_V2", "userid":preferences.string(forKey: "userid") ?? "", "typepartenaire": type ] as [String : Any]
        
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
                                var partenaires = [Partenaire]()
                                
                                let jsonPartenaires = json["partenaires"] as! [[String: Any]]
                                
                                for jsonPartenaire in jsonPartenaires{
                                    let partenaire = Partenaire()
                                    
                                    if let id = jsonPartenaire["id"] as? String{
                                        partenaire.id = id
                                    }
                                    
                                    if let nom = jsonPartenaire["nom"] as? String{
                                        partenaire.nom = nom
                                    }
                                    
                                    if let descr = jsonPartenaire["description"] as? String{
                                        partenaire.descr = descr
                                    }
                                    
                                    if let telephone = jsonPartenaire["telephone"] as? String{
                                        partenaire.telephone = telephone
                                    }
                                    
                                    if let email = jsonPartenaire["email"] as? String{
                                        partenaire.email = email
                                    }
                                    
                                    if let adresse = jsonPartenaire["adresse"] as? String{
                                        partenaire.adresse = adresse
                                    }
                                    
                                    if let latitude = jsonPartenaire["latitude"] as? String{
                                        partenaire.latitude = latitude
                                    }
                                    
                                    if let longitude = jsonPartenaire["longitude"] as? String{
                                        partenaire.longitude = longitude
                                    }
                                    
                                    if let photo = jsonPartenaire["photo"] as? String{
                                        partenaire.photo = photo
                                    }
                                    
                                    if let categorie = jsonPartenaire["categorie"] as? String{
                                        partenaire.categorie = categorie
                                    }
                                    
                                    if let distance = jsonPartenaire["distance"] as? String{
                                        partenaire.distance = distance
                                    }
                                    
                                    if let actif = jsonPartenaire["actif"] as? String{
                                        partenaire.actif = actif
                                    }
                                    
                                    if let note = jsonPartenaire["note"] as? String{
                                        partenaire.note = note
                                    }
                                    
                                    partenaires.append(partenaire)
                                }
                                
                                let giftPartenaires = self.storyboard?.instantiateViewController(withIdentifier: "giftPartenaires") as! Controller_GiftPartenaires
                                
                                giftPartenaires.partenaires = partenaires
                                
                                self.navigationController?.pushViewController(giftPartenaires, animated: true)
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
    
    /*func verifierPartenairesPossibles(type: String) {
        print(type)
        
        self.present(alertController, animated: true, completion: nil)
        
        let params = [ "type":"check_premierrdvok", "userid":preferences.string(forKey: "userid") ?? "", "autreid": preferences.string(forKey: "gift_iduser") ?? ""] as [String : Any]
        
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
                                self.afficherPartenaires(type: type)
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Vous n'avez encore jamais eu de rendez-vous")
                            })
                        }
                    } else {
                        self.alertController.dismiss(animated: true, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
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
    }*/
    
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
