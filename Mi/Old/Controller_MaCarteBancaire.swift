//
//  Controller_MaCarteBancaire.swift
//  Timi
//
//  Created by Julien on 17/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit

class Controller_MaCarteBancaire: UIViewController {
    @IBOutlet weak var editNumeroCarte: UITextField!
    @IBOutlet weak var editMM: UITextField!
    @IBOutlet weak var editAA: UITextField!
    @IBOutlet weak var editCVC: UITextField!

    var preferences : UserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        print("page ok")
        
        //initialisation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*func initialisation() {
        print("init")
        
        if( preferences.string(forKey: "card_number") != "" ) {
            print("ok")
            
            editNumeroCarte.text = "************"+preferences.string(forKey: "card_number")!.substring(from: 12)
            editMM.text = preferences.string(forKey: "card_month")!
            editAA.text = preferences.string(forKey: "card_year")!
            editCVC.text = ""
        }
    }*/
    
    @IBAction func clickSupprimerDonnees(_ sender: Any) {
        self.preferences.set("", forKey: "card_number")
        self.preferences.set("", forKey: "card_month")
        self.preferences.set("", forKey: "card_year")
        self.preferences.set("", forKey: "card_cvc")
        
        self.preferences.synchronize()
     
        self.afficherPopup(title:"Données supprimées", message:"Vos données ont bien été effacées de vos préférences")
        
        editNumeroCarte.text = ""
        editMM.text = ""
        editAA.text = ""
        editCVC.text = ""
    }
    
    @IBAction func clickRetour(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickSauvegarder(_ sender: Any) {
        if( editNumeroCarte.text! == "" || editMM.text! == "" || editAA.text! == "" || editCVC.text! == "" ) {
            self.afficherPopup(title: "Action impossible",message: "Veuillez remplir tous les champs")
        } else if( editNumeroCarte.text!.characters.count != 16 ) {
            self.afficherPopup(title: "Action impossible",message: "Numéro de carte invalide")
        } else if( editMM.text!.characters.count != 2 ) {
            self.afficherPopup(title: "Action impossible",message: "Mois invalide (format MM)")
        } else if( editAA.text!.characters.count != 2 ) {
            self.afficherPopup(title: "Action impossible",message: "Année invalide (format AA)")
        } else if( editCVC.text!.characters.count != 3 ) {
            self.afficherPopup(title: "Action impossible",message: "CVC invalide (format CVC)")
        } else {
            self.preferences.set(editNumeroCarte.text!, forKey: "card_number")
            self.preferences.set(editMM.text!, forKey: "card_month")
            self.preferences.set(editAA.text!, forKey: "card_year")
            self.preferences.set(editCVC.text!, forKey: "card_cvc")
            
            self.preferences.synchronize()
            
            self.afficherPopup(title:"Données sauvegardées", message: "Vos données ont bien été sauvegardées")

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
