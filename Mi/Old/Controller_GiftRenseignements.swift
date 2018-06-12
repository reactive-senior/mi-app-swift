//
//  Controller_GiftRenseignements.swift
//  Timi
//
//  Created by Julien on 09/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP

class Controller_GiftRenseignements: UIViewController {
    @IBOutlet weak var fieldPrenomNom: UITextField!
    @IBOutlet weak var fieldAdresse: UITextField!
    @IBOutlet weak var fieldTelephone: UITextField!
    @IBOutlet weak var fieldHoraire: UITextField!

    var coupon = Coupon()
    var autreid = ""
    var idchat = ""
    
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
    
    @IBAction func clickValider(_ sender: Any) {
        print("valider")
        
        if( fieldPrenomNom.text! == "" || fieldAdresse.text! == "" || fieldTelephone.text! == "" || fieldHoraire.text! == "" ) {
            self.afficherPopup(title: "Action impossible", message: "Veuillez remplir tous les champs")
        } else {
            envoyerRenseignements()
        }
    }
    
    func envoyerRenseignements() {
        self.present(alertController, animated: true, completion: nil)
        
        let infos = "\(fieldPrenomNom.text!);\(fieldAdresse.text!);\(fieldTelephone.text!);\(fieldHoraire.text!)"
        
        let params = [ "type":"accepter_coupon_petiteattention",
                       "userid":preferences.string(forKey: "userid") ?? "",
                       "autreid":autreid, "idchat":idchat,
                       "idcoupon":coupon.id,
                       "infos":infos,
                       "prenomnom":fieldPrenomNom.text!,
                        "adresse":fieldAdresse.text!,
                        "numero":fieldTelephone.text!,
                        "tranchehoraire":fieldHoraire.text!
     ] as [String : Any]
        
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
                                let alert = UIAlertController(title: "Cadeau accepté", message: "Vous avez bien accepté ce cadeau", preferredStyle: .alert)
                                
                                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                    UIAlertAction in
                                    alert.dismiss(animated: true, completion: nil)
                                    print("clic suivant")
                                    
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
                                alert.addAction(okAction)
                                
                                self.present(alert, animated: true, completion: nil)
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
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
