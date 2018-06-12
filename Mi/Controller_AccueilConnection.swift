//
//  Controller_AccueilConnection.swift
//  Timi_Test1
//
//  Created by Julien on 28/04/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP

import FacebookCore
import FacebookLogin

import FBSDKCoreKit
import FBSDKLoginKit

import Crashlytics

import FirebaseMessaging

class Controller_AccueilConnection: UIViewController {
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editPass: UITextField!

    @IBOutlet weak var BtnCrt: UIButton!
    @IBOutlet weak var BtnConnect: UIButton!
    
    var preferences : UserDefaults = UserDefaults.standard

    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)

        editEmail.layer.borderColor = PrimaryColor.cgColor
        editEmail.layer.borderWidth = 2.0
        editEmail.layer.cornerRadius = 5.0
        
        editPass.layer.borderColor = PrimaryColor.cgColor
        editPass.layer.borderWidth = 2.0
        editPass.layer.cornerRadius = 5.0
        
        BtnCrt.layer.borderColor = PrimaryColor.cgColor
        BtnCrt.layer.borderWidth = 2.0
        BtnCrt.layer.cornerRadius = 5.0
        
        BtnConnect.layer.borderColor = PrimaryColor.cgColor
        BtnConnect.layer.borderWidth = 2.0
        BtnConnect.layer.cornerRadius = 5.0

        /*
        editEmail.text = "daudiert2@wanadoo.fr"
        //editEmail.text = "daudiert@skyviewprod.com"
        editPass.text = "Zzt88300"
        */
        let button = UIButton(frame: CGRect(x: 1, y: 15, width: 90, height: 40))
        button.setTitleColor(PrimaryColor,  for: .normal)

        button.setTitle("Retour", for: .normal)
        button.addTarget(self, action: #selector(Retour), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func Retour () {

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Controller_Main") as! Controller_Main
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func BtnPerdu(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Controller_MdpOublie") as! Controller_MdpOublie
        self.present(vc, animated: true, completion: nil)

    }

    
    @IBAction func clickConnection(_ sender: Any) {
        let email = editEmail.text
        let pass = editPass.text
        
        if( email == "" || pass == "" ) {
            afficherPopup(title : "Action impossible", message : "Veuillez renseigner votre email et votre mot de passe")
        } else {
            if( Global().isConnectedToNetwork() == true ) {
                tacheConnection(email: email!, pass: pass!)
            } else {
                afficherPopup(title : "Action impossible", message : "Aucune connection internet")
            }
        }
    }
    
    @IBAction func BtnCrt(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "inscriptionEtape1") as! Controller_InscriptionEtape1
        self.present(vc, animated: true, completion: nil)

    }

    
    
    func tacheConnection(email : String, pass: String) {
        print("connection")
        
        self.present(alertController, animated: true, completion: nil)
        
        let params = ["type":"login", "email":email, "pass":pass, "token":Messaging.messaging().fcmToken ?? "null"] as [String : Any]

        print(params)

        
        
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
                            print("success 1")
                            
                            let data = json["data"] as! Dictionary<String,AnyObject>
                            
                            
                            
                            var wdatenaissance = data["datenaissance"] as! String
                           // if(wdatenaissance == "0000-00-00")
                            //{
                              //  wdatenaissance = "1995-01-01"
                            //}
                            
                            
                                self.preferences.set(data["id"], forKey: "userid")
                                self.preferences.set(email, forKey: "email")
                                self.preferences.set(pass, forKey: "pass")
                                self.preferences.set(data["photoprofil"], forKey: "photoprofil")
                                self.preferences.set(data["photoprofil_valide"], forKey: "photoprofil_valide")
                                self.preferences.set(data["prenom"], forKey: "prenom")
                                self.preferences.set(wdatenaissance, forKey: "datenaissance")
                                self.preferences.set(data["sexe"], forKey: "sexe")
                                
                                self.preferences.set(data["bonus_apple"], forKey: "bonus_apple")
                                self.preferences.set(data["bonus_facebook"], forKey: "bonus_facebook")
                                self.preferences.set(data["bonus_facebook5s"], forKey: "bonus_facebook5s")
                                self.preferences.synchronize()
                                
                                self.logUser(userid: data["id"] as! String, email: email)
                                self.alertController.dismiss(animated: true, completion: {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "pageAccueil") as! Controller_Accueil
                                    self.present(vc, animated: true, completion: nil)
                                })
                            
                        } else if json["success"] as! Int == 0 {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Connection impossible", message : "Email ou mot de passe incorrect")
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                            })                        }
                    } else {
                        self.alertController.dismiss(animated: true, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                        })                    }
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
    
    func color(from hexString : String) -> CGColor
    {
        if let rgbValue = UInt(hexString, radix: 16) {
            let red   =  CGFloat((rgbValue >> 16) & 0xff) / 255
            let green =  CGFloat((rgbValue >>  8) & 0xff) / 255
            let blue  =  CGFloat((rgbValue      ) & 0xff) / 255
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0).cgColor
        } else {
            return UIColor.black.cgColor
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
    
    func logUser(userid: String, email: String) {
        Crashlytics.sharedInstance().setUserEmail(email)
        Crashlytics.sharedInstance().setUserIdentifier(userid)
    }
}
