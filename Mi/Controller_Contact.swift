//
//  Controller_Contact.swift
//  Timi
//
//  Created by Julien on 18/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP

class Controller_Contact: UIViewController {
    @IBOutlet weak var editMessage: UITextField!
    @IBOutlet weak var labelversion: UILabel!

    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    var preferences : UserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        var wTmp = ""
        if let shortversion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.labelversion.text = "Version " + shortversion
            wTmp = "Version " + shortversion
        }
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.labelversion.text = "" + wTmp + " build " + version
        }
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        alertController.view.addSubview(spinnerIndicator)
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickEnvoyer(_ sender: Any) {
        if( editMessage.text! == "" ) {
            self.afficherPopup( title : "Action impossible", message : "Vous n'avez pas écrit de message")
        } else {
            if( Global().isConnectedToNetwork() == true ) {
                self.envoyerMessage()
            } else {
                self.afficherPopup(title : "Action impossible", message : "Aucune connection internet")
            }
        }
    }
    
    func envoyerMessage() {
        let params = ["type":"send_message", "userid":preferences.string(forKey: "userid") ?? "", "message":editMessage.text!] as [String : Any]
        
        self.present(alertController, animated: true, completion: nil)
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_global.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    })
                    
                    return
                }
                
                print(response.text!)
                
                DispatchQueue.main.async(execute: {
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopupFermable(title:"Message envoyé", message:"Votre message a bien été transmis aux administrateurs")
                    })
                })
            }
        } catch {
            self.alertController.dismiss(animated: true, completion: {
                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez rééssayer")
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
