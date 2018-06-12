//
//  Controller_Main.swift
//  Mi
//
//  Created by TED on 14/02/2018.
//  Copyright © 2018 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP



class Controller_Lieux: UIViewController {

    var preferences : UserDefaults = UserDefaults.standard

    @IBOutlet weak var Cat1: UIButton!
    @IBOutlet weak var Cat2: UIButton!
    @IBOutlet weak var Cat3: UIButton!

    @IBOutlet weak var SsCat1: UIButton!
    @IBOutlet weak var SsCat2: UIButton!
    @IBOutlet weak var SsCat3: UIButton!
    @IBOutlet weak var SsCat4: UIButton!
    @IBOutlet weak var SsCat5: UIButton!
    @IBOutlet weak var SsCat6: UIButton!
    @IBOutlet weak var SsCat7: UIButton!
    @IBOutlet weak var SsCat8: UIButton!
    @IBOutlet weak var SsCat9: UIButton!

    @IBOutlet weak var CatLib1: UILabel!
    @IBOutlet weak var CatLib2: UILabel!

    @IBOutlet weak var SsCatLib: UILabel!
    @IBOutlet weak var BtnValider: UIButton!

    @IBOutlet weak var uiTitle: UILabel!
    var wTitle = "Modifier Mon Lieu"


    let CatLib1Bar = "#Bar :"
    let CatLib1Restau = "#Restaurant"
    let CatLib1Sortie = "#Sortie"
    
    let CatLib2Bar = "S'hydrater c'est bien à 2 c'est mieux !"
    let CatLib2Restau = "Pour partager un repas pour commencer…"
    let CatLib2Sortie = "Pour se divertir"
    
    let ssCatLibBar1 = "#Autour d'un cocktail"
    let ssCatLibBar2 = "#Autour d'un jus de fruits"
    let ssCatLibBar3 = "#Autour d'un verre de vin"
    let ssCatLibBar4 = "#Autour d'une bière"
    let ssCatLibBar5 = "#Autour d'un thé"
    let ssCatLibBar6 = "#Musical / culturel"

    let ssCatLibRestau1 = "#Cuisine Française"
    let ssCatLibRestau2 = "#Spécialité de la mer"
    let ssCatLibRestau3 = "#Cuisine Asiatique"
    let ssCatLibRestau4 = "#Cuisine Japonaise"
    let ssCatLibRestau5 = "#Cuisine Veggie"
    let ssCatLibRestau6 = "#Cuisine Oriental"
    let ssCatLibRestau7 = "#Street food"
    let ssCatLibRestau8 = "#Cuisine Italienne"
    let ssCatLibRestau9 = "#Cuisine Exotique"
    
    let ssCatLibSortie1 = "#Devant une pièce"
    let ssCatLibSortie2 = "#A une soirée"
    
    var CatLib1Array = [String]()
    var CatLib2Array = [String]()

    var ssCatLib1Array = [String]()
    var ssCatLib2Array = [String]()
    var ssCatLib3Array = [String]()

    var ssCatImg1Array = [String]()
    var ssCatImg2Array = [String]()
    var ssCatImg3Array = [String]()
    
    var iCat = 1
    var iSsCat = 1

    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uiTitle.text = wTitle
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()

        Cat1.layer.borderColor = PrimaryColor.cgColor
        Cat1.layer.borderWidth = 2.0
        Cat1.layer.cornerRadius = 3.0
        self.Cat1.setImage(UIImage(named: "cat_bar"), for: .normal)
        
        Cat2.layer.borderColor = PrimaryColor.cgColor
        Cat2.layer.borderWidth = 1.0
        Cat2.layer.cornerRadius = 3.0
        self.Cat2.setImage(UIImage(named: "cat_restaurant"), for: .normal)

        Cat3.layer.borderColor = PrimaryColor.cgColor
        Cat3.layer.borderWidth = 1.0
        Cat3.layer.cornerRadius = 3.0
        self.Cat3.setImage(UIImage(named: "cat_sorties"), for: .normal)

        CatLib1Array = [CatLib1Bar, CatLib1Restau, CatLib1Sortie]
        CatLib1.text = CatLib1Array[0]
        
        CatLib2Array = [CatLib2Bar, CatLib2Restau, CatLib2Sortie]
        CatLib2.text = CatLib2Array[0]

        ssCatLib1Array = [ssCatLibBar1, ssCatLibBar2, ssCatLibBar3, ssCatLibBar4, ssCatLibBar5, ssCatLibBar6]
        ssCatLib2Array = [ssCatLibRestau1, ssCatLibRestau2, ssCatLibRestau3,ssCatLibRestau4, ssCatLibRestau5, ssCatLibRestau6,ssCatLibRestau7, ssCatLibRestau8, ssCatLibRestau9]
        ssCatLib3Array = [ssCatLibSortie1, ssCatLibSortie2]
        
        ssCatImg1Array = ["bar_1_cocktail", "bar_2_jus_de_fruits", "bar_3_vin", "bar_4_biere.png", "bar_5_thes", "bar_6_musical_culturel"]
        ssCatImg2Array = ["resto_1_Francais", "resto_2_Fruits-de-mer", "resto_3_Asiatique", "resto_4_Japonnais", "resto_5_Veggie", "resto_6_Oriental", "resto_7._Street-food", "resto_8_Italien", "resto_9_Exotique"]
        ssCatImg3Array = ["Sortie_1_Theatre", "Sortie_2_Soirée"]
        
        SsCatLib.text = ssCatLib1Array[0]

        SsCat1.setImage(UIImage(named: ssCatImg1Array[0]), for: .normal)        
        SsCat2.setImage(UIImage(named: ssCatImg1Array[1]), for: .normal)
        SsCat3.setImage(UIImage(named: ssCatImg1Array[2]), for: .normal)
        SsCat4.setImage(UIImage(named: ssCatImg1Array[3]), for: .normal)
        SsCat5.setImage(UIImage(named: ssCatImg1Array[4]), for: .normal)
        SsCat6.setImage(UIImage(named: ssCatImg1Array[5]), for: .normal)

        SsCat7.isHidden = true
        SsCat8.isHidden = true
        SsCat9.isHidden = true

        SsCat1.layer.borderColor = PrimaryColor.cgColor
        SsCat2.layer.borderColor = PrimaryColor.cgColor
        SsCat3.layer.borderColor = PrimaryColor.cgColor
        SsCat4.layer.borderColor = PrimaryColor.cgColor
        SsCat5.layer.borderColor = PrimaryColor.cgColor
        SsCat6.layer.borderColor = PrimaryColor.cgColor
        SsCat7.layer.borderColor = PrimaryColor.cgColor
        SsCat8.layer.borderColor = PrimaryColor.cgColor
        SsCat9.layer.borderColor = PrimaryColor.cgColor

        SsCat1.layer.borderWidth = 1.0
        SsCat2.layer.borderWidth = 0.0
        SsCat3.layer.borderWidth = 0.0
        SsCat4.layer.borderWidth = 0.0
        SsCat5.layer.borderWidth = 0.0
        SsCat6.layer.borderWidth = 0.0
        SsCat7.layer.borderWidth = 0.0
        SsCat8.layer.borderWidth = 0.0
        SsCat9.layer.borderWidth = 0.0

        SsCat1.layer.cornerRadius = 3.0
        SsCat2.layer.cornerRadius = 3.0
        SsCat3.layer.cornerRadius = 3.0
        SsCat4.layer.cornerRadius = 3.0
        SsCat5.layer.cornerRadius = 3.0
        SsCat6.layer.cornerRadius = 3.0
        SsCat7.layer.cornerRadius = 3.0
        SsCat8.layer.cornerRadius = 3.0
        SsCat9.layer.cornerRadius = 3.0
        

        var wCat = preferences.integer(forKey: "inscription_iCat")
        if (wCat == 0)
        {
            wCat = 1
        }
        var wSsCat = preferences.integer(forKey: "inscription_iSsCat")
        if (wSsCat == 0)
        {
            wSsCat = 1
        }
        iCat = 1
        iSsCat = 1

        initialisation()
        print ("wCat " + String(wCat) + " wSsCat " + String(wSsCat))
        
        SetCat(wTag: wCat)
        SetssCat(wTag: wSsCat)

        BtnValider.layer.borderColor = PrimaryColor.cgColor
        BtnValider.layer.borderWidth = 2.0
        BtnValider.layer.cornerRadius = 5.0

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
                                var wCat = Int(data["lieu_cat"] as! String)!
                                var wSsCat = Int(data["lieu_sscat"] as! String)!
                                

                                if (wCat == 0)
                                {
                                    wCat = 1
                                }

                                if (wSsCat == 0)
                                {
                                    wSsCat = 1
                                }

                                
                                self.SetCat(wTag: wCat)
                                self.SetssCat(wTag: wSsCat)

                            })
                        }
                    }
                } catch { }
            }
        } catch { }
    }
    
    @IBAction func CatClick(_ sender: UIButton) {
        let wTag = sender.tag
        SetCat(wTag: wTag)
    }
    
    func SetCat(wTag: Int) {

        
        print ("wTag " + String(wTag) + " iCat " + String(iCat))

        
        if (iCat == wTag)
        {
            print ("wTag return")
            return
        }
        iCat = wTag
        print ("Set iCat " + String(iCat))

        switch wTag {
        case 1:
            CatLib1.text = CatLib1Array[0]
            CatLib2.text = CatLib2Array[0]

            Cat1.layer.borderWidth = 2.0
            Cat2.layer.borderWidth = 1.0
            Cat3.layer.borderWidth = 1.0

            SsCat1.isHidden = false
            SsCat2.isHidden = false
            SsCat3.isHidden = false
            SsCat4.isHidden = false
            SsCat5.isHidden = false
            SsCat6.isHidden = false
            SsCat7.isHidden = true
            SsCat8.isHidden = true
            SsCat9.isHidden = true

            SsCatLib.text = ssCatLib1Array[0]

            SsCat1.setImage(UIImage(named: ssCatImg1Array[0]), for: .normal)
            SsCat2.setImage(UIImage(named: ssCatImg1Array[1]), for: .normal)
            SsCat3.setImage(UIImage(named: ssCatImg1Array[2]), for: .normal)
            SsCat4.setImage(UIImage(named: ssCatImg1Array[3]), for: .normal)
            SsCat5.setImage(UIImage(named: ssCatImg1Array[4]), for: .normal)
            SsCat6.setImage(UIImage(named: ssCatImg1Array[5]), for: .normal)

            break;

        case 2:
            CatLib1.text = CatLib1Array[1]
            CatLib2.text = CatLib2Array[1]
            
            Cat1.layer.borderWidth = 1.0
            Cat2.layer.borderWidth = 2.0
            Cat3.layer.borderWidth = 1.0

            SsCat1.isHidden = false
            SsCat2.isHidden = false
            SsCat3.isHidden = false
            SsCat4.isHidden = false
            SsCat5.isHidden = false
            SsCat6.isHidden = false
            SsCat7.isHidden = false
            SsCat8.isHidden = false
            SsCat9.isHidden = false


            SsCatLib.text = ssCatLib2Array[0]

            
            SsCat1.setImage(UIImage(named: ssCatImg2Array[0]), for: .normal)
            SsCat2.setImage(UIImage(named: ssCatImg2Array[1]), for: .normal)
            SsCat3.setImage(UIImage(named: ssCatImg2Array[2]), for: .normal)
            SsCat4.setImage(UIImage(named: ssCatImg2Array[3]), for: .normal)
            SsCat5.setImage(UIImage(named: ssCatImg2Array[4]), for: .normal)
            SsCat6.setImage(UIImage(named: ssCatImg2Array[5]), for: .normal)
            SsCat7.setImage(UIImage(named: ssCatImg2Array[6]), for: .normal)
            SsCat8.setImage(UIImage(named: ssCatImg2Array[7]), for: .normal)
            SsCat9.setImage(UIImage(named: ssCatImg2Array[8]), for: .normal)

            break;

        case 3:
            CatLib1.text = CatLib1Array[2]
            CatLib2.text = CatLib2Array[2]
            
            Cat1.layer.borderWidth = 1.0
            Cat2.layer.borderWidth = 1.0
            Cat3.layer.borderWidth = 2.0

            SsCat1.isHidden = false
            SsCat2.isHidden = false
            SsCat3.isHidden = true
            SsCat4.isHidden = true
            SsCat5.isHidden = true
            SsCat6.isHidden = true
            SsCat7.isHidden = true
            SsCat8.isHidden = true
            SsCat9.isHidden = true


            SsCatLib.text = ssCatLib3Array[0]
            
            SsCat1.setImage(UIImage(named: ssCatImg3Array[0]), for: .normal)
            SsCat2.setImage(UIImage(named: ssCatImg3Array[1]), for: .normal)

            
            break;

            
        default:
            break;
        }

        SsCat1.layer.borderWidth = 1.0
        SsCat2.layer.borderWidth = 0.0
        SsCat3.layer.borderWidth = 0.0
        SsCat4.layer.borderWidth = 0.0
        SsCat5.layer.borderWidth = 0.0
        SsCat6.layer.borderWidth = 0.0
        SsCat7.layer.borderWidth = 0.0
        SsCat8.layer.borderWidth = 0.0
        SsCat9.layer.borderWidth = 0.0

        
        iSsCat = 1
        
        
    }

    @IBAction func ssCatClick(_ sender: UIButton) {
        let wTag = sender.tag
         SetssCat(wTag: wTag)
    }
        
      func SetssCat(wTag: Int) {

        if (iSsCat == wTag)
        {
            return
        }
        
        
        iSsCat = wTag

        SsCat1.layer.borderWidth = (wTag == 1) ? 1 : 0
        SsCat2.layer.borderWidth = (wTag == 2) ? 1 : 0
        SsCat3.layer.borderWidth = (wTag == 3) ? 1 : 0
        SsCat4.layer.borderWidth = (wTag == 4) ? 1 : 0
        SsCat5.layer.borderWidth = (wTag == 5) ? 1 : 0
        SsCat6.layer.borderWidth = (wTag == 6) ? 1 : 0
        SsCat7.layer.borderWidth = (wTag == 7) ? 1 : 0
        SsCat8.layer.borderWidth = (wTag == 8) ? 1 : 0
        SsCat9.layer.borderWidth = (wTag == 9) ? 1 : 0

    
        switch iCat {
        case 1:
            SsCatLib.text = ssCatLib1Array[wTag-1]
            break;
            
        case 2:
            SsCatLib.text = ssCatLib2Array[wTag-1]
            break;
            
        case 3:
            SsCatLib.text = ssCatLib3Array[wTag-1]
            break;
            
        default:
            break;
        }

    }


    @IBAction func ValiderClick(_ sender: Any) {
    enregistrerDonnees()

    
    }
    
    func enregistrerDonnees() {
        print("enregistrer donnees")
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
        let params = ["type":"modifierlieu", "userid":preferences.string(forKey: "userid") ?? "",  "lieu_cat":iCat , "lieu_sscat":iSsCat ] as [String : Any]
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

                                self.preferences.set(self.iCat, forKey: "inscription_iCat")
                                self.preferences.set(self.iSsCat, forKey: "inscription_iSsCat")
                                self.preferences.synchronize()
                                
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "pageAccueil") as! Controller_Accueil
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
