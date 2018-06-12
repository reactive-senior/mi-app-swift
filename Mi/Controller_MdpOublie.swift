//
//  Controller_MdpOublie.swift
//  Timi_Test1
//
//  Created by Julien on 12/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP

class Controller_MdpOublie: UIViewController {
    var etape = 1
    var code = 0
    var email = ""
    
    @IBOutlet weak var edit: UITextField!
    @IBOutlet weak var BtnValider: UIButton!
    @IBOutlet weak var BtnRetour: UIButton!
    
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()

        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        edit.layer.borderColor = PrimaryColor.cgColor
        edit.layer.borderWidth = 2.0
        edit.layer.cornerRadius = 5.0
        
        BtnValider.layer.borderColor = PrimaryColor.cgColor
        BtnValider.layer.borderWidth = 2.0
        BtnValider.layer.cornerRadius = 5.0

        BtnRetour.layer.borderColor = PrimaryColor.cgColor
        BtnRetour.layer.borderWidth = 1.0
        BtnRetour.layer.cornerRadius = 5.0

        
    }

    override func viewDidAppear(_ animated: Bool) {
        self.initialiser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initialiser() {
        DispatchQueue.main.async(execute: {
            if( self.etape == 1 ) {
                self.edit.text = ""
                
                self.edit.placeholder = "Votre adresse email"
            } else if( self.etape == 2 ) {
                self.edit.text = ""
                
                self.edit.placeholder = "Code de validation"
            } else if( self.etape == 3 ) {
                self.edit.text = ""
                
                self.edit.placeholder = "Nouveau mot de passe"
                self.edit.isSecureTextEntry = true
            }
        });
    }
    
    
    @IBAction func btnclickretour(_ sender: Any) {
        print("retour")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickValider(_ sender: Any) {
        if( etape == 1 ) {
            if( isValidEmail(testStr: edit.text!) ) {
                if( Global().isConnectedToNetwork() == true ) {
                    self.code = self.randomNumberBetween(min:100000, max: 999999)
                    self.email = edit.text!
                    
                    self.sendMail()
                } else {
                    self.afficherPopup(title : "Action impossible", message : "Aucune connection internet")
                }
            } else {
                self.afficherPopup(title:"Action impossible", message:"Adresse email invalide")
            }
        } else if( etape == 2 ) {
            if( String(code) == edit.text! ) {
                self.afficherPopup(title:"Code correct", message:"Vous pouvez désormais renseigner votre nouveau mot de passe")

                self.etape = 3
                self.initialiser()
            } else {
                self.afficherPopup(title:"Action impossible", message:"Code incorrect")
            }
        } else if( etape == 3 ) {
            if( (edit.text?.characters.count)! < 6 ) {
                self.afficherPopup(title:"Action impossible", message:"Mot de passe trop court")
            } else {
                if( Global().isConnectedToNetwork() == true ) {
                    self.changerMdp()
                } else {
                    self.afficherPopup(title : "Action impossible", message : "Aucune connection internet")
                }
            }
        }
    }
    
    func changerMdp() {
        let params = ["type":"mdpoubliechanger", "email":email, "pass":edit.text!] as [String : Any]
        
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
                
                print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if ( json["success"] as! Int == 1 ) {
                            DispatchQueue.main.async(execute: {
                                self.alertController.dismiss(animated: true, completion: {
                                    self.afficherPopupFermable(title:"Mot de passe modifié", message:"Votre changement de mot de passe est bien effectué")
                                })
                            })
                        } else {
                            DispatchQueue.main.async(execute: {
                                self.alertController.dismiss(animated: true, completion: {
                                    self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                                })
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

    func sendMail() {
        let params = ["type":"mdpoubliemail", "email":edit.text!, "code":String(code)] as [String : Any]
        
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
                
                print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {                        
                        if ( json["success"] as! Int == 1 ) {
                            DispatchQueue.main.async(execute: {
                                self.alertController.dismiss(animated: true, completion: {
                                    self.etape = 2
                                    self.initialiser()
                                    
                                    self.afficherPopup(title : "Code envoyé", message : "Un email vous a été envoyé avec un code personnel. Entrez ce code pour pouvoir réinitialiser votre mot de passe.")
                                })
                            })
                        } else if ( json["success"] as! Int == 2 ) {
                            DispatchQueue.main.async(execute: {
                                self.alertController.dismiss(animated: true, completion: {
                                    self.afficherPopup(title : "Action impossible", message : "Aucun compte ne possède cette adresse email")
                                })
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
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func randomNumberBetween(min: Int, max: Int)-> Int{
        return Int(arc4random_uniform(UInt32(min)) + UInt32(max));
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
