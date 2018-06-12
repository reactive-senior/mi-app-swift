//
//  Controller_Main.swift
//  Mi
//
//  Created by TED on 14/02/2018.
//  Copyright © 2018 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP



class Controller_Symboles: UIViewController {

    var preferences : UserDefaults = UserDefaults.standard

    var symbole = "coeur"

    let StringCoeur = "Le cœur pour du sérieux seulement."
    let StringTrefle = "Le trèfle pour de l'amitié."
    let StringPique = "Le pique pour de l'éphemère."
    let StringCarreau = "Le carreau pour tout type de rencontres."
    
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var StringTCCP: UILabel!
    @IBOutlet weak var BtnValider: UIButton!
    
    
    
    
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    @IBOutlet weak var uiTitle: UILabel!
    var wTitle = "Modifier Mon Envie"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        uiTitle.text = wTitle
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        
        symbole = preferences.string(forKey: "inscription_symbole") ?? "coeur"
        StringTCCP.text = StringCoeur
        
        BtnValider.layer.borderColor = PrimaryColor.cgColor
        BtnValider.layer.borderWidth = 2.0
        BtnValider.layer.cornerRadius = 5.0

        initialisation()
    }
    
    func initialisation() {
        let params = ["type":"recupererpreferences", "userid":preferences.string(forKey: "userid") ?? ""] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                
                print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if ( json["success"] as! Int == 1 ) {
                            DispatchQueue.main.async(execute: {
                                let data = json["data"] as! Dictionary<String,AnyObject>
                                self.symbole = data["symbole"] as! String
                                self.setSymbole()
                            })
                        }
                    }
                } catch { }
            }
        } catch { }
    }
    
    func setSymbole()
    {
        switch symbole {
        case "pique"  :
            StringTCCP.text = StringPique
            self.Logo.image = UIImage(named: "Symbole_pique")

        case "coeur"  :
            StringTCCP.text = StringCoeur
            self.Logo.image = UIImage(named: "Symbole_coeur")

        case "carreau"  :
            StringTCCP.text = StringCarreau
            self.Logo.image = UIImage(named: "Symbole_carreau")

        case "trefle"  :
            StringTCCP.text = StringTrefle
            self.Logo.image = UIImage(named: "Symbole_trefle")

        default : break
        }
    }
    
    
    
    @IBAction func CoeurClick(_ sender: Any) {
        symbole = "coeur"
        setSymbole()
    }
    @IBAction func TrefleClic(_ sender: Any) {
        symbole = "trefle"
        setSymbole()
    }
    @IBAction func PiqueClick(_ sender: Any) {
        symbole = "pique"
        setSymbole()
    }
    @IBAction func CarreauClick(_ sender: Any) {
        symbole = "carreau"
        setSymbole()
    }
    
    @IBAction func ValiderClick(_ sender: Any) {
    
       enregistrerDonnees()
    }
    
    
    func enregistrerDonnees() {
        print("enregistrer donnees")
        
        self.present(alertController, animated: true, completion: nil)
        
        let params = ["type":"modifiersymbole", "userid":preferences.string(forKey: "userid") ?? "",  "symbole":symbole] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
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

                                print("call Controller_Lieux")
                                
                                self.preferences.set(self.symbole, forKey: "inscription_symbole")
                                self.preferences.synchronize()
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Controller_Lieux") as! Controller_Lieux
                                
                                
                                
                                if (self.wTitle != "Modifier Mon Envie")
                                {
                                    vc.wTitle = "Pour une rencontre vous êtes plutôt :"
                                }
                                self.present(vc, animated: true, completion: nil)

                            
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
