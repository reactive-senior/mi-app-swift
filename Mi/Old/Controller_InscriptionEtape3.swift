//
//  Controller_InscriptionEtape3.swift
//  Timi_Test1
//
//  Created by Julien on 03/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP

class Controller_InscriptionEtape3: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var preferences : UserDefaults = UserDefaults.standard

    var imageProfil : UIImage? = nil
    var imageSelfie : UIImage? = nil
    @IBOutlet weak var imgSelfie: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var code : Int = 123456

    var emailsend : Bool = false
    
    @IBOutlet weak var labelCGU: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        imgSelfie.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgSelfieTapped(tapGestureRecognizer:))))
        
        labelCGU.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelCGUTapped(tapGestureRecognizer:))))
    }

    override func viewDidAppear(_ animated: Bool) {
        if( !emailsend ) {
            if( Global().isConnectedToNetwork() == true ) {
                code = self.randomNumberBetween(min:100000, max: 999999)
            
                self.checkEmailSendCode()
            } else {
                self.afficherPopupErreur(title : "Action impossible", message : "Aucune connection internet")
            }
        }
    }
    
    func randomNumberBetween(min: Int, max: Int)-> Int{
        return Int(arc4random_uniform(UInt32(min)) + UInt32(max));
    }
    
    func checkEmailSendCode() {
        let params = ["type":"sendcodeemail", "email":preferences.string(forKey: "inscription_email") ?? "", "code":String(code)] as [String : Any]

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
                        if ( json["success"] as! Int == 1 ) {
                            self.emailsend = true
                            
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Code envoyé", message : "Un email avec un code personnel vient de vous être envoyé")
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopupErreur(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                            })
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
    
    @IBAction func clickValider(_ sender: Any) {
        if( imageProfil == nil || imageSelfie == nil ) {
            self.afficherPopup(title: "Action impossible", message: "Veuillez fournir une photo")
        } else {
            if( Global().isConnectedToNetwork() == true ) {
                self.sendinscriptionEtape1()
            } else {
                self.afficherPopupErreur(title : "Action impossible", message : "Aucune connection internet")
            }
        }
    }
    
    func sendinscriptionEtape1() {
        print("etape 1")
        
        var params = [String : Any]()
        
        params["type"] = "sendinscription"
        params["prenom"] = preferences.string(forKey: "inscription_prenom") ?? ""
        params["email"] = preferences.string(forKey: "inscription_email") ?? ""
        params["pass"] = preferences.string(forKey: "inscription_pass") ?? ""
        params["datenaissance"] = preferences.string(forKey: "inscription_datenaissance") ?? ""
        params["sexe"] = preferences.string(forKey: "inscription_sexe") ?? ""
        params["sexualite"] = preferences.string(forKey: "inscription_sexualite") ?? ""
        params["symbole"] = preferences.string(forKey: "inscription_symbole") ?? ""
        params["code"] = String(code)
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
        params["filmprefere"] = ""
        params["musiqueprefere"] = ""
        params["lieuprefere"] = preferences.string(forKey: "inscription_rdv") ?? ""
        params["fbid"] = preferences.string(forKey: "fbid") ?? ""

        alertController =  UIAlertController(title: nil, message: "Enregistrement\n1/3\n", preferredStyle: .alert)

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
                
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if ( json["success"] as! Int == 1 ) {
                            self.preferences.set(json["userid"], forKey: "userid")
                            
                            self.preferences.synchronize()
                            
                            self.alertController.dismiss(animated: true, completion: {
                                self.sendinscriptionEtape2()
                            })
                        } else if ( json["success"] as! Int == 2 ) {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Votre adresse email est déjà utilisée")
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible ", message : "Une erreur est survenue, veuillez réessayer")
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

    func sendinscriptionEtape2() {
        print("etape 2")
        
        let imageData:NSData = UIImagePNGRepresentation(imageProfil!)! as NSData

        let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
        
        var params = [String : Any]()
        
        params["type"] = "sendimageprofil"
        params["userid"] = preferences.string(forKey: "userid") ?? ""
        params["imageprofil"] = strBase64

        alertController =  UIAlertController(title: nil, message: "Enregistrement\n2/3\n", preferredStyle: .alert)

        self.present(alertController, animated: true, completion: nil)

        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.alertController.dismiss(animated: true, completion: {
                        self.alertController.dismiss(animated: true, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                        })
                    })
                    
                    return
                }
                
                print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if ( json["success"] as! Int == 1 ) {
                            self.alertController.dismiss(animated: true, completion: {
                                self.sendinscriptionEtape3()
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
                self.alertController.dismiss(animated: true, completion: {
                    self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                })
            })
        }
    }
    
    func sendinscriptionEtape3() {
        print("etape 3")
        
        let imageData:NSData = UIImagePNGRepresentation(imageSelfie!)! as NSData
        
        let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
        
        var params = [String : Any]()
        
        params["type"] = "sendimageselfie"
        params["userid"] = preferences.string(forKey: "userid") ?? ""
        params["imageselfie"] = strBase64
        
        alertController =  UIAlertController(title: nil, message: "Enregistrement\n3/3\n", preferredStyle: .alert)
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
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopupFermable(title:"Inscription terminée !",message:"Votre compte sera validé sous 24h, checkez vos mails !")
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
    
    func afficherPopupFermable( title : String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.dismiss(animated: true)
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func imgSelfieTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
 
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        imageSelfie = resizeImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage, targetSize: CGSize(width: 500, height: 500))
        
        imgSelfie.image = imageSelfie
        imgSelfie.backgroundColor = UIColor.white
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func afficherPopup( title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
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
    
    @objc func labelCGUTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        UIApplication.shared.open(URL(string: "http://mi-app.fr/CGU-MI.pdf")!, options: [:], completionHandler: nil)
    }
}
