//
//  Controller_AccueilConnectionPartenaire.swift
//  Timi
//
//  Created by Julien on 22/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP

class Controller_AccueilConnectionPartenaire: UIViewController {
    @IBOutlet weak var editIdentifiant: UITextField!
    @IBOutlet weak var editPass: UITextField!
    
    var preferences : UserDefaults = UserDefaults.standard
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickRetour(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickConnection(_ sender: Any) {
        let identifiant = editIdentifiant.text
        let pass = editPass.text
        
        if( identifiant == "" || pass == "" ) {
            afficherPopup(title : "Action impossible", message : "Veuillez renseigner votre identifiant et votre mot de passe")
        } else {
            if( Global().isConnectedToNetwork() == true ) {
                DispatchQueue.main.async {
                    self.tacheConnection(identifiant: identifiant!, pass: pass!)
                }
            } else {
                afficherPopup(title : "Action impossible", message : "Aucune connection internet")
            }
        }
    }
    
    func tacheConnection(identifiant : String, pass: String) {
        print("connection")
        
        self.present(alertController, animated: true, completion: nil)
        
        let params = ["type":"connection_partenaire", "identifiant":identifiant, "pass":pass] as [String : Any]
        
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
                            DispatchQueue.main.async {
                                self.alertController.dismiss(animated: true, completion: {
                                    let jsonPartenaire = json["data"]!
                                    
                                    let partenaire = Partenaire()
                                    
                                    if let id = jsonPartenaire["id"] as? String{
                                        partenaire.id = id
                                    }
                                    if let nom = jsonPartenaire["nom"] as? String{
                                        partenaire.nom = nom
                                    }
                                    if let identifiant = jsonPartenaire["identifiant"] as? String{
                                        partenaire.identifiant = identifiant
                                    }
                                    if let photo = jsonPartenaire["photo"] as? String{
                                        partenaire.photo = photo
                                    }
                                    if let categorie = jsonPartenaire["categorie"] as? String{
                                        partenaire.categorie = categorie
                                    }
                                    if let actif = jsonPartenaire["actif"] as? String{
                                        partenaire.actif = actif
                                    }
                                    if let note = jsonPartenaire["note"] as? String{
                                        partenaire.note = note
                                    }
                                    
                                    self.preferences.set(identifiant, forKey: "partenaire_identifiant")
                                    self.preferences.set(partenaire.id, forKey: "partenaire_id")
                                    
                                    self.preferences.synchronize()
                                    
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "accueilPartenaire") as! Controller_AccueilPartenaire
                                    
                                    vc.partenaire = partenaire
                                    
                                    self.present(vc, animated: false, completion: nil)
                                })
                            }
                        } else if json["success"] as! Int == 0 {
                            DispatchQueue.main.async {
                                self.alertController.dismiss(animated: true, completion: {
                                    self.afficherPopup(title : "Connection impossible", message : "Identifiant ou mot de passe incorrect")
                                })
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.alertController.dismiss(animated: true, completion: {
                                    self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                                })
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                            })
                        }
                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    DispatchQueue.main.async {
                        self.alertController.dismiss(animated: true, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                        })
                    }
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
