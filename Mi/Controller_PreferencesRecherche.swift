//
//  Controller_PreferencesRecherche.swift
//  Timi
//
//  Created by Julien on 18/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import TTRangeSlider
import SwiftHTTP

class Controller_PreferencesRecherche: UIViewController {
    @IBOutlet weak var sliderAge: TTRangeSlider!
    @IBOutlet weak var sliderDistance: TTRangeSlider!

    @IBOutlet weak var BtnValider: UIButton!
    @IBOutlet weak var BtnSymboles: UIButton!

    var agemin = 0
    var agemax = 0
    
    var distance = 0
    
    var symbole = ""
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    var preferences : UserDefaults = UserDefaults.standard
    
    let step: Float = 1

    var gotoSymb = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        initialisation()
        
        sliderAge.tintColorBetweenHandles = PrimaryColor
        sliderAge.tintColor = UIColor.gray
        sliderAge.handleColor = PrimaryColor
        sliderAge.lineHeight = 2.0
        
        sliderDistance.tintColorBetweenHandles = PrimaryColor
        sliderDistance.tintColor = UIColor.gray
        sliderDistance.handleColor = PrimaryColor
        sliderDistance.lineHeight = 2.0
        
        BtnValider.layer.borderColor = PrimaryColor.cgColor
        BtnValider.layer.borderWidth = 2.0
        BtnValider.layer.cornerRadius = 5.0

        BtnSymboles.layer.borderColor = PrimaryColor.cgColor
        BtnSymboles.layer.borderWidth = 2.0
        BtnSymboles.layer.cornerRadius = 5.0

        
        
        
        symbole = preferences.string(forKey: "inscription_symbole") ?? "coeur"

        let button = UIButton(frame: CGRect(x: 1, y: 15, width: 90, height: 40))
        button.setTitleColor(PrimaryColor,  for: .normal)
        
        button.setTitle("Retour", for: .normal)
        button.addTarget(self, action: #selector(Retour), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func Retour () {

        self.dismiss(animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    @IBAction func clickRetour(_ sender: Any) {
        
    }
    
    @IBAction func sexeValueChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
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
                                
                                self.sliderAge.selectedMinimum = Float(data["agemin"] as! String)!
                                self.sliderAge.selectedMaximum = Float(data["agemax"] as! String)!
                                
                                self.sliderDistance.selectedMaximum = Float(data["distancemax"] as! String)!
                                
                                
                                self.symbole = data["symbole"] as! String
                              
                            })
                        }
                    }
                } catch { }
            }
        } catch { }
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
    
    @IBAction func clickEnregistrer(_ sender: Any) {
        agemin = Int(sliderAge.selectedMinimum)
        agemax = Int(sliderAge.selectedMaximum)
        
        distance = Int(sliderDistance.selectedMaximum)
        
        gotoSymb = false
        
        print ("agemin : \(agemin)")
        print ("agemax : \(agemax)")
        print ("distance : \(distance)")
        print ("symbole : \(symbole)")

            if( Global().isConnectedToNetwork() == true ) {
                enregistrerDonnees()
            } else {
                self.afficherPopup(title : "Action impossible", message : "Aucune connection internet")
            }

    }

    @IBAction func clickEnregistrer_Symbole(_ sender: Any) {
        agemin = Int(sliderAge.selectedMinimum)
        agemax = Int(sliderAge.selectedMaximum)
        
        distance = Int(sliderDistance.selectedMaximum)
        
        gotoSymb = true
        
        print ("agemin : \(agemin)")
        print ("agemax : \(agemax)")
        print ("distance : \(distance)")
        print ("symbole : \(symbole)")
        
        if( Global().isConnectedToNetwork() == true ) {
            enregistrerDonnees()
        } else {
            self.afficherPopup(title : "Action impossible", message : "Aucune connection internet")
        }
    }
    
    func enregistrerDonnees() {
        print("enregistrer donnees")
        
        self.present(alertController, animated: true, completion: nil)
        
        let params = ["type":"modifierpreferences", "userid":preferences.string(forKey: "userid") ?? "", "agemin":String(agemin), "agemax": String(agemax), "distance":String(distance),  "symbole":symbole] as [String : Any]
        
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
                                
                                if (self.gotoSymb)
                                {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Controller_Symboles") as! Controller_Symboles
                                    self.present(vc, animated: true, completion: nil)

                                }
                                else
                                {
                                    self.dismiss(animated: true, completion: nil)

                                }

                                
                                

                            })
                        } else if json["success"] as! Int == 0 {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Connection impossible", message : "Email ou mot de passe incorrect")
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
    
    func getSexeFromInt( value : Int ) -> Int {
        switch value {
        case 0  :
            return 0
        case 1  :
            return 2
        case 2  :
            return 1
        default :
            return 2
        }
    }
    
    func afficherPopupFermable( title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Controller_Symboles") as! Controller_Symboles
            self.present(vc, animated: true, completion: nil)
        }

        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
