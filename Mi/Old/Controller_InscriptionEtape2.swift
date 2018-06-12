//
//  Controller_InscriptionEtape2.swift
//  Timi_Test1
//
//  Created by Julien on 03/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP

import MVHorizontalPicker

class Controller_InscriptionEtape2: UIViewController {
    var imageProfil : UIImage? = nil

    var preferences : UserDefaults = UserDefaults.standard
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    var emailvalide = -1
    
    @IBOutlet weak var pickerCouleurYeux: MVHorizontalPicker!
    @IBOutlet weak var pickerCouleurCheveux: MVHorizontalPicker!
    @IBOutlet weak var pickerLongueurCheveux: MVHorizontalPicker!
    @IBOutlet weak var pickerPhysique: MVHorizontalPicker!
    @IBOutlet weak var pickerTaille: MVHorizontalPicker!
    @IBOutlet weak var pickerStyle: MVHorizontalPicker!
    @IBOutlet weak var pickerOrigine: MVHorizontalPicker!
    @IBOutlet weak var pickerReligion: MVHorizontalPicker!
    @IBOutlet weak var pickerProfession: MVHorizontalPicker!
    @IBOutlet weak var pickerFleurChocolat: MVHorizontalPicker!
    @IBOutlet weak var pickerRDV: MVHorizontalPicker!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)

        pickerCouleurYeux.titles = [ "Noir", "Marron", "Ambre", "Noisette", "Marron-vert", "Marron-bleu", "Vert", "Bleu", "Turquoise", "Gris", "Vairons" ]
        pickerCouleurCheveux.titles = [ "Noir", "Brun", "Aubrun", "Châtain", "Roux", "Blond", "Blanc", "Chauve", "Rouge", "Rose", "Vert", "Bleu", "Gris" ]
        pickerLongueurCheveux.titles = [ "Rasés","Courts", "Mi-longs", "Longs" ]
        pickerPhysique.titles = [ "Mince", "Costaud", "Musclé", "Body-builder", "Enrobé", "Équilibré", "Sec" ]
        pickerTaille.titles = [ "1,40 m", "1,45 m", "1,50 m", "1,55 m", "1,60 m", "1,65 m", "1,70 m", "1,75 m", "1,80 m", "1,85 m", "1,90 m", "1,95 m", "2,00 m", "2,05 m", "2,10 m" ]
        pickerStyle.titles = [ "Classique", "BCBG", "Sportif", "Skateur", "Fashion", "Grunge", "Bobo Chic", "Hipster", "Costume", "Kiff kiff" ]
        pickerOrigine.titles = [ "Caucasien", "Afro", "Oriental", "Asiatique", "Métisse", "Eurasien", "Latin", "Antillais", "Indien" ]
        pickerReligion.titles = [ "Personnel", "Catholique", "Protestant", "Indou", "Juif", "Musulman", "Agnostique", "Athée", "Bouddhiste", "Autre" ]
        pickerProfession.titles = [ "Étudiant", "Employé", "Cadre", "Manager", "Ouvrier", "Indépendant", "Sans emploi" ]
        pickerFleurChocolat.titles = [ "Fleurs", "Chocolats" ]
        pickerRDV.titles = [ "Bar", "Restaurant", "Soirée", "Musée", "Cinéma" ]
        

        
    }
    
    override func viewDidAppear(_ animated: Bool) {

        if( Global().isConnectedToNetwork() == true ) {
        //    self.checkVerificationEmail()
        
        pickerCouleurYeux.setSelectedItemIndex(selectedItemIndex: pickerCouleurYeux.titles.index(of: preferences.string(forKey: "inscription_couleuryeux") ?? "") ?? 0, animated: true)
        pickerCouleurCheveux.setSelectedItemIndex(selectedItemIndex: pickerCouleurCheveux.titles.index(of: preferences.string(forKey: "inscription_couleurcheveux") ?? "") ?? 0, animated: true)
        pickerLongueurCheveux.setSelectedItemIndex(selectedItemIndex: pickerLongueurCheveux.titles.index(of: preferences.string(forKey: "inscription_longueurcheveux") ?? "") ?? 0, animated: true)
        pickerPhysique.setSelectedItemIndex(selectedItemIndex: pickerPhysique.titles.index(of: preferences.string(forKey: "inscription_physique") ?? "") ?? 0, animated: true)
        pickerTaille.setSelectedItemIndex(selectedItemIndex: pickerTaille.titles.index(of: preferences.string(forKey: "inscription_taille") ?? "") ?? 0, animated: true)
        pickerStyle.setSelectedItemIndex(selectedItemIndex: pickerStyle.titles.index(of: preferences.string(forKey: "inscription_style") ?? "") ?? 0, animated: true)
        pickerOrigine.setSelectedItemIndex(selectedItemIndex: pickerOrigine.titles.index(of: preferences.string(forKey: "inscription_origine") ?? "") ?? 0, animated: true)
        pickerReligion.setSelectedItemIndex(selectedItemIndex: pickerReligion.titles.index(of: preferences.string(forKey: "inscription_religion") ?? "") ?? 0, animated: true)
        pickerProfession.setSelectedItemIndex(selectedItemIndex: pickerProfession.titles.index(of: preferences.string(forKey: "inscription_profession") ?? "") ?? 0, animated: true)
        pickerFleurChocolat.setSelectedItemIndex(selectedItemIndex: pickerFleurChocolat.titles.index(of: preferences.string(forKey: "inscription_fleurchocolat") ?? "") ?? 0, animated: true)
        pickerRDV.setSelectedItemIndex(selectedItemIndex: pickerRDV.titles.index(of: preferences.string(forKey: "inscription_rdv") ?? "") ?? 0, animated: true)
        } else {
            self.afficherPopupErreur(title : "Action impossible", message : "Aucune connection internet")
        }
        
        
        print("Controller_InscriptionEtape2");
        
    }

    func checkVerificationEmail() {
        let params = ["type":"checkemail", "email":preferences.string(forKey: "inscription_email") ?? ""] as [String : Any]
        
        self.present(alertController, animated: true, completion: nil)

        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopupErreur(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    })
                    
                    return
                }
                
                print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        self.emailvalide = json["success"] as! Int
                        
                        if self.emailvalide == 0 {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopupErreur(title : "Action impossible", message : "Votre adresse email est déjà utilisée")
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        self.alertController.dismiss(animated: true, completion: {
                            self.afficherPopupErreur(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                        })
                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopupErreur(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    })
                }
            }
        } catch {
            self.alertController.dismiss(animated: true, completion: {
                self.afficherPopupErreur(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
            })
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func clickValiderEtape2(_ sender: Any)  {
        self.preferences.set(pickerCouleurYeux.titles[pickerCouleurYeux.selectedItemIndex], forKey: "inscription_couleuryeux")
        self.preferences.set(pickerCouleurCheveux.titles[pickerCouleurCheveux.selectedItemIndex], forKey: "inscription_couleurcheveux")
        self.preferences.set(pickerLongueurCheveux.titles[pickerLongueurCheveux.selectedItemIndex], forKey: "inscription_longueurcheveux")
        self.preferences.set(pickerPhysique.titles[pickerPhysique.selectedItemIndex], forKey: "inscription_physique")
        self.preferences.set(pickerTaille.titles[pickerTaille.selectedItemIndex], forKey: "inscription_taille")
        self.preferences.set(pickerStyle.titles[pickerStyle.selectedItemIndex], forKey: "inscription_style")
        self.preferences.set(pickerOrigine.titles[pickerOrigine.selectedItemIndex], forKey: "inscription_origine")
        self.preferences.set(pickerReligion.titles[pickerReligion.selectedItemIndex], forKey: "inscription_religion")
        self.preferences.set(pickerProfession.titles[pickerProfession.selectedItemIndex], forKey: "inscription_profession")
        self.preferences.set(pickerFleurChocolat.titles[pickerFleurChocolat.selectedItemIndex], forKey: "inscription_fleurchocolat")
        self.preferences.set(pickerRDV.titles[pickerRDV.selectedItemIndex], forKey: "inscription_rdv")
        self.preferences.synchronize()
        sendinscriptionEtape1()

        
        
        
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        self.preferences.set(pickerCouleurYeux.titles[pickerCouleurYeux.selectedItemIndex], forKey: "inscription_couleuryeux")
        
        self.preferences.set(pickerCouleurCheveux.titles[pickerCouleurCheveux.selectedItemIndex], forKey: "inscription_couleurcheveux")
        
        self.preferences.set(pickerLongueurCheveux.titles[pickerLongueurCheveux.selectedItemIndex], forKey: "inscription_longueurcheveux")
        
        self.preferences.set(pickerPhysique.titles[pickerPhysique.selectedItemIndex], forKey: "inscription_physique")
        
        self.preferences.set(pickerTaille.titles[pickerTaille.selectedItemIndex], forKey: "inscription_taille")
        
        self.preferences.set(pickerStyle.titles[pickerStyle.selectedItemIndex], forKey: "inscription_style")
        
        self.preferences.set(pickerOrigine.titles[pickerOrigine.selectedItemIndex], forKey: "inscription_origine")
        
        self.preferences.set(pickerReligion.titles[pickerReligion.selectedItemIndex], forKey: "inscription_religion")
        
        self.preferences.set(pickerProfession.titles[pickerProfession.selectedItemIndex], forKey: "inscription_profession")
        
        self.preferences.set(pickerFleurChocolat.titles[pickerFleurChocolat.selectedItemIndex], forKey: "inscription_fleurchocolat")
        
        self.preferences.set(pickerRDV.titles[pickerRDV.selectedItemIndex], forKey: "inscription_rdv")
        
        self.preferences.synchronize()
    
        if emailvalide == 1 {
            return true
        }
        else if emailvalide == 0 {
            afficherPopupErreur(title : "Action impossible", message : "Votre adresse email est déjà utilisée")
            return false
        } else {
            afficherPopup(title : "Action impossible", message : "Vérification de l'adresse email en cours")
            return false
        }
    
        return true

    
    }
    
    // TED
    func sendinscriptionEtape1() {
        print("etape 1")
        
        var params = [String : Any]()
        params["type"] = "modifierprofil2_ios"
        params["userid"] = preferences.string(forKey: "userid") ?? ""
        params["couleuryeux"] = preferences.string(forKey: "inscription_couleuryeux") ?? ""
        params["couleurcheveux"] = preferences.string(forKey: "inscription_couleurcheveux") ?? ""
        params["longueurcheveux"] = preferences.string(forKey: "inscription_longueurcheveux") ?? ""
        params["physique"] = preferences.string(forKey: "inscription_physique") ?? ""
        params["taille"] = preferences.string(forKey: "inscription_taille") ?? ""
        params["style"] = preferences.string(forKey: "inscription_style") ?? ""
        params["origine"] = preferences.string(forKey: "inscription_origine") ?? ""
        params["religion"] = preferences.string(forKey: "inscription_religion") ?? ""
        params["profession"] = preferences.string(forKey: "inscription_profession") ?? ""
        params["fleurschocolats"] = preferences.string(forKey: "inscription_fleurchocolat") ?? ""
        params["lieuprefere"] = preferences.string(forKey: "inscription_rdv") ?? ""
        self.present(alertController, animated: true, completion: nil)
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    })
                    
                    return
                }
                
                print("=> response = " , response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if ( json["success"] as! Int == 1 ) {
                            self.preferences.set(json["userid"], forKey: "userid")
                            self.preferences.synchronize()
                            self.alertController.dismiss(animated: true, completion: {
                                
                                self.afficherPopupFermable(title : "Profil modifié", message : "")

                            })
                        } else if ( json["success"] as! Int == 2 ) {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Votre adresse email est déjà utilisée")
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
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let insEtape3 = segue.destination as? Controller_InscriptionEtape3 {
            insEtape3.imageProfil = imageProfil!
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
    
    func afficherPopupErreur( title : String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func afficherPopupFermable( title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.dismiss(animated: true)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
