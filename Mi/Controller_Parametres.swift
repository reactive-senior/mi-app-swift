//
//  Controller_Parametres.swift
//  Timi
//
//  Created by Julien on 18/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP

class Controller_Parametres: UIViewController {
    var preferences : UserDefaults = UserDefaults.standard
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
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
    
    @IBAction func clickCGU(_ sender: Any) {
        UIApplication.shared.open(URL(string: "http://mi-app.fr/CGU-MI.pdf")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func clickDeconnection(_ sender: Any) {
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)

        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        
        self.preferences.set(true, forKey: "first")
        
        self.preferences.synchronize()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "controllerAccueilConnection") as! Controller_AccueilConnection
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func clickRetour(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickSupprimerProfil(_ sender: Any) {
        let alert = UIAlertController(title: "Êtes-vous sûr de vouloir\nsupprimer votre compte ?", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { (action) in
            self.supprimerProfil()
        }))
        
        alert.addAction(UIAlertAction(title: "Non", style: .default, handler: { (action) in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func supprimerProfil() {
        self.present(alertController, animated: true, completion: nil)
        
        let params = ["type":"supprimer_mon_compte", "userid":preferences.string(forKey: "userid") ?? ""] as [String : Any]
        
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
                                self.afficherPopupFermante(title : "Compte supprimé", message : "Votre compte vient d'être supprimé")
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
    
    @IBAction func clickDonneesPerso(_ sender: Any) {
        DonneesPerso()
    }

    func DonneesPerso() {
        self.present(alertController, animated: true, completion: nil)
        
        let params = ["type":"DonneesPerso", "userid":preferences.string(forKey: "userid") ?? ""] as [String : Any]
        
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
                                self.afficherPopup2(title : "Données personnelles", message : "Votre demande a bien été prise en compte vous recevrez sous peu vos données personnelles ")
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
    
    func afficherPopupFermante( title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            
            let appDomain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "controllerAccueilConnection") as! Controller_AccueilConnection
            self.present(vc, animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
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
    
    func afficherPopup2( title : String, message : String) {
        let text = message
        let TitleString = NSAttributedString(string: title, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18), NSAttributedStringKey.foregroundColor : PrimaryColor])
        
        
        let alert = UIAlertController(title: "MI", message: "", preferredStyle: .alert)
        
        alert.setValue(TitleString, forKey: "attributedTitle")
        
        let textView = UITextView()
        textView.text = text
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        textView.isUserInteractionEnabled = false
        textView.isEditable = false
        let controller = UIViewController()
        textView.frame = controller.view.frame
        controller.view.addSubview(textView)
        alert.setValue(controller, forKey: "contentViewController")
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (AppDelegate.getCurrentViewController()?.view.frame.height)! * 0.3)
        alert.view.addConstraint(height)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.view.tintColor = PrimaryColor
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    

    
    
    
    
}
